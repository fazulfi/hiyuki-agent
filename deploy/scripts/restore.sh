#!/usr/bin/env bash
#
# hiyuki-agent restore (see deploy/restore-runbook.md for the full procedure).
#
# Restores the Hermes home (SOUL.md, OPS.md, state.db, memories/, sessions/)
# and config.yaml from a backup produced by deploy/scripts/backup.sh.
#
# Usage:
#   restore.sh <archive.tar.gz | snapshot-dir>
#
# The gateway MUST be stopped during restore to avoid a torn state.db.
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-/home/gamesim/.hermes-hiyuki}"
APP_DIR="${APP_DIR:-/opt/hiyuki}"
SERVICE_NAME="${SERVICE_NAME:-hiyuki-gateway.service}"

log() { printf '[restore] %s\n' "$*"; }
die() { printf '[restore] ERROR: %s\n' "$*" >&2; exit 1; }

[[ $# -eq 1 ]] || die "usage: $0 <archive.tar.gz | snapshot-dir>"
SRC="$1"
[[ -e "${SRC}" ]] || die "backup source not found: ${SRC}"

if [[ "$(id -u)" -ne 0 ]]; then
    die "must run as root (stops/starts systemd unit, writes ${HERMES_HOME})"
fi

# 1. Stop the gateway so state.db is not being written during restore.
log "stopping ${SERVICE_NAME}"
systemctl stop "${SERVICE_NAME}" 2>/dev/null || true

# 2. Materialize a snapshot dir (extract if we were given the tar archive).
SNAPSHOT=""
if [[ -d "${SRC}" ]]; then
    SNAPSHOT="${SRC}"
else
    SNAPSHOT="$(mktemp -d)"
    log "extracting ${SRC} -> ${SNAPSHOT}"
    tar -xzf "${SRC}" -C "${SNAPSHOT}"
    # The archive contains a single top-level dated dir.
    SNAPSHOT="$(find "${SNAPSHOT}" -mindepth 1 -maxdepth 1 -type d | head -n1)"
    [[ -n "${SNAPSHOT}" ]] || die "no snapshot dir found inside archive"
fi

# 3. Restore the Hermes home.
mkdir -p "${HERMES_HOME}"
if [[ -d "${SNAPSHOT}/hermes-home" ]]; then
    log "restoring ${SNAPSHOT}/hermes-home -> ${HERMES_HOME}"
    rsync -a --delete "${SNAPSHOT}/hermes-home/" "${HERMES_HOME}/"
else
    die "snapshot missing hermes-home/ directory"
fi

# 4. Restore config.yaml (config/.env.sops is restored manually — see runbook).
if [[ -f "${SNAPSHOT}/config/config.yaml" ]]; then
    mkdir -p "${APP_DIR}/config"
    log "restoring config.yaml -> ${APP_DIR}/config/config.yaml"
    cp -a "${SNAPSHOT}/config/config.yaml" "${APP_DIR}/config/config.yaml"
fi

# 5. Fix ownership to the service user if present.
if id -u gamesim >/dev/null 2>&1; then
    chown -R gamesim:gamesim "${HERMES_HOME}" "${APP_DIR}/config"
fi

# 6. Restart the gateway.
log "starting ${SERVICE_NAME}"
systemctl start "${SERVICE_NAME}"

log "restore complete. Verify with: journalctl -u ${SERVICE_NAME} -f"