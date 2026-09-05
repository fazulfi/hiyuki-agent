# 05 — Memory RAG (enowx-rag, TEI, Ingestion, Retrieval, Retention)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-18..D-21, D-37..D-41, D-77, D-78, D-83)
Dependensi dokumen: 03-architecture

---

## 1. Penyedia embedding & RAG

| Aspek | Nilai | Keputusan |
|---|---|---|
| RAG server | enowx-rag remote MCP (`rag.zrouter.dev/mcp`) | D-18 |
| Embedding | TEI (Text Embeddings Inference) | D-18 |
| Voyage AI | **TIDAK dipakai** (Voyage key bocor, SF-01) | D-18 |
| Embedding dim | native TEI (bukan 2048 Voyage) | D-18 |

## 2. Sumber data (D-19)

Ingest **semua** sumber:
1. Riwayat chat Discord (Hiyuki ↔ Faiz).
2. Dokumen eksternal (file, dokumen yang dibaca).
3. Konten web yang dibaca Hiyuki.
4. Repo / code yang dikerjakan.

## 3. Ingestion (D-20, D-41)

- **Background service terpisah** yang **sudah aktif di VPS yang sama** (bukan service baru).
- Prioritas ingestion: **chat-first** (riwayat chat didahulukan).

## 4. Retrieval (D-21, D-39, D-40, D-77, D-78)

- **Auto-inject ke system prompt tiap turn** (bukan tool on-demand).
- Top-k = **5–10 chunk** per turn.
- Dedup: enowx-rag drop near-duplicate.
- Rerank: enowx-rag rerank pada retrieve.
- Format inject (D-78): blok `MEMORY CONTEXT` + metadata sumber (source, timestamp) — verifiable.

Format contoh:

```
MEMORY CONTEXT
[source: discord#hiyuki-3, timestamp: 2026-09-01T...]
<chunk>

[source: repo:hiyuki-agent/..., timestamp: ...]
<chunk>
```

## 5. Scope & retention (D-37, D-38)

- Scope: **global** — semua channel berbagi satu memory (tidak scoped per channel).
- Retention: **simpan selamanya** (tanpa TTL).

## 6. Wiring (D-83)

- Plugin memory-provider **native upstream** (`plugins/memory-providers/enowx-rag/`).
- Bukan code tempelan / monkey-patch.
- Hermes native memory (`memories/`) tetap berjalan berdampingan; RAG = lapisan lintas-sesi jangka panjang.

## 7. Integrasi dengan session

- Session transcript: SQLite `state.db` Hermes, keyed per `channel_id` (D-42).
- RAG memory global dibagi semua channel (D-37), tidak scoped.
