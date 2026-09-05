# 15 — Environment Manifest (Secrets, VPS, Akun Eksternal)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-51, D-65)
Dependensi dokumen: 07-config-inventory, 09-deployment-ops

---

## 1. Topologi & titik deployment

| Titik | Nilai |
|---|---|
| VPS | gamesim@82.25.62.204 (Tailscale ggl-vps 100.100.17.99) |
| Path | /opt/hiyuki (bersih, bukan /opt/wwma) |
| $HERMES_HOME | /home/gamesim/.hermes-hiyuki |
| DB | Tidak ada (SQLite state.db Hermes native) |
| LLM | MarketTabrak Router http://127.0.0.1:20228/v1 |

## 2. Env var (KEEP)

| Nama | Wajib | Sumber | Deskripsi |
|---|---|---|---|
| DISCORD_BOT_TOKEN | ya | .env.sops | Token bot Discord |
| GUILD_ID | ya | .env.sops | ID guild |
| CHANNEL_* | ya | .env.sops | ID 11 channel (#play + hiyuki-1..10) |
| HIYUKI_MARKETTABRAK_API_KEY | ya | .env.sops | API key router (single) |
| BRAVE_API_KEY | opsional | .env.sops | Brave search |

## 3. Env var (BUANG)

PAPYR_*, WWMA_SUISUI_*, 9ROUTER, GRAPH_EXTRACTION, EMBEDDING (Voyage), REDIS_URL, WWMA_API_TOKEN, WWMA_DASHBOARD_*, S3_*, CIRCUIT_BREAKER_*, MEMORY_INTEGRITY_HMAC_KEY, EPISODIC/REFLECTION, LEASE_*, GRAFANA/LANGFUSE/CLICKHOUSE/MINIO, HANDOFF_AUTH_KEY.

## 4. Secret & penyimpanan

- sops/age encryption (`.env.sops`).
- age key di `/etc/gamesim/age.key` (mode 600).
- OpenBao/Vault dipertahankan (D-65).
- Aturan: JANGAN commit secret plaintext; JANGAN paste key ke chat/git/log.

## 5. Akun eksternal

| Akun | Kredensial | Dibutuhkan mulai | Keterangan |
|---|---|---|---|
| Discord bot | DISCORD_BOT_TOKEN (existing) | F7 | Reuse existing bot (D-148), Message Content intent ON |
| DeepSeek API | via MarketTabrak Router | F3 | official api.deepseek.com |
| GitHub | fazulfi | F1 | repo hiyuki-agent |
| enowx-rag MCP | endpoint rag.zrouter.dev | F3 | TEI embedding |

## 6. Checklist kredensial per fase

- F1: GitHub remote.
- F3: semua .env.sops terisi.
- F7: Discord token aktif + Message Content intent ON + bot invited, router reachable.

## 7. Data live yang harus divalidasi saat build

- Router LLM reachable + model `hermes` → deepseek-v4-flash.
- enowx-rag endpoint reachable.
- 11 channel Discord ID valid.
- Message Content intent ON (privileged) + bot invited ke guild.

## 8. Definisi selesai

Semua env keep terisi, semua env buang dihapus, sops aktif, SF-01 (Voyage key) sudah di-rotate.
