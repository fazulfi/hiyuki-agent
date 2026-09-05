# 06 — Discord Surface (#play + hiyuki-1..10, NL only)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-22, D-23, D-42..D-46, D-89)
Dependensi dokumen: 07-config-inventory

---

## 1. Channel

| Channel | ID (dari config VPS asli) | Keterangan |
|---|---|---|
| #play | <env:CHANNEL_PLAY> | channel utama |
| hiyuki-1 .. hiyuki-10 | (10 ID di config.yaml) | multi-chat pribadi |

- D-22: `#play` + `hiyuki-1..10` (total 11 channel).
- D-89: channel **hardcode di config.yaml**. Penambahan channel oleh Hiyuki (D-43) = update config + restart.
- `channel_directory.json` lama **dibuang**.

## 2. Mode interaksi

| Aspek | Nilai | Keputusan |
|---|---|---|
| Require mention | `false` | D-23 |
| Permukaan | NL only, **tanpa slash command** | D-22 |
| DM | **Skip** (bukan DM) | (design doc) |
| Operator-only | `allowed_users: [<env:OPERATOR_USER_ID>]` | D-03 |

## 3. Perilaku channel (D-42..D-46)

| Aspek | Nilai | Keputusan |
|---|---|---|
| Konteks antar-channel | **Per-channel** (transcript keyed per `channel_id`) | D-42 |
| Typing indicator | Aktif | D-44 |
| Pesan panjang | Auto-split (batch delay 0.6s, split delay 0.1s) | D-45 |
| Reaksi emoji | Aktif | D-46 |

## 4. Session key

- `agent:main:discord:group:<channel_id>:<user_id>`
- Transcript durable di SQLite `state.db`.
- Memory RAG global dibagi semua channel (D-37).

## 5. Allowlist operator (satu-satunya fitur custom tersisa)

- Operator Discord user ID = `<env:OPERATOR_USER_ID>` (Faiz).
- Ini satu-satunya gate yang dipertahankan (bersama Memory RAG) — lihat 08-autonomy-boundary.

## 6. Provisioning bot (G1)

1. Aplikasi bot Discord **reuse existing** (D-148) — TIDAK buat baru, TIDAK rotate token.
2. Pastikan **Message Content intent** (privileged) = **ON** — WAJIB karena `require_mention:false` (baca pesan tanpa mention).
3. Pastikan bot di-invite ke guild (guild sama, D-147) dengan scope `bot` + `messages.read`.
4. Token = `DISCORD_BOT_TOKEN` existing (di `.env.sops`).

## 7. Go-live smoke test (G9)

1. `hermes gateway start` → log journald tanpa error, koneksi Discord sukses.
2. Kirim pesan di `#play` → Hiyuki merespons (Bahasa Indonesia, persona).
3. Verifikasi tool-calling (minta Hiyuki jalankan `whoami` / list file).
4. Verifikasi RAG inject (minta Hiyuki recall fakta dari memory).
