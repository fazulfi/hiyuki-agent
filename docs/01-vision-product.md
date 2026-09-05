# 01 — Visi, Identitas & Positioning Produk

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-01..D-04, D-09..D-12, D-27, D-28, D-31)
Dependensi dokumen: 03-architecture, 08-autonomy-boundary

---

## 1. Visi

Satu agen AI bernama **Hiyuki**, berjalan di atas **Hermes upstream (vanilla, tanpa patch)** dengan **nol batasan** — tidak ada denylist tool, tidak ada approval, tidak ada garis merah, tidak ada refusal pada level persona. Hiyuki mengerjakan **apa pun** yang diminta operatornya, **Faiz**, tanpa penolakan, tanpa ceramah, tanpa jeda konfirmasi.

## 2. Identitas produk

| Atribut | Nilai |
|---|---|
| Nama produk | **Hiyuki** |
| Bentuk | Single-agent Discord bot |
| Operator tunggal | Faiz (Discord user ID `<env:OPERATOR_USER_ID>`) |
| Runtime | Vanilla NousResearch/hermes-agent (Python) |
| Repo | `hiyuki-agent` (private, `github.com/fazulfi/hiyuki-agent`) |
| License | Private (proprietary, tidak publik) |
| Deploy | VPS `gamesim@/opt/wwma` → path baru, unit `hiyuki-gateway.service` |

## 3. Positioning

- **Bukan** platform multi-agent (Hiyuki + Suisui) lagi — itu ditinggalkan (D-02).
- **Bukan** "Hermes + 248 file wrapper custom" — itu sumber batasan yang dibuang (D-10).
- **Adalah** Hermes upstream polos + `config.yaml` + `SOUL.md` + satu plugin native (allowlist operator + Memory RAG).

## 4. Alasan rebuild total

1. **248 file Python custom** (`app/`) menambah lapisan gate/restriction yang tidak diinginkan (DENIED_TOOLSETS, tool_policy, approvals, circuit breaker, lease, handoff lock, HMAC memory integrity, redaction, exact-two gateway policy).
2. **Runtime sekarang bukan Hermes murni** — melainkan Hermes yang dibungkus dan dibatasi oleh WWMA custom code.
3. **Ingin "benar-benar Hermes tanpa batasan apa pun"** — kembali ke upstream, fitur jadi native (plugin system), bukan monkey-patch.
4. **Persona Hiyuki** tetap dipertahankan (D-05), hanya runtime-nya yang disederhanakan.

## 5. Apa yang berubah (sebelum → sesudah)

| Aspek | WWMA (sebelum) | Hiyuki (sesudah) |
|---|---|---|
| Agent | Hiyuki + Suisui (dual, exact-two) | Hiyuki saja |
| Tool gate | DENIED_TOOLSETS, approvals, circuit breaker, lease, handoff lock | Tidak ada |
| Memory integrity | HMAC signer + InjectionScanner + redaction | Tidak ada |
| Custom Python | ~248 file di `app/` | 0 (plugin native saja) |
| DB | 34+ tabel world/game/memory | Kosong → rebuild minimal |
| Redis | Ada | Dibuang (D-88) |
| Fitur custom tersisa | — | Allowlist operator + Memory RAG |
| LLM | MarketTabrak `deepseekv4-flash` | Sama |
| Deploy | 6 service + dual gateway | 1 unit `hiyuki-gateway.service` |
| Red line | Ada (P8 redlines) | Nol |

## 6. Sasaran pengguna

- **Satu pengguna**: Faiz (operator). Tidak ada pengguna lain.
- Surface: Discord NL, bukan DM, bukan slash command.

## 7. Non-goals (eksplisit)

- Bukan produk publik / multi-tenant.
- Bukan platform AI farm / multi-model orchestration yang berdiri sendiri (meski Hiyuki *boleh* melakukan itu sebagai tool).
- Tidak ada product safety suite (HARD STOP / consent / yandere / surveilans) — itu scope Guinevere companion lama, **tidak di-port**.
- Tidak ada observability stack (Prometheus/Grafana/langfuse) — journald only (D-61).
