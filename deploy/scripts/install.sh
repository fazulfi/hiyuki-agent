#!/usr/bin/env bash
#
# hiyuki-agent installer — idempotent, safe to re-run.
#
# Installs a vanilla single-agent Hermes gateway:
#   - Hermes (NousResearch/hermes-agent) as a pinned git dependency at /opt/hiyuki/hermes
#   - uv venv at /opt/hiyuki/.venv (OUTSIDE the Hermes source tree, per D-150)
#   - config/ + SOUL.md + OPS.md into $HERMES_HOME
#   - systemd unit hiyuki-gateway.service
#
# Locked facts (see docs/decisions.md): D-27..D-30, D-57..D-61, D-149..D-152.
#
# Secrets are NEVER committed in plaintext. Runtime credentials are decrypted
# at install time from SOPS/age ciphertext via `sops -d` (D-65, D-51).
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (all overridable via environment for staged/alternate installs)
# ---------------------------------------------------------------------------
APP_DIR="${APP_DIR:-/opt/hiyuki}"
HERMES_HOME="${HERMES_HOME:-/home/gamesim/.hermes-hiyuki}"
VENV_DIR="${APP_DIR}/.venv"
HERMES_SRC="${APP_DIR}/hermes"
CONFIG_DEST="${APP_DIR}/config"
SERVICE_USER="gamesim"
SERVICE_NAME="hiyuki-gateway.service"
SYSTEMD_UNIT="/etc/systemd/system/${SERVICE_NAME}"

HERMES_REPO="https://github.com/NousResearch/hermes-agent"
# Pinned ref (D-29). ~0.21.0 (= tag v2026.8.31); extras messaging+mcp. Override with HERMES_REF
# to pin a different tag or an exact commit hash for reproducibility.
HERMES_REF="${HERMES_REF:-v2026.8.31}"

# SOPS/age (D-65). The age key lives outside the repo; the sops ciphertext
# lives at $CONFIG_DEST/.env.sops (or $HERMES_HOME/.env if you place it there).
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-/etc/gamesim/age.key}"

# This script lives at deploy/scripts/install.sh; repo root is two levels up.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

log() { printf '[install] %s\n' "$*"; }
die() { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }

require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        die "must run as root (writes /opt and /etc/systemd, manages systemd unit)"
    fi
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

# ---------------------------------------------------------------------------
# 1. Prepare user and directories (idempotent)
# ---------------------------------------------------------------------------
ensure_user_and_dirs() {
    if ! id -u "${SERVICE_USER}" >/dev/null 2>&1; then
        log "creating service user '${SERVICE_USER}'"
        useradd --system --create-home --home-dir "$(dirname "${HERMES_HOME}")" \
            --shell /usr/sbin/nologin "${SERVICE_USER}"
    fi

    mkdir -p "${APP_DIR}" "${VENV_DIR%/*}" "${CONFIG_DEST}" "${HERMES_HOME}"
    # Hermes native subdirs (D-30): config + memories + sessions + skills.
    mkdir -p "${HERMES_HOME}/memories" "${HERMES_HOME}/sessions" "${HERMES_HOME}/skills"
    chown -R "${SERVICE_USER}:${SERVICE_USER}" "${HERMES_HOME}"
    chown -R "${SERVICE_USER}:${SERVICE_USER}" "${APP_DIR}"
    log "directories ready: ${APP_DIR}, ${HERMES_HOME}"
}

# ---------------------------------------------------------------------------
# 2. Clone / pin Hermes into /opt/hiyuki/hermes (idempotent, D-150)
# ---------------------------------------------------------------------------
ensure_hermes() {
    if [[ ! -d "${HERMES_SRC}/.git" ]]; then
        log "cloning Hermes from ${HERMES_REPO}"
        mkdir -p "${HERMES_SRC}"
        git clone --no-checkout "${HERMES_REPO}" "${HERMES_SRC}"
    else
        log "Hermes checkout already present; updating refs"
        git -C "${HERMES_SRC}" fetch --tags --quiet origin
    fi

    log "pinning Hermes to ref '${HERMES_REF}'"
    git -C "${HERMES_SRC}" checkout --quiet "${HERMES_REF}"
    git -C "${HERMES_SRC}" submodule update --init --recursive 2>/dev/null || true
    chown -R "${SERVICE_USER}:${SERVICE_USER}" "${HERMES_SRC}"
    log "Hermes pinned at $(git -C "${HERMES_SRC}" rev-parse --short HEAD)"
}

# ---------------------------------------------------------------------------
# 3. Create uv venv OUTSIDE the source tree + install (idempotent, D-150)
# ---------------------------------------------------------------------------
ensure_venv_and_install() {
    require_cmd uv

    if [[ ! -x "${VENV_DIR}/bin/python" ]]; then
        log "creating uv venv at ${VENV_DIR}"
        uv venv --python 3.11 "${VENV_DIR}"
    else
        log "venv already present at ${VENV_DIR}"
    fi

    # Editable install of Hermes with the messaging + mcp extras.
    # requires-python >=3.11,<3.14 is load-bearing (D-150).
    log "installing Hermes editable with [messaging,mcp] extras"
    (
        cd "${HERMES_SRC}"
        "${VENV_DIR}/bin/uv" pip install -e ".[messaging,mcp]"
    )
    log "Hermes installed; hermes binary at ${VENV_DIR}/bin/hermes"
}

# ---------------------------------------------------------------------------
# 4. Place config/ (config.yaml provided by the repo; do not fabricate)
# ---------------------------------------------------------------------------
ensure_config() {
    if [[ -f "${REPO_DIR}/config/config.yaml" ]]; then
        log "copying config.yaml from repo to ${CONFIG_DEST}"
        install -o "${SERVICE_USER}" -g "${SERVICE_USER}" -m 0640 \
            "${REPO_DIR}/config/config.yaml" "${CONFIG_DEST}/config.yaml"
    else
        log "no config/config.yaml in repo yet — another agent owns it; skipping"
    fi

    # SOPS ciphertext, if shipped in the repo (never plaintext).
    if [[ -f "${REPO_DIR}/config/.env.sops" ]]; then
        install -o "${SERVICE_USER}" -g "${SERVICE_USER}" -m 0600 \
            "${REPO_DIR}/config/.env.sops" "${CONFIG_DEST}/.env.sops"
    fi
}

# ---------------------------------------------------------------------------
# 5. Install SOUL.md + OPS.md into $HERMES_HOME (D-152: SOUL.md = identity #1)
# ---------------------------------------------------------------------------
ensure_identity_files() {
    for name in SOUL.md OPS.md; do
        if [[ -f "${REPO_DIR}/${name}" ]]; then
            install -o "${SERVICE_USER}" -g "${SERVICE_USER}" -m 0644 \
                "${REPO_DIR}/${name}" "${HERMES_HOME}/${name}"
            log "installed ${name} -> ${HERMES_HOME}/${name}"
        else
            die "missing ${REPO_DIR}/${name}; SOUL.md and OPS.md are required for the gateway"
        fi
    done
}

# ---------------------------------------------------------------------------
# 6. Decrypt secrets via sops (D-51, D-65) — never write plaintext to git
# ---------------------------------------------------------------------------
ensure_secrets() {
    local sops_src="${CONFIG_DEST}/.env.sops"
    local env_dest="${HERMES_HOME}/.env"

    if [[ ! -f "${sops_src}" ]]; then
        log "no ${sops_src} present; create it with the operator's age key, then:"
        log "  SOPS_AGE_KEY_FILE=${SOPS_AGE_KEY_FILE} sops -d ${sops_src} > ${env_dest}"
        log "or write ${env_dest} directly via a secure channel (never commit it)."
        return 0
    fi

    if [[ ! -f "${SOPS_AGE_KEY_FILE}" ]]; then
        die "sops ciphertext present but age key missing at ${SOPS_AGE_KEY_FILE}; cannot decrypt"
    fi

    require_cmd sops
    log "decrypting ${sops_src} -> ${env_dest} via sops -d"
    SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE}" sops -d "${sops_src}" > "${env_dest}"
    chown "${SERVICE_USER}:${SERVICE_USER}" "${env_dest}"
    chmod 0600 "${env_dest}"
    log "secrets decrypted; plaintext .env lives only at ${env_dest} (not in git)"
}

# ---------------------------------------------------------------------------
# 7. Install + enable systemd unit (D-58, D-61: journald only)
# ---------------------------------------------------------------------------
ensure_systemd() {
    local unit_src="${REPO_DIR}/deploy/systemd/${SERVICE_NAME}"
    if [[ ! -f "${unit_src}" ]]; then
        die "missing ${unit_src}"
    fi

    log "installing systemd unit ${SERVICE_NAME}"
    install -m 0644 "${unit_src}" "${SYSTEMD_UNIT}"
    systemctl daemon-reload
    systemctl enable --now "${SERVICE_NAME}"
    log "enabled and started ${SERVICE_NAME}"
}

# ---------------------------------------------------------------------------
main() {
    require_root
    require_cmd git

    ensure_user_and_dirs
    ensure_hermes
    ensure_venv_and_install
    ensure_config
    ensure_identity_files
    ensure_secrets
    ensure_systemd

    log "install complete. Inspect logs with:"
    log "  journalctl -u ${SERVICE_NAME} -f"
}

main "$@"