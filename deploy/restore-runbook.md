# Restore Runbook — hiyuki-agent

This runbook describes how to restore the Hiyuki gateway from a backup produced
by `deploy/scripts/backup.sh`, and how to roll back a bad deploy. It is the
manual companion to `deploy/scripts/restore.sh`.

## When to use

- `state.db` (Hermes SQLite) is corrupted or deleted.
- `SOUL.md` / `OPS.md` are lost or damaged.
- A deploy introduced a regression and you need the previous known-good state.

A restore is a **disaster-recovery** operation: it returns the gateway to its
state at backup time. A rollback (last section) returns only the Hermes
checkout + running process to a previous installed version, without touching
memories/sessions.

## Prerequisites

- Root access on the VPS (`gamesim@` host).
- A backup archive at `/opt/hiyuki/backups/hiyuki-backup-YYYY-MM-DD.tar.gz`
  (or a dated snapshot dir under the same root).
- The SOPS age key at `/etc/gamesim/age.key` (only if you also need to
  re-decrypt secrets; a running gateway already has `/home/gamesim/.hermes-hiyuki/.env`).

## Restore procedure

1. **Stop the gateway**

   ```
   systemctl stop hiyuki-gateway.service
   ```

   Always stop the service first so `state.db` is not written mid-restore.

2. **Select the backup source**

   `backup.sh` keeps the last 14 days. List what is available:

   ```
   ls -lt /opt/hiyuki/backups/
   ```

   Pick either an archive (`hiyuki-backup-YYYY-MM-DD.tar.gz`) or a dated
   snapshot directory (`/opt/hiyuki/backups/YYYY-MM-DD/`).

3. **Run the restore script**

   ```
   /opt/hiyuki/.../deploy/scripts/restore.sh /opt/hiyuki/backups/hiyuki-backup-YYYY-MM-DD.tar.gz
   ```

   The script stops the service (idempotent with step 1), extracts the archive,
   rsyncs `hermes-home/` into `/home/gamesim/.hermes-hiyuki`, restores
   `config.yaml`, fixes ownership, and restarts the gateway.

4. **Restore secrets if needed**

   The backup contains only the SOPS ciphertext `config/.env.sops`, never the
   decrypted `.env`. If `.env` is missing from the Hermes home, re-decrypt:

   ```
   SOPS_AGE_KEY_FILE=/etc/gamesim/age.key sops -d /opt/hiyuki/config/.env.sops > /home/gamesim/.hermes-hiyuki/.env
   chown gamesim:gamesim /home/gamesim/.hermes-hiyuki/.env
   chmod 600 /home/gamesim/.hermes-hiyuki/.env
   ```

5. **Verify the gateway is healthy**

   ```
   systemctl status hiyuki-gateway.service
   journalctl -u hiyuki-gateway.service -f
   ```

   Confirm the gateway reconnects to Discord (natural-language channel
   `#play` + `hiyuki-1..10`) and that `state.db` is complete.

## Rollback (software only)

A rollback reverts Hermes to a previously known-good pinned version without
touching memories, sessions, or config.

1. Stop the gateway:

   ```
   systemctl stop hiyuki-gateway.service
   ```

2. Check out the previous pinned ref in `/opt/hiyuki/hermes`:

   ```
   git -C /opt/hiyuki/hermes fetch --tags origin
   git -C /opt/hiyuki/hermes log --oneline -5
   git -C /opt/hiyuki/hermes checkout <previous-commit-or-tag>
   ```

3. Reinstall the editable package into the venv:

   ```
   cd /opt/hiyuki/hermes
   /opt/hiyuki/.venv/bin/uv pip install -e ".[messaging,mcp]"
   ```

4. Restart:

   ```
   systemctl start hiyuki-gateway.service
   journalctl -u hiyuki-gateway.service -f
   ```

## Notes

- Offsite replication (S3) is out of scope; backups are local only.
- Retention is 14 days. Restore older state only if you kept archives longer
  than the default by raising `KEEP_DAYS`.
- The decrypted `.env` must never be committed or copied into backups.