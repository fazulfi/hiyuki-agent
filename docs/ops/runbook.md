# Operational Runbook — hiyuki-agent

Day-to-day operation of the Hiyuki gateway (single-agent vanilla Hermes).
Deployment and DR specifics live in `deploy/`; this runbook is the operator
reference.

## Facts

| Item | Value |
|---|---|
| Service | `hiyuki-gateway.service` |
| Working dir | `/opt/hiyuki` |
| Hermes home | `/home/gamesim/.hermes-hiyuki` |
| venv | `/opt/hiyuki/.venv` |
| Logs | journald only (no Prometheus/Grafana) |
| Secrets | SOPS/age; ciphertext `/opt/hiyuki/config/.env.sops`; age key `/etc/gamesim/age.key` |

## Daily backup

Run `deploy/scripts/backup.sh` (scheduled daily via cron or a systemd timer).
It archives `SOUL.md`, `OPS.md`, `state.db`, `memories/`, `sessions/`, and
`config.yaml` + `.env.sops` (never the decrypted `.env`) into
`/opt/hiyuki/backups/` and keeps the last 14 days.

```
sudo /opt/hiyuki/.../deploy/scripts/backup.sh
ls -lt /opt/hiyuki/backups/
```

Suggested cron line (runs 03:00 daily):

```
0 3 * * * /opt/hiyuki/.../deploy/scripts/backup.sh >> /var/log/hiyuki-backup.log 2>&1
```

## Log review (journald)

All gateway output is captured by journald. Common commands:

```
journalctl -u hiyuki-gateway.service -f                  # follow
journalctl -u hiyuki-gateway.service -n 200              # last 200 lines
journalctl -u hiyuki-gateway.service --since "1 hour ago" # last hour
journalctl -u hiyuki-gateway.service -p err -b           # errors this boot
```

Service health:

```
systemctl status hiyuki-gateway.service
```

## Restart

```
systemctl restart hiyuki-gateway.service
journalctl -u hiyuki-gateway.service -f
```

If the unit changes on disk (after `install.sh` or a hand edit):

```
systemctl daemon-reload
systemctl restart hiyuki-gateway.service
```

## Restore (disaster recovery)

See `deploy/restore-runbook.md` for the full procedure. Short form:

```
systemctl stop hiyuki-gateway.service
/opt/hiyuki/.../deploy/scripts/restore.sh /opt/hiyuki/backups/hiyuki-backup-YYYY-MM-DD.tar.gz
journalctl -u hiyuki-gateway.service -f
```

If `.env` is missing after restore, re-decrypt it:

```
SOPS_AGE_KEY_FILE=/etc/gamesim/age.key sops -d /opt/hiyuki/config/.env.sops > /home/gamesim/.hermes-hiyuki/.env
chown gamesim:gamesim /home/gamesim/.hermes-hiyuki/.env
chmod 600 /home/gamesim/.hermes-hiyuki/.env
```

## Rollback (software only)

Revert Hermes to a previous pinned ref without touching memories/sessions:

```
systemctl stop hiyuki-gateway.service
git -C /opt/hiyuki/hermes fetch --tags origin
git -C /opt/hiyuki/hermes checkout <previous-commit-or-tag>
cd /opt/hiyuki/hermes && /opt/hiyuki/.venv/bin/uv pip install -e ".[messaging,mcp]"
systemctl start hiyuki-gateway.service
journalctl -u hiyuki-gateway.service -f
```

## Routine checks

- Confirm the gateway is connected to Discord (`#play` + `hiyuki-1..10`) in
  the startup log.
- Confirm the RAG `MEMORY CONTEXT` block appears in turns with source metadata.
- Confirm no plaintext secret is present in `/opt/hiyuki/backups/` (only
  `.env.sops` ciphertext is expected).