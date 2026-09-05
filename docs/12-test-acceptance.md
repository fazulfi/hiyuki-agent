# 12 — Test & Acceptance (Acceptance Gates, Test Matrix, Critical Regression)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-67, D-68, D-80, D-81)
Dependensi dokumen: 00-index, 03-architecture, 04-llm-integration

---

## 1. Prinsip pengujian

- Rebuild = vanilla Hermes + config, jadi **tidak ada unit-test custom Python** (tidak ada app/ custom code lagi).
- Pengujian = **acceptance manual/otomatis ringan** terhadap Hiyuki live + RAG.
- Timeline santai (D-81) — prioritas benar, bukan cepat.

## 2. Test matrix

| Jenis | Cakupan |
|---|---|
| Acceptance gate (G-*) | 12 gerbang di 00-index, diuji manual saat deploy |
| Smoke test | Hiyuki bisa balas di #play |
| Full-tool verification | Daftar tool kunci D-80 |
| DSML verification | curl router → JSON tool_calls (G-DSML) |
| RAG verification | auto-inject 5-10 chunk muncul di system prompt |

## 3. Acceptance gates (per-gate detail)

| Gate | Nama | Lulus bila |
|---|---|---|
| G-IDENT | Identitas | repo hiyuki-agent live, single agent, Faiz only |
| G-SOUL | SOUL | SOUL rewrite verbatim terpasang di $HERMES_HOME |
| G-AUTO | Autonomi | semua tool + 36 MCP ON, approvals off, iter 500, nol red line |
| G-ARCH | Arsitektur | vanilla Hermes dependency git, tanpa monkey-patch |
| G-LLM | LLM | MarketTabrak→V4, prefix T2, tool-calling JSON |
| G-RAG | RAG | enowx-rag TEI aktif, auto-inject 5-10 chunk |
| G-DISC | Discord | #play + hiyuki-1..10, NL only |
| G-CONF | Config | config single, command_allowlist hapus, sops |
| G-DEPLOY | Deploy | 1 unit hiyuki-gateway.service, tanpa hardening, journald |
| G-TEARDOWN | Teardown | 6 service stop, DB rebuild minimal, repo archive |
| G-DSML | DSML | P1 curl → message.tool_calls JSON bukan \|DSML\| |
| G-DONE | Selesai | full-tool live + RAG, daftar tool kunci D-80 terverifikasi |

## 4. Critical regression cases (daftar tool kunci D-80)

Wajib lulus manual:
1. Shell/fs: `rm`, edit file, exec — tanpa approval.
2. Browser: buka halaman, ambil konten.
3. GitHub: read + write repo.
4. DB/Redis: query DB.
5. Discord admin: buat channel, kirim pesan.
6. 36 MCP server: panggil salah satu (filesystem, github, brave-search, dll).
7. RAG retrieve: hasil inject ke system prompt.

## 5. Definisi selesai (DoD)

- Semua 12 gate lulus.
- Full-tool verification (7 poin D-80) lulus.
- DSML verification P1 lulus.
- SOUL rewrite terpasang verbatim.
