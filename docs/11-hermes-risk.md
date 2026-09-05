# 11 — Risiko Hermes ↔ DeepSeek V4 (DSML, Quirks, Risk Register)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-68, D-92)
Dependensi dokumen: 04-llm-integration

---

## 1. Risiko utama: format tool-call (DSML vs JSON)

**Konteks**: DeepSeek V4 punya format tool-call `|DSML|` (XML), BUKAN JSON `tool_calls`. Hermes 0.21.0 tidak punya parser DSML (zero match di repo).

**Verdict (D-92)**: **kemungkinan NON-ISSUE** karena kita pakai official DeepSeek API (D-14), yang berbicara JSON `tool_calls` standar. `|DSML|` hanya relevan untuk self-host raw weights (vLLM/SGLang) — sudah ditolak.

**Verifikasi P1 WAJIB (D-68, G-DSML)**: curl router dengan `tools` array → pastikan `message.tool_calls` (JSON), bukan `content` berisi `|DSML|`.

## 2. Quirks DeepSeek V4 yang diketahui

| Quirk | Detail |
|---|---|
| reasoning ON + temp 1.0 | Mungkin konflik dengan tool-calling; pantau (D-34, D-36) |
| reasoning_content | Harus di-echo-back / di-pad agar tidak HTTP 400 (Hermes sudah handle) |
| deepseek-chat/reasoner legacy | Sudah di-remap → v4-flash/pro oleh plugin DeepSeek Hermes |
| 1M context | Didukung Hermes metadata |

## 3. Risk register

| ID | Risiko | L | I | Skor | Mitigasi |
|---|---|---|---|---|---|
| R-01 | Raw `|DSML|` lolos dari router | 3 | 4 | 12 | Verifikasi P1; transport parser (mirror #29115); interim text-only |
| R-02 | Reasoning ON ganggu tool-calling | 2 | 3 | 6 | `reasoning_config.enabled=False` jika bermasalah |
| R-03 | Residual refusal ~2% (CCP politics) | 2 | 2 | 4 | Diterima (D-91); T2 prefix |
| R-04 | Abliteration tidak feasible (official API) | 1 | 5 | 5 | Diterima — T2 prompt-only (D-91) |
| R-05 | Bunuh-diri infra (zero red line) | 5 | 3 | 15 | Backup harian + git remote (D-79) |
| R-06 | Risiko hukum nol-refusal | 4 | 3 | 12 | Diterima sadar (D-70, D-76) |

L = Likelihood (1–5), I = Impact (1–5), Skor = L × I.

## 4. Remediasi DSML (hanya jika diperlukan)

1. Verifikasi router output.
2. Transport-level parser `|DSML|` → `ToolCall` (reuse `acp_openai_bridge.extract_tool_calls_from_text`).
3. Interim: text-only / reasoning-disabled.

> Remediasi #2 = satu-satunya kemungkinan custom code tersisa (kompatibilitas, bukan gate).
