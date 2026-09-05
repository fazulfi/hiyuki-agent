# 14 — Implementation Plan (Step Breakdown + Struktur Repo)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-82, D-86, D-90)
Dependensi dokumen: 03-architecture, 13-roadmap

---

## 1. Tujuan

Menghasilkan repo `hiyuki-agent` yang menjalankan vanilla Hermes (dependency git, pinned commit) sebagai single agent Hiyuki, dengan config + SOUL + OPS + AGENTS.md + plugin RAG.

## 2. Ringkasan teknologi

| Lapisan | Pilihan | Keputusan |
|---|---|---|
| Runtime | NousResearch/hermes-agent (git, pinned ~0.21.0) | D-29, D-82 |
| LLM | DeepSeek V4 via MarketTabrak Router | D-13..D-15 |
| Memory | enowx-rag TEI (plugin memory-provider) | D-18, D-83 |
| DB | SQLite `state.db` Hermes (native, fresh) — Postgres/Alembic dibuang | D-146 |
| Redis | Dibuang | D-88 |
| Deploy | tarball + systemd single unit | D-57, D-58 |

## 3. Struktur repositori `hiyuki-agent`

```
hiyuki-agent/
├── README.md
├── AGENTS.md               # kontrak coding agent Sisyphus (auto-load, D-156)
├── pyproject.toml          # hermes = dependency git pinned
├── config/
│   ├── config.yaml          # single, command_allowlist hapus
│   ├── SOUL.md              # rewrite verbatim (bersih Suisui)
│   ├── OPS.md               # lean
│   └── .env.sops            # secrets (sops/age)
├── deploy/
│   ├── systemd/hiyuki-gateway.service
│   └── scripts/install.sh   # idempotent bash
├── plugins/
│   └── memory-providers/enowx-rag/   # wiring RAG native
├── docs/
│   ├── ops/                 # runbook
│   └── ...
└── greenfield-plan/         # (opsional) arsip plan ini
```

## 4. Skema data (D-146)

TIDAK ada Postgres / Alembic / DDL. Data plane = SQLite `state.db` Hermes (sessions/messages/routing, dibuat otomatis Hermes) + remote enowx-rag (memory). Fresh/kosong saat rebuild.

## 5. Uraian task per fase

**F0 — Persiapan & backup**
- [ ] Backup state.db + SOUL asli + config salinan (TANPA pg_dump, DB dibuang).

**F1 — Repo baru**
- [ ] `git init hiyuki-agent`, remote github.com/fazulfi/hiyuki-agent.
- [ ] pyproject.toml dengan hermes git pinned.
- [ ] Struktur dir config/ + deploy/ + docs/ + plugins/ + README.

**F2 — SOUL + OPS + AGENTS**
- [ ] Baca SOUL asli VPS (.sisyphus/research/SOUL-hiyuki-VPS-original.md).
- [ ] Rewrite verbatim, hapus ref Suisui + backend stale.
- [ ] Tulis OPS.md lean.
- [ ] Copy AGENTS.md draft (`greenfield-plan/draft/AGENTS.md`) → root repo.

**F3 — Config & secrets**
- [ ] config.yaml single (command_allowlist dihapus, max_iterations 500, approvals off).
- [ ] .env.sops dengan secrets keep (DISCORD_BOT_TOKEN, MARKETTABRAK, BRAVE).

**F4 — Teardown**
- [ ] Stop 6 service lama + disable unit systemd (`wwma-gateway-*`, `gamesim-*`, `hermes-gateway-guinevere`).
- [ ] Archive + tag repo lama (GitHub).
- [ ] `docker compose -f /opt/wwma/docker-compose*.yml down -v` (Postgres + Redis + dashboard).
- [ ] DROP database Postgres lama (tanpa replacement) — atau hapus container/volume.
- [ ] `docker system prune -a --volumes` (image/volume dangling).
- [ ] `rm -rf /opt/wwma` (repo lama + venv + build + checkout Hermes lama).
- [ ] Verifikasi bersih: `/opt/wwma` hilang, `docker ps -a` kosong (kecuali openbao), port 5432/6379 tidak listening.

**F5 — State (no DB)**
- [ ] Pastikan fresh state.db (hapus lama 686MB), TANPA Postgres/Alembic.

**F6 — Install Hermes**
- [ ] git clone pinned commit + `uv venv` DI LUAR source + `uv pip install -e ".[messaging,mcp]"`.
- [ ] Verifikasi requires-python >=3.11,<3.14.
- [ ] Install plugin memory-provider enowx-rag.

**F7 — Deploy**
- [ ] Tarball archive → SCP → extract → atomic switch.
- [ ] systemd hiyuki-gateway.service (tanpa hardening), ExecStart = `hermes gateway start`.

**F8 — Verifikasi**
- [ ] DSML P1 (curl router → JSON tool_calls).
- [ ] Full-tool verification (7 poin D-80).
- [ ] 12 acceptance gate.

## 6. Definisi selesai

F8 hijau + semua gate + full-tool D-80 terverifikasi.
