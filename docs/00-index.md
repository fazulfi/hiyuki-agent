# 00 — Index, Traceability Matrix & Acceptance Gates

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord (vanilla Hermes, zero restriction)
Bahasa: Indonesia (istilah teknis English)
Referensi keputusan: ../decisions.md (D-01 s/d D-156)
Dependensi dokumen: seluruh spec 01–15

---

## 1. Tujuan dokumen

Dokumen ini adalah peta navigasi untuk seluruh `greenfield-plan/spec/`. Ia menjelaskan:

1. Struktur 16 dokumen spec dan perannya masing-masing.
2. Sumber kebenaran tunggal (`decisions.md`) dan aturan resolusi konflik.
3. Traceability matrix: setiap keputusan inti → dokumen spec → acceptance gate.
4. Gerbang penerimaan (acceptance gates) yang harus lulus sebelum rebuild dinyatakan selesai.
5. Status kelengkapan tiap dokumen.

---

## 2. Struktur dokumen

| ID | Dokumen | Peran |
|---|---|---|
| 00 | index.md | Master index, traceability, acceptance gates |
| 01 | vision-product.md | Visi, identitas, positioning, alasan rebuild |
| 02 | agent-spec.md | Persona, SOUL, autonomy, role, perilaku |
| 03 | architecture.md | Vanilla Hermes + config + plugin, topologi |
| 04 | llm-integration.md | DeepSeek V4 via MarketTabrak, no-refusal T2, DSML |
| 05 | memory-rag.md | enowx-rag TEI, ingestion, retrieval, retention |
| 06 | discord-surface.md | #play + hiyuki-1..10, NL only |
| 07 | config-inventory.md | config.yaml + secrets + MCP servers |
| 08 | autonomy-boundary.md | Zero red line, risiko bunuh-diri infra |
| 09 | deployment-ops.md | systemd single unit, backup, monitoring |
| 10 | teardown-migration.md | Archive repo lama, kosongkan DB, hapus 248 file |
| 11 | hermes-risk.md | DSML, V4 quirks, risk register |
| 12 | test-acceptance.md | Acceptance gates + test matrix |
| 13 | roadmap.md | Fase eksekusi |
| 14 | implementation-plan.md | Step breakdown + file |
| 15 | environment-manifest.md | Secrets, VPS, akun eksternal |

---

## 3. Sumber kebenaran

**`../decisions.md` adalah sumber kebenaran tunggal.**

- Jika ada konflik antara `decisions.md` dan dokumen spec manapun → **`decisions.md` menang.**
- Dokumen spec adalah *elaborasi* keputusan, bukan pengganti keputusan.
- Perubahan keputusan ditulis dulu di `decisions.md` (D# baru atau S# supersession), baru spec di-update.

---

## 4. Traceability matrix

| Area keputusan | Keputusan inti | Dokumen spec | Acceptance gate |
|---|---|---|---|
| Identitas produk | D-01 (nama Hiyuki), D-02 (single agent), D-03 (Faiz only) | 01 | G-IDENT |
| Persona & SOUL | D-05, D-52..D-56, D-72..D-76, D-84 | 02 | G-SOUL |
| Autonomy & red line | D-06, D-07, D-08, D-47..D-51, D-76 | 08 | G-AUTO |
| Arsitektur runtime | D-10, D-12, D-29, D-30, D-82..D-86 | 03 | G-ARCH |
| LLM provider | D-13..D-17, D-32..D-36, D-91, D-92 | 04 | G-LLM |
| Memory RAG | D-18..D-21, D-37..D-41, D-77, D-78, D-83, D-153..D-155 | 05 | G-RAG |
| Discord surface | D-22, D-23, D-42..D-46, D-89 | 06 | G-DISC |
| Config & secrets | D-47..D-51, D-65, config VPS findings | 07 | G-CONF |
| Deploy & ops | D-24..D-26, D-57..D-61, D-79, D-90, D-149..D-151 | 09 | G-DEPLOY |
| Teardown & migrasi | D-09, D-62..D-66, D-88, D-146 | 10 | G-TEARDOWN |
| Risiko Hermes↔V4 | D-68, D-92 | 11 | G-DSML |
| Penerimaan akhir | D-67, D-80 | 12 | G-DONE |

---

## 5. Gerbang penerimaan (acceptance gates)

| Gate | Nama | Lulus bila |
|---|---|---|
| G-IDENT | Identitas | Repo `hiyuki-agent` live, single agent Hiyuki, hanya Faiz (1146639950654214264) yang bisa pakai |
| G-SOUL | Persona | SOUL.md rewrite verbatim (persona Hiyuki lama, referensi Suisui + backend stale dibersihkan) terpasang |
| G-AUTO | Autonomy | Semua tool Hermes native + 36 MCP ON, approvals off, max_iterations 500, nol garis merah |
| G-ARCH | Arsitektur | Vanilla Hermes (bukan 248 file app/) berjalan sebagai dependency git, tanpa monkey-patch |
| G-LLM | LLM | MarketTabrak → DeepSeek V4 Flash, prefix T2 terpasang, tool-calling JSON jalan |
| G-RAG | Memory | enowx-rag TEI aktif, auto-inject `MEMORY CONTEXT` 5–10 chunk tiap turn |
| G-DISC | Discord | #play + hiyuki-1..10 live, require_mention false, NL only, no slash |
| G-CONF | Config | config.yaml single profile, command_allowlist dihapus, secrets via .env.sops |
| G-DEPLOY | Deploy | Satu unit `hiyuki-gateway.service` aktif, tanpa hardening, journald only |
| G-TEARDOWN | Teardown | 6 service lama stop, Postgres lama DROP (tanpa replacement), repo lama archive+tag |
| G-DSML | DSML | Verifikasi P1: curl router dengan `tools` array → `message.tool_calls` JSON, bukan `|DSML|` |
| G-DONE | Selesai | Full-tool live + RAG aktif (daftar tool kunci D-80 terverifikasi semua) |

---

## 6. Status kelengkapan

- [x] 00 index
- [x] 01 vision-product
- [x] 02 agent-spec
- [x] 03 architecture
- [x] 04 llm-integration
- [x] 05 memory-rag
- [x] 06 discord-surface
- [x] 07 config-inventory
- [x] 08 autonomy-boundary
- [x] 09 deployment-ops
- [x] 10 teardown-migration
- [x] 11 hermes-risk
- [x] 12 test-acceptance
- [x] 13 roadmap
- [x] 14 implementation-plan
- [x] 15 environment-manifest
- [x] draft/SOUL.md (persona Hiyuki rewrite)
- [x] draft/OPS.md (kemampuan/ops, langsung gas)
- [x] draft/AGENTS.md (kontrak coding agent Sisyphus — **copy ke root repo `hiyuki-agent` saat F2**; lihat D-156)

---

## 7. Open questions & security flags (pointer)

- **Q-05** (generic): ditutup saat implementasi dimulai (lihat `decisions.md`).
- **SF-01**: Voyage API key (format `pa-...`) bocor ke transkrip saat sesi Q&A. **Wajib di-rotate.** Rebuild TIDAK memakai Voyage (embedding pakai enowx-rag TEI), tapi key yang bocor tetap harus dinonaktifkan.
