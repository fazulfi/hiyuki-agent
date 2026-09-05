# 13 — Roadmap (Fase Eksekusi)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-81, D-25)
Dependensi dokumen: 10-teardown-migration, 14-implementation-plan

---

## 1. Prinsip

- Timeline santai (D-81), production langsung (D-25).
- Fase sekuensial dengan checkpoint.

## 2. Ringkasan fase

| Fase | Nama | Output |
|---|---|---|
| F0 | Persiapan & backup | backup final state.db + SOUL salinan |
| F1 | Repo baru hiyuki-agent | git init, struktur config/+deploy/+docs/+README |
| F2 | SOUL + OPS rewrite | SOUL verbatim (bersih Suisui), OPS lean |
| F3 | Config & secrets | config.yaml single, .env.sops, 36 MCP ON |
| F4 | Teardown lama | stop 6 service, DROP tabel tanpa replacement, archive repo |
| F5 | State (no DB) | fresh state.db SQLite, TANPA Postgres/Alembic |
| F6 | Install Hermes | git clone + uv venv (luar source) + uv pip install, pinned commit |
| F7 | Deploy | tarball, single unit hiyuki-gateway.service |
| F8 | Verifikasi | DSML P1, full-tool, 12 gate |

## 3. Dependensi antar fase

| Fase | Bergantung pada |
|---|---|
| F1 | F0 |
| F2 | F1 (perlu repo) |
| F3 | F2 |
| F4 | F0 |
| F5 | F4 |
| F6 | F1 |
| F7 | F3, F5, F6 |
| F8 | F7 |

## 4. Checkpoint per fase

Setiap fase punya bukti (log / diff / screenshot) di `evidence/`.

## 5. Definisi selesai

- F8 lulus semua 12 acceptance gate + full-tool verification D-80.
