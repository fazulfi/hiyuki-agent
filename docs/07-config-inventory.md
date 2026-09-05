# 07 — Inventaris Config & Secrets (config.yaml + MCP)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-47..D-51, D-65, config VPS findings)
Dependensi dokumen: 03-architecture, 06-discord-surface

---

## 1. Sumber baseline

`config-hiyuki-VPS-original.yaml` (306 baris, `.sisyphus/research/`) — baseline runtime saat ini, referensi rewrite (bukan dipertahankan mentah).

## 2. Perubahan config yang wajib

| Bagian | Sekarang | Target | Alasan |
|---|---|---|---|
| agent.name | Hiyuki | Hiyuki (tetap) | — |
| agent.max_iterations | 15 | **500** | D-50 |
| agent.approvals.mode | false | **off** (zero approval) | D-49 |
| agent.role | platform-peer | (single, sesuaikan) | D-02 |
| command_allowlist | ADA (`*`,`[`,`]`,`"`, sudo, -e/-c) | **HAPUS** | zero restriction |
| model.provider | markettabrak | markettabrak (tetap) | D-13 |
| model.key_env | WWMA_HIYUKI_MARKETTABRAK_API_KEY | **HIYUKI_MARKETTABRAK_API_KEY** (single) | D-02 |
| shared_memory | read_only | **HAPUS** | D-85 |
| plugins | wwma-episodic-recorder, wwma-memory-rag, wwma-telemetry-recorder | **hanya RAG** | (config findings) |
| mcp_servers | mayoritas enabled, beberapa disabled (grafana, prometheus) | **semua 36 ON** | D-47 |
| mcp custom | wwma-decomposition, wwma-handoff | **HAPUS** | (P12 custom) |

## 3. Parameter agent (target)

```
agent:
  name: Hiyuki
  max_iterations: 500
  approvals:
    mode: off
  destructive_slash_confirm: false
```

Tidak ada `command_allowlist`, tidak ada DENIED_TOOLSETS, tidak ada tool_policy.

## 4. MCP servers (36, semua ON — D-47)

Dari config VPS asli, server yang akan **semua enabled:true**:
filesystem, github, themissingmanual, time, wwma-memory, fetch, brave-search, weather-mcp, edgar, macalc, sequential-thinking, pdf-mcp, curl, jq, exa-search, tavily, firecrawl, sqlite, open-meteo, financial-data, spreadsheet, postgres-mcp, redis, postgres, docker, htop, systemctl, journalctl, tailscale, playwright, sops, age, grafana, prometheus.

**Dihapus dari daftar** (custom P12): wwma-decomposition, wwma-handoff.

> Catatan: grafana & prometheus di config asli `disabled:true` → sekarang ON (D-47 "semua 36 ON"). Tapi observability stack TIDAK di-deploy (D-61) — MCP server grafana/prometheus hanya sebagai *tool* yang tersedia jika Faiz ingin query, bukan observability pipeline aktif.

## 5. Secrets (via .env.sops)

| Secret | Status |
|---|---|
| `DISCORD_BOT_TOKEN` | KEEP (single bot) |
| `GUILD_ID`, `CHANNEL_*` | KEEP |
| `HIYUKI_MARKETTABRAK_API_KEY` | KEEP (single) |
| `WWMA_SUISUI_MARKETTABRAK_API_KEY` | **BUANG** (D-02) |
| `PAPYR_*` (legacy Budgezen) | **BUANG** |
| `WWMA_*_9ROUTER_API_KEY` (legacy) | **BUANG** |
| `GRAPH_EXTRACTION_API_KEY` | **BUANG** |
| `WWMA_EMBEDDING_API_KEY`, `OPENROUTER_API_KEY`, `EMBEDDING_MODEL`, `EMBEDDING_DIM` | **BUANG** (pakai TEI, D-18) |
| `BRAVE_API_KEY` | KEEP (untuk brave-search MCP) |
| `DATABASE_URL` | KEEP (DB baru minimal, D-87) |
| `REDIS_URL` | **BUANG** (D-88) |
| `WWMA_API_TOKEN`, `WWMA_DASHBOARD_*` | **BUANG** |
| `S3_*` | **BUANG** |
| `CIRCUIT_BREAKER_*` | **BUANG** |
| `MEMORY_INTEGRITY_HMAC_KEY` | **BUANG** (D-12) |
| `EPISODIC_RECORDING`, `REFLECTION` | **BUANG** |
| `LEASE_*` | **BUANG** |
| `GRAFANA`, `LANGFUSE`, `CLICKHOUSE`, `MINIO` | **BUANG** (D-61) |
| `HANDOFF_AUTH_KEY` | **BUANG** |

## 6. Enkripsi

- `config/.env.sops` dienkripsi sops/age.
- age key di `/etc/gamesim/age.key` (VPS, mode 600).
- OpenBao/Vault **dipertahankan** (D-65).

## 7. SOUL.md & OPS.md

- `SOUL.md` → rewrite (lihat 02-agent-spec).
- `OPS.md` → rewrite fresh lean (lihat 02-agent-spec).
- `AGENTS.md` lama → **tidak dipertahankan** (kontrak WWMA lama, diganti struktur baru).
