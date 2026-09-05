#!/usr/bin/env bash
#
# hiyuki-agent daily backup (D-79, D-60).
#
# Backs up the running state of the Hiyuki gateway:
#   - SOUL.md, OPS.md, state.db, memories/, sessions/ (all under $HERMES_HOME)
#   - config.yaml + .env.sops ciphertext (never the decrypted .env)
#
# Strategy: rsync the Hermes home into a dated snapshot dir, then tar it into
# a single archive. Retention keeps the last N=14 days and prunes older sets.
#
# Offsite replication (e.g. S3) is intentionally OUT OF SCOPE for this repo.
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (overridable)
# ---------------------------------------------------------------------------
HERMES_HOME="${HERMES_HOME:-/home/gamesim/.hermes-hiyuki}"
APP_DIR="${APP_DIR:-/opt/hiyuki}"
BACKUP_ROOT="${BACKUP_ROOT:-${APP_DIR}/backups}"
KEEP_DAYS="${KEEP_DAYS:-14}"
STAMP="$(date +%Y-%m-%d)"
DEST="${BACKUP_ROOT}/${STAMP}"
ARCHIVE="${BACKUP_ROOT}/hiyuki-backup-${STAMP}.tar.gz"

log() { printf '[backup] %s\n' "$*"; }
die() { printf '[backup] ERROR: %s\n' "$*" >&2; exit 1; }

[[ -d "${HERMES_HOME}" ]] || die "HERMES_HOME not found: ${HERMES_HOME}"

mkdir -p "${DEST}"

# 1. Snapshot the Hermes home (SOUL.md, OPS.md, state.db, memories/, sessions/).
#    Use --delete so the snapshot mirrors the live tree exactly.
log "rsyncing ${HERMES_HOME} -> ${DEST}/hermes-home"
rsync -a --delete "${HERMES_HOME}/" "${DEST}/hermes-home/"

# 2. Copy config (config.yaml + SOPS ciphertext only; never plaintext .env).
mkdir -p "${DEST}/config"
if [[ -f "${APP_DIR}/config/config.yaml" ]]; then
    cp -a "${APP_DIR}/config/config.yaml" "${DEST}/config/config.yaml"
fi
if [[ -f "${APP_DIR}/config/.env.sops" ]]; then
    cp -a "${APP_DIR}/config/.env.sops" "${DEST}/config/.env.sops"
fi

# 3. Bundle into a single tar archive (tar + rsync per spec).
log "creating archive ${ARCHIVE}"
tar -czf "${ARCHIVE}" -C "${BACKUP_ROOT}" "${STAMP}"

# 4. Prune snapshots and archives older than KEEP_DAYS.
log "pruning backups older than ${KEEP_DAYS} days"
find "${BACKUP_ROOT}" -maxdepth 1 -type d -name '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' \
    -mtime "+${KEEP_DAYS}" -exec rm -rf {} +
find "${BACKUP_ROOT}" -maxdepth 1 -type f -name 'hiyuki-backup-*.tar.gz' \
    -mtime "+${KEEP_DAYS}" -delete

log "backup complete: ${ARCHIVE}"