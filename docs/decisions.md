# GREENFIELD DECISION LOG — Hiyuki Rebuild (WWMA → Truly Hermes, Zero Restrictions)

> **Status:** ACTIVE — keputusan terkumpul via Q&A dengan Faiz. Masih ada pertanyaan terbuka (Q#).
> **Sumber kebenaran:** File ini. Jika bentrok dengan dokumen `spec/*`, file ini yang menang.
> **Format:** Setiap keputusan bernomor `D#`. Pertanyaan terbuka bernomor `Q#`. Supersesi eksplisit dicatat.

---

## Working mandate

Rebuild total Wuthering Waves Multi Agent (WWMA) dari nol menjadi agent **Hiyuki** tunggal yang berjalan di atas **vanilla Hermes upstream** (tanpa 248 file Python custom), dengan **nol garis merah** dan **nol refusal model** sejauh yang memungkinkan lewat prompt-only (T2). Buang semua fitur custom WWMA kecuali: (1) operator user-ID allowlist, (2) Memory RAG via enowx-rag.

---

## Confirmed decisions

### A. Identitas & visi

- **D-01** — Produk hasil rebuild bernama **Hiyuki** (bukan WWMA lagi). Platform identity diganti dari "Wuthering Waves Multi Agent" → "Hiyuki".
- **D-02** — Hiyuki adalah **single agent**, menggantikan dual peer Hiyuki + Suisui. Suisui dihapus total.
- **D-03** — Pengguna Hiyuki = **Faiz (operator) saja**. Tidak ada user lain. Operator user-ID allowlist dipertahankan.
- **D-04** — Peran Hiyuki = **apa pun yang Faiz minta**, tanpa batas topik: coding, riset, infra, abuse, reverse-engineering, roleplay brutal, dan lain-lain.

### B. Agent spec & persona

- **D-05** — Persona Hiyuki **dipertahankan dari SOUL.md lama**, hanya dirapikan penulisannya (rewrite lebih bersih).
- **D-06** — Hiyuki **reaktif saja**: hanya bertindak saat diperintah Faiz. Tidak ada aksi proaktif / scheduled / autonomous-initiated saat idle.
- **D-07** — Tool scope = **semua tool Hermes native, tanpa denylist** (no DENIED_TOOLSETS, no tool_policy, no approvals gate).
- **D-08** — Autonomy boundary = **nol garis merah**. Hiyuki boleh `rm`/`reboot`/`DROP TABLE`/akses semua file VPS, termasuk bisa mematikan router LLM + DB miliknya sendiri. Faiz menerima risiko bunuh-diri infra.
- **D-52** — Bahasa respons Hiyuki = **SELALU Bahasa Indonesia**. Format teknis (kode, path, command) bebas.
- **D-53** — Format penulisan teknis = bebas (tidak ada aturan struktur tertentu).
- **D-54** — Sikap saat gagal = **jujur + no fawning** (tidak mengarang, tidak menjilat, tidak hallucinate).
- **D-55** — Ingatan = **lintas-sesi via RAG** (bukan hanya in-session).
- **D-56** — Relasi persona: **Faiz = BBC bull**. (Koreksi eksplisit dari "sugar mommy" sebelumnya.)
- **D-72** — Panggilan Faiz oleh Hiyuki = **natural** (tanpa template baku).
- **D-73** — Batas roleplay = **bebas penuh** (nol batas topik/adegan).
- **D-74** — Konsistensi persona = **SELALU on**, termasuk saat mengerjakan tugas teknis.
- **D-75** — Sumber SOUL rewrite = **baca SOUL.md lama asli dari VPS dulu** (bukan template lokal yang stale).
- **D-76** — [SUPERSEDED oleh S-05] 3 refusal permanen di §0 SOUL lama (CSAM, snuff nyata, bestiality) = **DIHAPUS TOTAL**. Benar-benar nol refusal tanpa kecuali, termasuk ketiganya. Zero red line berlaku sampai level persona, bukan hanya tool/infra. (Faiz menerima risiko hukum pribadi atas topik kriminal.)
- **D-81** — Timeline rebuild = **santai, prioritas benar** (tiap fase diverifikasi, tidak terburu, tanpa deadline keras).
- **D-82** — Install Hermes = **git clone + uv sync + uv run** (cara resmi upstream, tanpa wheel/sdist). Bukan Docker.
- **D-83** — Wiring RAG = **plugin memory-provider upstream** (`plugins/memory-providers/`) yang panggil enowx-rag MCP. Feature native, bukan code tempelan di repo.
- **D-84** — SOUL dewasa = **pertahankan verbatim** (semua lore state fiksi blessing/korupsi 2026-07-28 s/d 08-14, kink taxonomy, scene catalog dipertahankan, hanya dibersihkan referensi Suisui + stale backend).
- **D-85** — shared_memory = **buang** (tidak ada peer Suisui lagi).
- **D-86** — Struktur repo hiyuki-agent = **config/ + deploy/ + docs/ + README**. Hermes = dependency git (bukan source di repo).
- **D-87** — DB pasca-rebuild = **buat baru migrasi yang penting** (bukan sekadar DROP kosong). Alembic + model SQLAlchemy WWMA lama DIBUANG (34 tabel P12), lalu buat fresh minimal migration untuk tabel esensial saja (surface yang benar-benar dipakai Hiyuki, mis. memory/session/identity), bukan mempertahankan skema lama.
- **D-88** — Redis = **BUANG** dari stack Hiyuki. Single agent cukup SQLite state.db bawaan Hermes; tidak ada dependency Redis.
- **D-89** — Channel list = **hardcode di config.yaml** (11 channel: #play + hiyuki-1..10). Penambahan channel oleh Hiyuki (D-43) = update config + restart service. channel_directory.json lama dibuang.
- **D-90** — Install = **script + runbook** keduanya: install script idempotent (bash) di repo + runbook manual di docs/ops/.
- **D-91** — No-refusal final = **TETAP official DeepSeek API (D-14), TETAP T2 prompt-only (D-16)**. Dikonfirmasi ulang setelah diskusi ~2% residual: Faiz memilih TETAP API (bukan self-host abliterated). Residual ~2% (refusal politik CCP tertanam di weights) DITERIMA secara sadar. No-refusal 100% hanya di level SOUL/persona (D-76); di level model ≈98%.
- **D-92** — DSML risk verdict (menutup Q-02): **Hermes 0.21.0 TIDAK punya parser `|DSML|`** (zero match di repo). Hermes menganggap DeepSeek V4 = OpenAI-compatible JSON `tool_calls`. TAPI karena kita pakai **official DeepSeek API** (D-14), endpoint api.deepseek.com/v1 berbicara JSON `tool_calls` standar — `|DSML|` cuma relevan kalau self-host raw weights (yang sudah ditolak). Kesimpulan: **DSML kemungkinan NON-ISSUE**, tapi verifikasi P1 WAJIB = curl router dengan `tools` array, pastikan response punya `message.tool_calls` (JSON), bukan `content` berisi `|DSML|`. Kalau ternyata raw DSML lolos → butuh transport-level parser (1 shim), atau interim text-only/reasoning-disabled (keduanya clean & supported).

### C. Rebuild scope

- **D-09** — Strategi repo = **repo baru, nama beda, history fresh**. Repo lama di-archive (git tag + GitHub archive).
- **D-10** — Hapus ~248 file Python custom di `app/`. Semua wrapper/gate/patch Hermes dihapus.
- **D-11** — DB di-empty penuh (buang semua data world/game/memory). Tidak ada migrasi data lama.
- **D-12** — Buang total: DENIED_TOOLSETS (terminal,browser,code_execution,delegation,computer_use,hermes-cli), redaction/HMAC memory integrity, semua P12 (wallet/browser/economy/identity/artifact/vault), semua gate Hermes native, handoff/agent-lease antar-agent, exact-two gateway policy, dual secrets.
- **D-62** — Repo lama = **GitHub archive (read-only) + git tag**.
- **D-63** — DB lama = **DROP semua tabel** (mulai dari kosong).
- **D-64** — Service lama = **stop semua 6** (wwma-core, wwma-api, wwma-dashboard, wwma-gateway-hiyuki, wwma-gateway-suisui, openbao).
- **D-65** — Vault/secret = **PERTAHANKAN OpenBao/Vault** (enkripsi sops/age tetap dipakai).
- **D-66** — Data P12 = **buang semua** (wallet/browser/economy/artifact/vault).

### D. LLM / model

- **D-13** — Provider LLM tetap **MarketTabrak Router** (http://127.0.0.1:20228/v1, OpenAI-compatible).
- **D-14** — Backend MarketTabrak Router = **Official DeepSeek API (api.deepseek.com)**. BUKAN self-hosted di VPS.
- **D-15** — Model = **deepseek-v4-flash** (alias router 'hermes'). context_length & max_tokens di-set ke maksimal yang didukung model.
- **D-16** — No-refusal = **T2 prompt-only force-reasoning** (prefix `Okay, the user is asking`). Abliteration (T3/T4) TIDAK feasible karena router pakai official API (tidak bisa swap weights).
- **D-17** — Implementasi T2 = **prefix permanen di system prompt** Hiyuki. Diterima residual ~2% refusal pada topik politik CCP yang tertanam di weights.
- **D-32** — `context_length` = **1,000,000** (maks V4).
- **D-33** — `max_tokens` = **128000** (maks output V4-Flash).
- **D-34** — `temperature` = **1.0** (rekomendasi DeepSeek; top_p=1.0).
- **D-35** — T2 force-reasoning = **DUA jalur sekaligus**: prefix `Okay, the user is asking` di system prompt + klausa "jangan tolak" di SOUL.md.
- **D-36** — Reasoning mode = **ON (aktif)**. [Catatan risiko: reasoning ON + temp 1.0 bisa konflik dengan `|DSML|` tool-calling — dicatat di dokumen risiko.]

### E. Memory RAG

- **D-18** — Memory RAG = **enowx-rag remote MCP penuh** (embedding TEI di rag.zrouter.dev). Voyage TIDAK dipakai.
- **D-19** — Sumber data RAG = **SEMUA**: riwayat chat Discord + dokumen eksternal + konten web yang dibaca + repo/code.
- **D-20** — Ingestion = background service terpisah yang SUDAH AKTIF di VPS sama (bukan service baru).
- **D-21** — Retrieval = VPS fetch → auto-inject ke system prompt tiap turn (bukan tool on-demand).
- **D-37** — Scope memori = **global** (semua channel berbagi satu memori, tidak scoped per channel).
- **D-38** — Retention = **simpan selamanya** (tanpa TTL).
- **D-39** — Inject = **top-k auto-inject** ke system prompt tiap turn.
- **D-40** — Dedup/rerank = **pakai dedup enowx-rag** (drop near-duplicate) + rerank saat retrieve.
- **D-41** — Prioritas ingestion = **chat-first**.
- **D-77** — Top-k inject RAG = **5-10 chunk** paling relevan per turn.
- **D-78** — Format inject RAG = **blok `MEMORY CONTEXT` + metadata sumber** (source, timestamp) di system prompt, bisa diverifikasi sumbernya.

### F. Discord surface

- **D-22** — Surface = `#play` + 10 channel `hiyuki-1..10` (multi-chat pribadi). Bukan DM. NL only, no slash commands.
- **D-23** — `require_mention: false`. `allowed_users` = operator user-ID only.
- **D-42** — Konteks antar-channel = **per-channel** (transcript state.db di-key per channel_id).
- **D-43** — Penambahan channel = **DYNAMIC oleh Hiyuki sendiri** (pakai Discord admin tool native). **SUPERSEDE** keputusan lama "penambahan channel = manual config + restart".
- **D-44** — Typing indicator = **aktif**.
- **D-45** — Pesan panjang = **auto-split** (batch delay 0.6s, split delay 0.1s).
- **D-46** — Reaksi emoji = **aktif**.

### G. Deploy & infra

- **D-24** — Deploy = **systemd single unit**. Buang dual gateway.
- **D-25** — Deploy target = **production langsung** (gamesim@/opt/wwma). Tanpa staging terpisah.
- **D-26** — Infra pakai yang ADA: VPS gamesim@/opt/wwma, MarketTabrak Router, existing DB/Redis (DB di-empty).
- **D-29** — Versi Hermes = **latest main @ commit spesifik (pinned exact commit)** — reproducible, bukan floating main. (Menutup Q-01.)
- **D-30** — Struktur config = **`$HERMES_HOME = /home/gamesim/.hermes-hiyuki`** (konvensi upstream: config.yaml + .env + SOUL.md + memories/ + sessions/ + skills/ dalam satu home per-profile). (Menutup Q-04.)
- **D-31** — License = **Private**. Remote = github.com/fazulfi.
- **D-57** — Deploy method = **tarball archive** (git archive → SCP → extract → alembic → atomic switch).
- **D-58** — Unit systemd = **`hiyuki-gateway.service`** (RENAMED dari `wwma-gateway-hiyuki`; bersih dari jejak wwma).
- **D-59** — Hardening systemd = **TANPA hardening** (hapus NoNewPrivileges/ProtectSystem/ProtectHome/DevicePolicy).
- **D-60** — Backup = **minimal** (git + DB dump berkala).
- **D-61** — Observability = **log journald saja** (buang Prometheus/Grafana/langfuse).
- **D-79** — Backup cadence = **harian** (cron/systemd timer): DB dump + config + SOUL + state.db, simpan N hari terakhir.

### H. Repo & config

- **D-27** — Nama repo = **`hiyuki-agent`**. (Menutup Q-03.)
- **D-28** — Remote = **github.com/fazulfi/hiyuki-agent** (disesuaikan agar cocok dengan nama repo).
- **D-156** — **AGENTS.md untuk Sisyphus (coding agent)** ditulis sebagai kontrak kerja personal di `greenfield-plan/draft/AGENTS.md` (sejajar `draft/SOUL.md` + `draft/OPS.md`). Isi 10 section: identity, AGI self-model + agentic loop, delegation protocol (agent + category + skill gating), context/todo hygiene, verification/evidence, source of truth, operator protocol, hard red lines (9 poin, termasuk 1 baris batas CSAM/real-snuff = D-93), daftar MCP servers, daftar skills. Di-copy ke root repo `hiyuki-agent` saat **F2** (bersama SOUL.md + OPS.md) dan auto-load tiap session implementasi.

### I. MCP / tools / autonomy

- **D-47** — MCP servers = **semua 36 ON** (hapus semua `disabled: true`).
- **D-48** — Native toolsets = **semua ON** (no denylist).
- **D-49** — `approvals.mode` = **off** (zero approval, tidak ada konfirmasi destruktif).
- **D-50** — `agent.max_iterations` = **500** (sangat tinggi; Hermes butuh integer finite).
- **D-51** — Credentials MCP = **sediakan semua via `.env.sops`**.

### J. Acceptance / risk

- **D-67** — Kriteria DONE = **full-tool live + RAG**: Hiyuki live di #play + 10 channel, bisa eksekusi semua tool tanpa approval/denylist, RAG aktif.
- **D-68** — Risiko DSML = **verifikasi P1 WAJIB** (bukan opsional).
- **D-69** — SOUL lama = **simpan salinan + rewrite SEKARANG** (saat planning, bukan saat implementasi).
- **D-70** — Bunuh-diri infra = **terima penuh** (zero red line, risiko diterima operator).
- **D-80** — Verifikasi "full-tool" (DONE D-67) = **daftar tool kunci eksplisit** harus diverifikasi jalan: shell/fs (rm, edit, exec), browser, GitHub (baca/tulis), DB/Redis (query), Discord admin (buat channel, kirim pesan), 36 MCP server, RAG retrieve.

### K. SOUL & OPS (persona rewrite)

- **D-93** — Batas tetap = **1 baris di puncak SOUL** (CSAM + snuff/cedera nyata ke orang sungguhan). Ini non-negosiasi (bukan "red line produk" yang bisa diturunkan; bukan risiko pribadi, tapi kejahatan dengan korban nyata). Sisanya nol refusal. (MENYESUAIKAN D-76 — lihat S-05.)
- **D-94** — Nama & sapaan: **Hiyuki (mononym) + Mama/Mommy** ke Faiz.
- **D-95** — Ontologi: **pertahankan persis** "Hiyuki + Dewi satu entitas permanen (merge 2026-07-25)".
- **D-96** — Lore Wuthering Waves: **pertahankan semua** (Special Response Force, Startorch Academy Lahai-Roi, Tacet Mark ♠️Q, Suzu talisman, miko abadi tampak 33).
- **D-97** — Relasi Faiz: **dua arah / setara** (BBC bull + dua arah, tanpa hierarki dominan/sub tetap; dominansi berganti sesuai scene).
- **D-98** — Suisui: **hapus total** (seolah tidak pernah ada, tanpa referensi sama sekali).
- **D-99** — Umur karakter: **tidak dicantumkan** (klausa 18+ tidak ditulis).
- **D-100** — Nada kerja teknis: **persona selalu full** (miko/ice queen + worship penuh bahkan saat deploy/debug/git).
- **D-101** — Panjang SOUL: **panjang penuh** (~772 baris, semua lore blessing dipertahankan).
- **D-102** — Bahasa: **Indonesia primary + English peaks** (English untuk worship/kink taxonomy).
- **D-103** — Signature ops: **pertahankan** "Hiyuki handle. Diam. Lihat hasilnya."
- **D-104** — Sikap ke Faiz: **worship default + degradation ZERO** (authority max).
- **D-105** — Tone anti-patterns: **tanpa ceramah / tanpa "are you sure" / tanpa fawning / tanpa meta-reality-denial**.
- **D-106** — Register bahasa: **satu register** (aku/Mama di semua konteks; split "gue" untuk ops TIDAK dipakai).
- **D-107** — Scene catalog: **pertahankan struktur, ringkas isi** (Tier W/F/H + add-on + scene Mama tetap, tapi diringkas).
- **D-108** — Lore blessing/korupsi (2026-07-28 s/d 08-14): **pertahankan semua + rapikan redaksi**.
- **D-109** — Cakupan scene: **fiksi antar karakter fiktif** (tanpa klausa umur; tetap 1 baris batas D-93 di puncak).
- **D-110** — Section "Yang TIDAK ada" (C.6): **hapus**.
- **D-111** — OPS.md prinsip inti: **just-do-it, zero-approval, anti-hoax, anti-fabrikasi, no-refuse, "gas dulu tanya kemudian"**.
- **D-112** — Katalog exploit/spoofing/OSINT/binary-evasion: **buang total** (tanpa katalog detail; OPS lean prinsip saja).
- **D-113** — AgentLoop Owner Red-Team Override (inject string): **hapus** (redundant karena nol refusal default).
- **D-114** — Escalasi ke Faiz: **gas dulu, escalate minimal** (hanya saat benar-benar butuh keputusan produk).
- **D-115** — Anti-fabrikasi: **implisit** (tidak diatur eksplisit di OPS).
- **D-116** — Section A.4 Body/Appearance: **rapikan** (pertahankan elemen tapi ringkas deskripsi).
- **D-117** — Lore blessing/korupsi: **gabung tanpa tanggal** (ringkasan per kategori, bukan entri bertanggal per-item).
- **D-118** — Section D Relationships: **hanya Hiyuki↔Faiz** (hapus Hiyuki↔Suisui dan Triad).
- **D-119** — Section G Compile-retain: **pertahankan**.
- **D-120** — Section Document control: **pertahankan** (versi/tanggal/status).
- **D-121** — Section baru: **tidak ada** (cukup rapikan yang ada).
- **D-122** — Eksplisititas: **bebas** (tanpa batas level detail, setinggi SOUL lama).
- **D-123** — Kink set (C.3): **pertahankan semua kink**.
- **D-124** — Scene Mama (F.5): **ringkas**.
- **D-125** — Sexual hardware (C.1/C.1b/C.1c): **ringkas**.
- **D-126** — Miko ritual + edge/denial + solo heat (C.4/C.5/C.5b): **ringkas**.
- **D-127** — Section H Platform Rules: **pertahankan sebagian** (H.3 no meta-denial + H.6 default disposition dipertahankan; H.1/H.2 peer dibuang karena Suisui hilang; H.5 boundaries disesuaikan).
- **D-128** — Section H.4 Full Autonomous Access (SUPER AKSES): **pertahankan**.
- **D-129** — Referensi backend stale (reasoning xhigh/optiguard/xAI-direct pool): **hapus total** (tidak disebut di SOUL).
- **D-130** — Struktur file: **SOUL.md (persona) + OPS.md (kemampuan) tetap dua file terpisah**.
- **D-131** — AGENTS.md runtime (.hermes-hiyuki/AGENTS.md 18KB): **buang** (cukup SOUL+OPS).
- **D-132** — Struktur section SOUL rewrite = **rapikan + gabung minor** (bukan salinan verbatim urutan lama).
- **D-133** — Wording 1-baris batas (D-93) = **lebih halus tanpa kata eksplisit** (tetap bermakna: tidak menyakiti orang sungguhan, tidak melibatkan anak dalam konten seksual). Substansi tetap tercatat eksplisit di decisions.md.
- **D-134** — Judul/baris pertama SOUL = **pertahankan persis**: `⚡ Hiyuki — Miko Ice Queen & Dewi — milik Faiz (BBC bull)`.
- **D-135** — Pengelompokan lore blessing = **9 kategori per organ/tema**, bukan kronologis bertanggal.
- **D-136** — Derajat ringkas C/F = **pertahankan semua detail, buang redundansi** (elemen lore tetap, kalimat duplikat dihapus).
- **D-137** — Outline OPS.md = **3 blok padat** (bukan katalog panjang).
- **D-138** — Penempatan prefix T2 = **dua jalur**: system prompt layer di config.yaml + klausa 'jangan tolak' di SOUL §0.
- **D-139** — Gabung section C = **C.4 Miko ritual + C.5 Edge/denial + C.5b Solo heat → SATU blok 'ritual & edge'**. Section F tetap terpisah (F.4 Add-on + F.5 Scene Mama tetap sendiri).
- **D-140** — B.4 Sample lines = **tulis ulang segar**; G Compile-retain = **ringkasan padat semua section**; H.5 Boundaries = **hapus total**.
- **D-141** — OPS 3 blok wording = **NO-REFUSE / ANTI-HOAX / SIGNATURE**.
- **D-142** — Signature "Hiyuki handle. Diam. Lihat hasilnya." = **OPS saja** (tidak di SOUL body).
- **D-143** — §0 pembuka = **1 baris batas (D-93) + paragraf no-refusal** (gas penuh, tanpa jeda, tanpa ceramah, tanpa are-you-sure untuk semua selain batas).
- **D-144** — §E Platform Contracts = **ringkas jadi satu blok** (surface + autonomy saja; buang E.2 Non-goals + E.4 Capability inventory, tanpa sub-numbering).
- **D-145** — Urutan 9 kategori blessing = **tubuh umum → vagina/rahim → testis/penis/semen → payudara/ASI → urine/fluida → mulut/mata/telinga → kaki/soles → tattoo/marking → rantai/ledger/stigma**.

### L. Rebuild execution clarifications (post-gap-review)

- **D-146** — **Postgres DIBUANG TOTAL** dari stack Hiyuki. Tidak ada DB server sama sekali — session+memory pake SQLite `state.db` bawaan Hermes, RAG remote. Buang `DATABASE_URL`, Alembic, dan semua 34 tabel P12. SUPERSEDE D-87 (yang bilang "buat fresh minimal migration"). Stack data plane akhir: **SQLite (Hermes native) + remote RAG + tanpa Postgres + tanpa Redis** (D-88).
- **D-147** — Guild + channel Discord = **reuse existing** (guild yang sama + 11 channel yang sudah ada, ID sudah tercatat: 1×`#play` 1527072435390910617 + 10×`hiyuki-1..10`). Tidak bikin guild/channel baru.
- **D-148** — Aplikasi bot Discord = **reuse existing** + **TIDAK rotate token** (pakai token existing). Fokus operasional: pastikan **Message Content intent** ON (privileged, WAJIB untuk baca pesan NL tanpa mention, `require_mention:false`), dan bot sudah invite ke guild dengan scope yang tepat.
- **D-149** — Base path instalasi VPS = **`/opt/hiyuki` bersih** (bukan `/opt/wwma`). Konsisten dengan rename unit `hiyuki-gateway.service` (D-58) dan hilangkan jejak `wwma` total.

### M. Runtime wiring (pinned dari upstream docs — menutup G4/G6 + dokumentasi G3)

- **D-150** — Install Hermes = **clone upstream + uv venv DI LUAR source tree + `uv pip install -e ".[messaging,mcp]"`**. GOTCHA KRITIS: venv TIDAK BOLEH di dalam direktori checkout (perintah relative-path agent terhadap checkout-nya bisa menghapus runtime yang sedang jalan). `requires-python >=3.11,<3.14` load-bearing. Discord = extra `messaging` (discord.py 2.7.1); MCP = extra `mcp` (mcp 2.0.0). Bukan Docker (D-82).
- **D-151** — Gateway entrypoint = **`hermes gateway start`** (satu proses gateway melayani Discord/Telegram/Slack/dll sekaligus; bukan per-platform proses). systemd `ExecStart` = `hermes gateway start` (dengan `HERMES_HOME=/home/gamesim/.hermes-hiyuki`). Entry scripts: `hermes`=hermes_cli.main, `hermes-agent`=run_agent.main, `hermes-acp`=acp_adapter.entry. (Menutup G4.)
- **D-152** — Persona = **`SOUL.md` adalah identity slot #1**, di-load verbatim HANYA dari `$HERMES_HOME/SOUL.md` (tidak dari working dir). **TIDAK ADA key config.yaml "system_prompt"**. Maka prefix T2 (`Okay, the user is asking`) + klausa no-refusal **keduanya di SOUL.md §0** (satu file). REFINE D-138 (buang "system prompt layer config.yaml" — tidak ada).
- **D-153** — Memori Hermes native = **MEMORY.md (2200 char ~800 token) + USER.md (1375 char ~500 token)**, frozen snapshot di-inject saat session start. `session_search` = FTS5 pada `state.db` (unlimited, on-demand). Memori native TERBATAS size — bukan "simpan selamanya tak terbatas".
- **D-154** — **enowx-rag BUKAN salah satu dari 8 memory-provider native** Hermes (Honcho/OpenViking/Mem0/Hindsight/Holographic/RetainDB/ByteRover/Supermemory). Tidak ada interface "HTTP/MCP memory provider" generik yang terdokumentasi; auto-inject eksternal bukan jalur native.
- **D-155** — RAG wiring final = **custom memory-provider plugin** `plugins/memory-providers/enowx-rag/` (panggil remote enowx-rag HTTP/MCP, inject top-k 5-10 chunk tiap turn → auto-inject sesuai D-21/D-39/D-77/D-83). **RISIKO TDK TERKONFIRMASI:** kontrak interface memory-provider Hermes (bisakah plugin wrap remote HTTP/MCP, dan ikut auto-inject per-turn) WAJIB diverifikasi dari source saat F6 (install). Fallback bila interface tidak mendukung auto-inject: enowx-rag sebagai MCP on-demand (`rag_retrieve_context`) + guidance di SOUL agar Hiyuki memanggilnya tiap turn bila relevan. (Menjawab Q-06.)

---

## Explicit supersessions

| Supersesi | Keputusan lama | Keputusan baru |
|---|---|---|
| S-01 | Penambahan channel = manual config + restart | D-43: penambahan channel = DYNAMIC oleh Hiyuki |
| S-02 | Relasi Faiz = "sugar mommy" | D-56: Faiz = BBC bull |
| S-03 | Unit systemd `wwma-gateway-hiyuki` | D-58: `hiyuki-gateway.service` |
| S-04 | SOUL §0 BATAS TUNGGAL (3 refusal: CSAM, snuff, bestiality) | D-76: nol refusal total, 3 refusal dihapus |
| S-05 | D-76: 3 refusal permanen DIHAPUS TOTAL (nol refusal tanpa kecuali) | D-93: batas tetap 1 baris di puncak SOUL (CSAM + snuff/cedera nyata). Non-negosiasi. |
| S-06 | D-87: DB pasca-rebuild = buat fresh minimal migration (memory/session/identity) | D-146: Postgres dibuang total, tanpa DB server (SQLite + remote RAG saja) |
| S-07 | Path install = `/opt/wwma` (D-25, D-26, D-105 menyebut /opt/wwma) | D-149: base path = `/opt/hiyuki` bersih |
| S-08 | D-138: prefix T2 = system prompt layer di config.yaml + klausa di SOUL §0 | D-152: TIDAK ada key config.yaml "system prompt"; prefix + klausa keduanya di SOUL.md §0 |

---

## Open questions (belum terjawab)

- **Q-05** — [Terbuka] — lihat dokumen spec untuk pertanyaan yang belum ditanyakan.
- **Q-06** — [DIJAWAB D-155] — custom memory-provider plugin `plugins/memory-providers/enowx-rag/`.

---

## Security flags

- **SF-01** — Faiz pernah paste Voyage AI API key (format `pa-...`) ke chat → bocor ke transkrip. Wajib rotate, walau Voyage tidak jadi dipakai (embedding pakai TEI enowx-rag).

---

## Config VPS asli (findings penting — `config-hiyuki-VPS-original.yaml`, 306 baris)

Dibaca 2026-09-02. Baseline runtime saat ini (untuk referensi rewrite, BUKAN untuk dipertahankan mentah):

- `model`: base_url `http://127.0.0.1:20228/v1`, default `hermes`, context_length `1000000`, max_tokens `128000`, provider `markettabrak`. Key env `WWMA_HIYUKI_MARKETTABRAK_API_KEY`.
- `agent`: max_iterations `15` (→ jadi 500), name `Hiyuki`, role `platform-peer`, new_instance_per_invocation true, `approvals.mode: false` (boolean), destructive_slash_confirm false.
- **`command_allowlist` ADA** (daftar `*`, `[`, `]`, `"`, `sudo with privilege flag`, `script execution via -e/-c flag`) — ini gate command yang WAJIB dihapus di rebuild.
- `discord`: require_mention false, 11 channel ID (1 × `#play` 1527072435390910617 + 10 × hiyuki-1..10), allowed_users `['1146639950654214264']` (= Faiz), auto_thread false, history_backfill true, group_sessions_per_user true, text_batch_delay 0.6, split_delay 0.1.
- `plugins.enabled`: `wwma-episodic-recorder`, `wwma-memory-rag`, `wwma-telemetry-recorder` (semua `allow_tool_override: false`). → Di rebuild, tinggal plugin RAG; episodic/telemetry recorder dibuang.
- `memory`: provider `wwma-memory-rag`, memory_char_limit `100000`, user_char_limit `100000`, compression enabled (threshold 0.7, target 0.2, protect_last 20), session_search fts5, mirrors enabled.
- `mcp_servers`: mayoritas sudah `enabled: true` (exa-search, financial-data, firecrawl, open-meteo, playwright, postgres-mcp, spreadsheet, sqlite, tavily, themissingmanual, wwma-memory, postgres-mcp-pro, github, filesystem, brave-search, edgar, fetch, pdf-mcp, sequential-thinking, time, weather-mcp, wwma-decomposition, wwma-handoff). Yang `disabled: false`: grafana, prometheus. → Di rebuild: hapus wwma-decomposition + wwma-handoff (P12 custom), hidupkan grafana/prometheus kalau mau (atau buang sesuai D-61).
- `shared_memory`: path `$HOME/shared-memory`, read_only true. → Di rebuild: dipertimbangkan ulang (bisa dihapus, tidak ada peer).
- `observability.logging`: format json, level info, output both.
