# Deploy — hiyuki-agent

Deployment assets for the vanilla single-agent Hermes gateway.

## Layout

| Path | Purpose |
|---|---|
| `deploy/systemd/hiyuki-gateway.service` | The single systemd unit (no hardening directives, `Restart=on-failure`, journald only). |
| `deploy/scripts/install.sh` | Idempotent installer: clones/pins Hermes, creates the uv venv outside the source tree, installs `[messaging,mcp]`, places config + SOUL/OPS, decrypts secrets, installs + enables the unit. |
| `deploy/scripts/backup.sh` | Daily backup (SOUL.md, OPS.md, state.db, memories/, sessions/, config.yaml, `.env.sops`); keeps 14 days. |
| `deploy/scripts/restore.sh` | Restores a backup archive/snapshot and restarts the gateway. |
| `deploy/restore-runbook.md` | Step-by-step restore (DR) and software-only rollback procedure. |

## Locked facts

These are pinned by `docs/decisions.md` and must not drift:

- Install path `/opt/hiyuki`; unit `hiyuki-gateway.service`.
- venv at `/opt/hiyuki/.venv` (outside the Hermes source tree).
- `ExecStart=/opt/hiyuki/.venv/bin/hermes gateway start`.
- `HERMES_HOME=/home/gamesim/.hermes-hiyuki`, `User=gamesim`.
- No systemd hardening directives; `Restart=on-failure`; `WantedBy=multi-user.target`.
- Logging via journald only (no Prometheus/Grafana).
- Secrets via SOPS/age; plaintext `.env` is never committed or backed up.
- Discord: `require_mention false`, operator allowlist only, natural language only,
  11 channels (`#play` + `hiyuki-1..10`), no slash commands.
- Hermes pinned `~0.21.0`, extras `messaging,mcp`; Python `>=3.11,<3.14`.

## Quick start

```
sudo deploy/scripts/install.sh
journalctl -u hiyuki-gateway.service -f
```