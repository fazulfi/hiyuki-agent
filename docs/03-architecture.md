# 03 — Arsitektur (Vanilla Hermes + Config + Plugin)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-10, D-12, D-29, D-30, D-82..D-86, D-88, D-146, D-150..D-155)
Dependensi dokumen: 04-llm-integration, 05-memory-rag, 07-config-inventory

---

## 1. Prinsip arsitektur

**Vanilla Hermes upstream, bukan fork, bukan monkey-patch.**

- Hermes = **dependency git** (D-86), di-pin ke commit eksak (D-29).
- Tidak ada `app/` (248 file custom dibuang, D-10).
- Fitur custom yang tersisa = **plugin native** upstream (D-83): `plugins/memory-providers/`.
- Semua konfigurasi via `config.yaml` + `SOUL.md` + `OPS.md` + `.env.sops`.

## 2. Ringkasan teknologi

| Lapisan | Pilihan | Keputusan |
|---|---|---|
| Runtime agent | NousResearch/hermes-agent (Python) | D-29, D-82 |
| Versi | Latest main (≈0.21.0), pinned commit eksak | D-29 |
| Python | >=3.11, <3.14 | (upstream constraint) |
| Install | `git clone` + `uv venv` (luar source) + `uv pip install -e ".[messaging,mcp]"` | D-82, D-150 |
| LLM provider | MarketTabrak Router → DeepSeek V4 Flash | D-13..D-15 |
| Memory | enowx-rag (TEI), plugin memory-provider | D-18, D-83 |
| Session state | SQLite `state.db` Hermes (native) | D-88 |
| Redis | **Dibuang** | D-88 |
| DB | SQLite `state.db` Hermes (native fresh) — Postgres/Alembic dibuang | D-146 |
| Deploy | systemd single unit | D-24, D-58 |

## 3. Topologi deployment

```
VPS gamesim@/opt/hiyuki
│
├── Hermes (vanilla, git-pinned)
│   ├── $HERMES_HOME = /home/gamesim/.hermes-hiyuki
│   │   ├── config.yaml          (single profile Hiyuki)
│   │   ├── .env.sops            (1 key MarketTabrak/DeepSeek)
│   │   ├── SOUL.md              (persona, rewrite)
│   │   ├── OPS.md               (kontrak operasional lean)
│   │   ├── memories/            (native Hermes memory)
│   │   ├── sessions/            (native)
│   │   ├── skills/              (native)
│   │   └── state.db             (transcript durable, per-channel)
│   └── plugins/
│       └── memory-providers/
│           └── enowx-rag        (plugin native, TEI)
│
├── MarketTabrak Router  (127.0.0.1:20228/v1)  → api.deepseek.com
├── enowx-rag MCP        (rag.zrouter.dev, TEI) — ingestion bg service existing
└── systemd unit: hiyuki-gateway.service
```

## 4. Struktur repositori `hiyuki-agent` (D-86)

```
hiyuki-agent/
├── config/
│   ├── config.yaml            (single profile)
│   ├── .env.sops.example
│   ├── SOUL.md
│   └── OPS.md
├── deploy/
│   ├── systemd/hiyuki-gateway.service
│   └── scripts/install.sh     (idempotent bash, D-90)
├── docs/
│   └── ops/                   (runbook, D-90)
├── plugins/
│   └── memory-providers/enowx-rag/
├── README.md
└── (Hermes = dependency git, bukan source)
```

## 5. Alur turn (runtime)

```
Discord message (Faiz, channel hiyuki-*)
  → Hermes gateway (single, exact-one)
  → session load (state.db, keyed per channel)
  → RAG retrieve (enowx-rag, top-k 5–10) → inject MEMORY CONTEXT ke system prompt
  → LLM (MarketTabrak → DeepSeek V4, prefix T2 force-reasoning)
  → tool-calling loop (JSON tool_calls, max_iterations 500, no approval)
  → response (Bahasa Indonesia, persona Hiyuki) → Discord
  → ingestion (chat → enowx-rag, bg service)
```

## 6. Apa yang TIDAK ada lagi

| Dihapus | Keputusan |
|---|---|
| `app/` (248 file: core, memory, api, dashboard, p12, decomposition, handoff, personality, self_improve) | D-10 |
| Dual gateway + exact-two policy | D-02 |
| `app/shared/identity.py` CANONICAL_AGENT_IDS | D-02 |
| Dual secrets (WWMA_SUISUI_*) | D-02 |
| Redis | D-88 |
| shared_memory (peer Suisui) | D-85 |
| 34 tabel P12 (wallet/browser/economy/artifact/vault) + seluruh Postgres | D-66, D-146 |
| HMAC memory integrity, redaction, circuit breaker, lease, handoff | D-12 |
| Prometheus/Grafana/langfuse/ClickHouse/MinIO | D-61 |
| MCP custom: wwma-decomposition, wwma-handoff | (config findings) |
| Plugins: wwma-episodic-recorder, wwma-telemetry-recorder | (config findings) |
