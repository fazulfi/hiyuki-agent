# 09 — Deployment & Ops (systemd Single Unit, Backup, Monitoring)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-24..D-26, D-57..D-61, D-79, D-90)
Dependensi dokumen: 03-architecture, 10-teardown-migration

---

## 1. Topologi deploy

| Aspek | Nilai | Keputusan |
|---|---|---|
| Host | VPS gamesim@82.25.62.204 (Tailscale ggl-vps 100.100.17.99) | D-26 |
| Path | `/opt/hiyuki` (bersih, bukan /opt/wwma) | D-149 |
| Metode deploy | tarball archive (git archive → SCP → extract → atomic switch) | D-57 |
| Unit systemd | `hiyuki-gateway.service` (single) | D-58 |
| Environment | Production langsung | D-25 |

## 2. Unit systemd (D-59)

- **Tanpa hardening** (hapus `NoNewPrivileges`, `ProtectSystem`, `ProtectHome`, `DevicePolicy`).
- Single unit `hiyuki-gateway.service`.
- Nama bersih dari jejak `wwma`.

```
[Unit]
Description=Hiyuki Gateway (vanilla Hermes)
After=network-online.target

[Service]
User=gamesim
WorkingDirectory=/opt/hiyuki
Environment=HERMES_HOME=/home/gamesim/.hermes-hiyuki
ExecStart=/opt/hiyuki/.venv/bin/hermes gateway start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

> ExecStart = `hermes gateway start` (SATU proses Hermes untuk Discord; D-151). Binary `hermes` = console-script entry `hermes_cli.main` di venv (di luar source, D-150).

## 3. Install (D-82, D-90, D-150)

- Hermes: `git clone` + `uv venv` **di luar source** + `uv pip install -e ".[messaging,mcp]"`.
- GOTCHA: venv TIDAK boleh di dalam direktori checkout agent (perintah relative-path agent bisa menghapus runtime kerja).
- requires-python `>=3.11,<3.14` (3.14 = maturin build gagal).
- Install script idempotent bash (`deploy/scripts/install.sh`) + runbook (`docs/ops/`).

## 4. Backup (D-79)

- Cadence: **harian** (cron / systemd timer).
- Cakupan: `$HERMES_HOME/` (config.yaml, .env.sops, SOUL.md, OPS.md, memories/, state.db) + repo git.
- TIDAK ada Postgres dump (DB dibuang, D-146).
- Retensi: N hari rolling + git remote offsite (config/code).

## 5. Observability (D-61)

- **journald only**.
- Buang Prometheus / Grafana / langfuse / ClickHouse / MinIO.

## 6. Rollback

- Atomic switch deploy (tarball) memungkinkan rollback ke rilis sebelumnya.
- Git tag per rilis.

## 7. Ops dijalankan AI

- Hiyuki punya akses penuh ke infra (D-08) — termasuk restart service sendiri.
- OPS.md lean: just-do-it, zero-approval, anti-hoax.

## 8. Incident runbook minimal

1. Deteksi (journald log).
2. Triage (cek service status, DB, router).
3. Mitigasi (restart service / rollback rilis).
4. Komunikasi (inform ke Faiz).
5. Post-mortem (catat di RAG).

## 9. Sops → env flow (G5)

1. Rahasia tersimpan terenkripsi di `config/.env.sops` (age key `/etc/gamesim/age.key`).
2. Saat deploy/start: `sops -d config/.env.sops > $HERMES_HOME/.env`.
3. Hermes membaca `.env` (secrets only); non-secret di config.yaml.
4. config.yaml boleh merujuk via `${env:VAR}` atau blok `secrets:` (inject saat startup).
5. systemd TIDAK menyimpan secret; unit hanya set `HERMES_HOME` + path binary.

## 10. Restore (DR, G8)

1. Siapkan `/opt/hiyuki` kosong (clone repo + checkout tag).
2. Restore `$HERMES_HOME/` dari backup (config, SOUL, OPS, state.db, memories).
3. `uv venv .venv` + `uv pip install -e ".[messaging,mcp]"`.
4. `sops -d` restore `.env`.
5. `systemctl start hiyuki-gateway` + smoke test (pesan di #play).
