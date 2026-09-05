# Hiyuki — Documentation

Canonical index of the spec suite and supplementary docs for the `hiyuki-agent`
repository (single-agent vanilla Hermes gateway).

## Single source of truth

- `docs/decisions.md` — the decision log (D-01..D-156, supersessions S-01..S-08,
  security flag SF-01). On any conflict between this file and the specs below,
  `decisions.md` wins.

## Spec suite (16 documents)

These are the accepted specs for the rebuild. They are authored primarily in
Indonesian (with technical terms in English); prose ordering per the master
index `docs/00-index.md`.

| Doc | Description |
|---|---|
| `docs/00-index.md` | Master index, traceability matrix, and acceptance gates for the entire spec suite. |
| `docs/01-vision-product.md` | Vision, identity, positioning, and the rationale for the rebuild. |
| `docs/02-agent-spec.md` | Persona, SOUL, autonomy boundary, role, and behaviour of Hiyuki. |
| `docs/03-architecture.md` | Vanilla Hermes + config + plugin topology. |
| `docs/04-llm-integration.md` | DeepSeek V4 via MarketTabrak router; no-refusal T2 prefix; DSML risk. |
| `docs/05-memory-rag.md` | enowx-rag TEI ingestion, retrieval, and retention. |
| `docs/06-discord-surface.md` | `#play` + `hiyuki-1..10` channels; natural language only, no slash commands. |
| `docs/07-config-inventory.md` | config.yaml, secrets, and MCP server inventory. |
| `docs/08-autonomy-boundary.md` | Zero red line and the accepted infrastructure self-harm risk. |
| `docs/09-deployment-ops.md` | Single systemd unit, backup, and monitoring (journald). |
| `docs/10-teardown-migration.md` | Archive the old repo, empty the DB, remove the 248-file custom app. |
| `docs/11-hermes-risk.md` | DSML, DeepSeek V4 quirks, and the risk register. |
| `docs/12-test-acceptance.md` | Acceptance gates and the test matrix. |
| `docs/13-roadmap.md` | Execution phases of the rebuild. |
| `docs/14-implementation-plan.md` | Step breakdown and file mapping. |
| `docs/15-environment-manifest.md` | Secrets, VPS, and external account inventory. |

## Supplementary docs

| Path | Description |
|---|---|
| `docs/adr/index.md` | Architecture decision record index — every decision grouped by category. |
| `docs/ops/runbook.md` | Operational runbook: backup, log review, restart, restore, rollback. |

## How to contribute docs

1. **Decision first.** New or changed decisions go to `docs/decisions.md` with a
   new `D#` (or an `S#` supersession), before any spec edit.
2. **One concern per doc.** Keep each numbered spec scoped to its topic; do not
   duplicate content across specs.
3. **Update the index.** After adding or removing a spec file, update the table
   in `docs/00-index.md` and this `docs/README.md` so the numbering and
   descriptions stay in sync.
4. **Record supersessions.** If a doc change reverses an earlier decision, add
   an `S#` row in `docs/decisions.md` and mark the superseded `D#` inline.
5. **English prose.** Documentation prose is English; the spec suite's internal
   language (Indonesian with English technical terms) is preserved for the
   specs themselves.
6. **No placeholders.** Files must not contain placeholder markers; write the
   final wording or leave the section out.