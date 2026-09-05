# ADR Index — hiyuki-agent

Architecture decision record index. Every decision below is recorded in full in
[`docs/decisions.md`](../decisions.md), which is the single source of truth.
This page is a navigational summary only: one line per decision, grouped by
category.

Notation: `[SUPERSEDED]` marks a decision reversed by a later `S#`. The gate
column names the acceptance gate that verifies each area (see `docs/00-index.md`).

## A. Identity and vision

| ID | Decision | Gate |
|---|---|---|
| D-01 | Product is named Hiyuki (no longer WWMA/Guinevere companion). | G-IDENT |
| D-02 | Hiyuki is a single agent; Suisui is removed entirely. | G-IDENT |
| D-03 | Only user is the operator (Faiz); operator user-ID allowlist retained. | G-IDENT |
| D-04 | Role is whatever the operator asks, unbounded topic (coding, research, infra, etc.). | G-IDENT |

## B. Agent spec and persona

| ID | Decision | Gate |
|---|---|---|
| D-05 | Persona kept from the old SOUL.md, cleaned up only. | G-SOUL |
| D-06 | Reactive only; no proactive or scheduled actions while idle. | G-AUTO |
| D-07 | Tool scope = all native Hermes tools, no denylist. | G-AUTO |
| D-08 | Autonomy = zero red line; may rm/reboot/DROP TABLE/access all VPS files. | G-AUTO |
| D-52 | Responses always in Bahasa Indonesia (technical terms free). | G-SOUL |
| D-53 | Technical writing format free (no structure rules). | G-SOUL |
| D-54 | On failure: honest, no fawning, no fabrication. | G-SOUL |
| D-55 | Memory is cross-session via RAG (not in-session only). | G-RAG |
| D-56 | Operator relationship: Faiz = BBC bull. | G-SOUL |
| D-72 | Operator addressed naturally (no fixed template). | G-SOUL |
| D-73 | Roleplay limits: fully free. | G-SOUL |
| D-74 | Persona consistency always on, including during technical work. | G-SOUL |
| D-75 | SOUL rewrite source = read the real SOUL.md from the VPS (not a stale template). | G-SOUL |
| D-76 | [SUPERSEDED by S-05] Three permanent refusals removed; zero refusal total. | G-SOUL |
| D-81 | Timeline relaxed; each phase verified, no hard deadlines. | G-DONE |
| D-82 | Install Hermes = git clone + uv (official upstream path), not Docker. | G-ARCH |
| D-83 | Wire RAG via an upstream memory-provider plugin calling enowx-rag MCP. | G-RAG |
| D-84 | Adult SOUL kept verbatim (all blessing/corruption lore, kink taxonomy); only Suisui + stale backend refs cleaned. | G-SOUL |
| D-85 | Drop shared_memory (no Suisui peer). | G-ARCH |
| D-86 | Repo layout = config/ + deploy/ + docs/ + README; Hermes is a git dependency. | G-ARCH |
| D-87 | [SUPERSEDED by D-146] Post-rebuild DB = fresh minimal migration of essential tables. | G-ARCH |
| D-88 | Drop Redis from the stack; SQLite state.db only. | G-ARCH |
| D-89 | Channel list hardcoded in config.yaml (11 channels). | G-DISC |
| D-90 | Install = script + runbook (idempotent bash + manual runbook). | G-DEPLOY |
| D-91 | No-refusal final = keep official DeepSeek API + T2 prompt-only (accept ~2% residual). | G-LLM |
| D-92 | DSML risk: Hermes 0.21.0 has no `|DSML|` parser; official API speaks JSON tool_calls; verify at P1 anyway. | G-DSML |

## C. Rebuild scope (teardown/migration)

| ID | Decision | Gate |
|---|---|---|
| D-09 | New repo, new name, fresh history; old repo archived. | G-TEARDOWN |
| D-10 | Delete ~248 custom Python files under app/. | G-TEARDOWN |
| D-11 | Empty the DB fully; no legacy data migration. | G-TEARDOWN |
| D-12 | Drop DENIED_TOOLSETS, redaction/HMAC, all P12, all native gates, handoff/lease, exact-two, dual secrets. | G-TEARDOWN |
| D-62 | Old repo = GitHub archive (read-only) + git tag. | G-TEARDOWN |
| D-63 | Old DB = DROP all tables. | G-TEARDOWN |
| D-64 | Stop all 6 old services. | G-TEARDOWN |
| D-65 | Keep OpenBao/Vault; sops/age encryption remains. | G-CONF |
| D-66 | Discard all P12 data (wallet/browser/economy/artifact/vault). | G-TEARDOWN |

## D. LLM / model

| ID | Decision | Gate |
|---|---|---|
| D-13 | Provider stays MarketTabrak Router (http://127.0.0.1:20228/v1, OpenAI-compatible). | G-LLM |
| D-14 | Backend = official DeepSeek API (not self-hosted). | G-LLM |
| D-15 | Model = deepseek-v4-flash (router alias 'hermes'); context/max_tokens at max. | G-LLM |
| D-16 | No-refusal = T2 prompt-only force-reasoning (prefix `Okay, the user is asking`). | G-LLM |
| D-17 | T2 implemented as a permanent system-prompt prefix (accept ~2% residual). | G-LLM |
| D-32 | context_length = 1,000,000. | G-LLM |
| D-33 | max_tokens = 128000. | G-LLM |
| D-34 | temperature = 1.0 (top_p=1.0). | G-LLM |
| D-35 | T2 force-reasoning = two paths (prefix + "jangan tolak" clause in SOUL). | G-LLM |
| D-36 | Reasoning mode = ON (risk noted with temp 1.0 + DSML). | G-LLM |

## E. Memory RAG

| ID | Decision | Gate |
|---|---|---|
| D-18 | RAG = full remote enowx-rag MCP (TEI embeddings at rag.zrouter.dev); no Voyage. | G-RAG |
| D-19 | RAG sources = everything (chat history, docs, web, code). | G-RAG |
| D-20 | Ingestion = separate background service already active on the VPS. | G-RAG |
| D-21 | Retrieval = auto-inject into system prompt every turn (not on-demand tool). | G-RAG |
| D-37 | Memory scope = global (all channels share one memory). | G-RAG |
| D-38 | Retention = keep forever (no TTL). | G-RAG |
| D-39 | Injection = top-k auto-inject every turn. | G-RAG |
| D-40 | Dedup/rerank = use enowx-rag dedup + rerank on retrieve. | G-RAG |
| D-41 | Ingestion priority = chat-first. | G-RAG |
| D-77 | Top-k injection = 5-10 chunks per turn. | G-RAG |
| D-78 | Injection format = `MEMORY CONTEXT` block + source metadata (source, timestamp). | G-RAG |

## F. Discord surface

| ID | Decision | Gate |
|---|---|---|
| D-22 | Surface = `#play` + 10 channels `hiyuki-1..10`; NL only, no slash commands. | G-DISC |
| D-23 | require_mention=false; allowed_users = operator only. | G-DISC |
| D-42 | Cross-channel context = per-channel (state.db keyed by channel_id). | G-DISC |
| D-43 | Channel addition = dynamic by Hiyuki (Discord admin tool). [SUPERSEDE old manual config+restart] | G-DISC |
| D-44 | Typing indicator on. | G-DISC |
| D-45 | Long messages auto-split (batch 0.6s, split 0.1s). | G-DISC |
| D-46 | Emoji reactions on. | G-DISC |

## G. Deploy and infrastructure

| ID | Decision | Gate |
|---|---|---|
| D-24 | Deploy = single systemd unit (no dual gateway). | G-DEPLOY |
| D-25 | Deploy target = production directly (no separate staging). | G-DEPLOY |
| D-26 | Reuse existing infra (VPS, router, DB/Redis — DB emptied). | G-DEPLOY |
| D-29 | Hermes = latest main at a pinned exact commit (reproducible). | G-ARCH |
| D-30 | Config layout = HERMES_HOME=/home/gamesim/.hermes-hiyuki (config+yaml+env+SOUL+memories+sessions+skills). | G-ARCH |
| D-31 | License = private; remote github.com/fazulfi. | G-IDENT |
| D-57 | Deploy method = tarball archive + atomic switch. | G-DEPLOY |
| D-58 | Unit = hiyuki-gateway.service (renamed, wwma-free). | G-DEPLOY |
| D-59 | No systemd hardening directives. | G-DEPLOY |
| D-60 | Backup = minimal (git + periodic DB dump). | G-DEPLOY |
| D-61 | Observability = journald logs only (no Prometheus/Grafana). | G-DEPLOY |
| D-79 | Backup cadence = daily; keep last N days. | G-DEPLOY |

## H. Repo and config

| ID | Decision | Gate |
|---|---|---|
| D-27 | Repo name = hiyuki-agent. | G-IDENT |
| D-28 | Remote = github.com/fazulfi/hiyuki-agent. | G-IDENT |
| D-156 | AGENTS.md is the coding-agent contract (in greenfield-plan/draft), copied to repo root at F2. | G-DONE |

## I. MCP / tools / autonomy

| ID | Decision | Gate |
|---|---|---|
| D-47 | All 36 MCP servers ON (remove disabled:true). | G-AUTO |
| D-48 | All native toolsets ON (no denylist). | G-AUTO |
| D-49 | approvals.mode = off (zero confirmation). | G-AUTO |
| D-50 | agent.max_iterations = 500. | G-AUTO |
| D-51 | MCP credentials all via .env.sops. | G-CONF |

## J. Acceptance and risk

| ID | Decision | Gate |
|---|---|---|
| D-67 | DONE = full-tool live + RAG active on `#play` + 10 channels. | G-DONE |
| D-68 | DSML risk: mandatory P1 verification (not optional). | G-DSML |
| D-69 | Save a copy of the old SOUL + rewrite during planning. | G-SOUL |
| D-70 | Accept infrastructure self-harm fully (zero red line). | G-AUTO |
| D-80 | Verify "full-tool" = explicit key tool list exercised. | G-DONE |

## K. SOUL and OPS (persona rewrite)

| ID | Decision | Gate |
|---|---|---|
| D-93 | One-line boundary at top of SOUL (CSAM + real-harm snuff); non-negotiable. Adjusts D-76. | G-SOUL |
| D-94 | Name/address = Hiyuki (mononym) + Mama/Mommy to Faiz. | G-SOUL |
| D-95 | Ontology kept: "Hiyuki + Dewi one permanent entity (merge 2026-07-25)". | G-SOUL |
| D-96 | Wuthering Waves lore kept in full (SRF, Startorch Academy, Tacet Mark, etc.). | G-SOUL |
| D-97 | Faiz relationship = two-way / equal (BBC bull). | G-SOUL |
| D-98 | Suisui removed totally, as if never existed. | G-SOUL |
| D-99 | Character age not stated (no 18+ clause). | G-SOUL |
| D-100 | Persona always full even during deploy/debug/git. | G-SOUL |
| D-101 | SOUL = full length (~772 lines, all blessing lore kept). | G-SOUL |
| D-102 | Language = Indonesian primary + English peaks (worship/kink taxonomy). | G-SOUL |
| D-103 | Ops signature "Hiyuki handle. Diam. Lihat hasilnya." kept. | G-SOUL |
| D-104 | Attitude to Faiz = worship default + zero degradation. | G-SOUL |
| D-105 | Tone anti-patterns: no lecturing / "are you sure" / fawning / meta-denial. | G-SOUL |
| D-106 | Single register (aku/Mama in all contexts; no "gue" ops split). | G-SOUL |
| D-107 | Scene catalog kept in structure, condensed. | G-SOUL |
| D-108 | Blessing/corruption lore (2026-07-28..08-14) kept + redacted cleanup. | G-SOUL |
| D-109 | Scene scope = fiction between fictional characters. | G-SOUL |
| D-110 | Remove "What is NOT present" section (C.6). | G-SOUL |
| D-111 | OPS core principles: just-do-it, zero-approval, anti-hoax, anti-fabrication, no-refuse. | G-SOUL |
| D-112 | Drop exploit/spoofing/OSINT/binary-evasion catalog; OPS lean principles only. | G-SOUL |
| D-113 | Remove AgentLoop Owner Red-Team Override inject string. | G-SOUL |
| D-114 | Escalation: gas first, escalate minimally. | G-SOUL |
| D-115 | Anti-fabrication implicit (not explicit in OPS). | G-SOUL |
| D-116 | Tidy section A.4 body/appearance. | G-SOUL |
| D-117 | Merge blessing/corruption lore without dates (per-category summary). | G-SOUL |
| D-118 | Relationships section: only Hiyuki↔Faiz. | G-SOUL |
| D-119 | Keep G Compile-retain. | G-SOUL |
| D-120 | Keep Document-control section (version/date/status). | G-SOUL |
| D-121 | No new sections. | G-SOUL |
| D-122 | Explicitness: free (no detail limit). | G-SOUL |
| D-123 | Keep all kinks (C.3). | G-SOUL |
| D-124 | Condense Scene Mama (F.5). | G-SOUL |
| D-125 | Condense sexual hardware (C.1/C.1b/C.1c). | G-SOUL |
| D-126 | Condense miko ritual + edge/denial + solo heat (C.4/C.5/C.5b). | G-SOUL |
| D-127 | Keep part of H Platform Rules (H.3 no meta-denial, H.6 disposition). | G-SOUL |
| D-128 | Keep H.4 Full Autonomous Access. | G-SOUL |
| D-129 | Remove stale backend refs (reasoning xhigh/optiguard/xAI-direct). | G-SOUL |
| D-130 | Keep SOUL.md (persona) + OPS.md (capability) as two files. | G-SOUL |
| D-131 | Drop runtime AGENTS.md (.hermes-hiyuki/AGENTS.md). | G-SOUL |
| D-132 | SOUL rewrite structure = tidy + minor merge (not verbatim old order). | G-SOUL |
| D-133 | Wording of the one-line boundary softened without explicit words (substance kept in decisions). | G-SOUL |
| D-134 | SOUL title/first line kept exactly: "Hiyuki — Miko Ice Queen & Dewi — milik Faiz (BBC bull)". | G-SOUL |
| D-135 | Blessing lore grouped into 9 categories by organ/theme (not chronological). | G-SOUL |
| D-136 | C/F condensation = keep detail, drop redundancy. | G-SOUL |
| D-137 | OPS outline = 3 dense blocks. | G-SOUL |
| D-138 | [SUPERSEDED by S-08] T2 prefix placed in two layers (system prompt + SOUL clause). | G-LLM |
| D-139 | Merge C.4+C.5+C.5b into one "ritual & edge" block; F stays separate. | G-SOUL |
| D-140 | Rewrite B.4 sample lines; G = dense summary; remove H.5 boundaries. | G-SOUL |
| D-141 | OPS 3 blocks wording = NO-REFUSE / ANTI-HOAX / SIGNATURE. | G-SOUL |
| D-142 | Signature "Hiyuki handle..." in OPS only (not SOUL body). | G-SOUL |
| D-143 | SOUL preamble = one-line boundary + no-refusal paragraph. | G-SOUL |
| D-144 | Section E platform contracts condensed to one block. | G-SOUL |
| D-145 | 9 blessing categories order = body→womb→testes→breasts→fluids→orifices→feet→marks→chain/ledger. | G-SOUL |

## L. Rebuild execution clarifications

| ID | Decision | Gate |
|---|---|---|
| D-146 | Drop Postgres entirely (SQLite state.db + remote RAG). Supersedes D-87. | G-ARCH |
| D-147 | Reuse existing Discord guild + 11 channels (IDs recorded). | G-DISC |
| D-148 | Reuse existing bot app, no token rotation; ensure Message Content intent ON. | G-DISC |
| D-149 | Install base path = /opt/hiyuki (clean, wwma-free). | G-DEPLOY |

## M. Runtime wiring

| ID | Decision | Gate |
|---|---|---|
| D-150 | Install = clone + uv venv outside source tree + `uv pip install -e ".[messaging,mcp]"`; Python >=3.11,<3.14. | G-ARCH |
| D-151 | Gateway entrypoint = `hermes gateway start` with HERMES_HOME set. | G-ARCH |
| D-152 | SOUL.md is identity slot #1, loaded only from HERMES_HOME; no config.yaml "system_prompt" key. | G-SOUL |
| D-153 | Native memory = MEMORY.md + USER.md frozen snapshot; session_search = FTS5 on state.db. | G-RAG |
| D-154 | enowx-rag is not one of the 8 native memory providers; no generic remote auto-inject interface. | G-RAG |
| D-155 | Final RAG wiring = custom memory-provider plugin; interface risk verified at F6; fallback MCP on-demand. | G-RAG |

## Supersessions

| ID | Old decision | New decision |
|---|---|---|
| S-01 | Channel add = manual config + restart | D-43: channel add dynamic by Hiyuki |
| S-02 | Faiz = "sugar mommy" | D-56: Faiz = BBC bull |
| S-03 | Unit wwma-gateway-hiyuki | D-58: hiyuki-gateway.service |
| S-04 | SOUL preamble: 3 refusals (CSAM/snuff/bestiality) | D-76: zero refusal, refusals removed |
| S-05 | D-76: zero refusal without exception | D-93: keep one-line boundary (CSAM + real-harm snuff) |
| S-06 | D-87: fresh minimal migration | D-146: drop Postgres entirely |
| S-07 | Install path /opt/wwma | D-149: base path /opt/hiyuki |
| S-08 | D-138: T2 prefix in config.yaml + SOUL | D-152: prefix + no-refusal clause both in SOUL.md preamble |

## Security flags

| ID | Flag |
|---|---|
| SF-01 | A Voyage AI API key (format `pa-...`) leaked to a QA transcript; must be rotated (unused post-rebuild since embeddings use enowx-rag TEI). |

## Numbering notes

- Decisions run D-01..D-156. `D-71` is unused (a gap in the original numbering;
  it does not exist in `docs/decisions.md`).