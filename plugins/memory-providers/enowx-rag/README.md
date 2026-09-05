# enowx-rag memory provider plugin

Custom Hermes memory-provider plugin that wires Hiyuki's cross-session memory to
the remote **enowx-rag** service (TEI embeddings) at `rag.zrouter.dev`, per
decisions D-18..D-21, D-37..D-41, D-77, D-78, and D-155.

## Purpose

- Retrieve the top-k (5..10) most relevant chunks per turn.
- Inject them every turn under a `MEMORY CONTEXT` block carrying source metadata
  (source, timestamp) so the provenance of each injected chunk is verifiable.

Embeddings are produced remotely by enowx-rag; no local embedding model is used.
Voyage is out of scope (see security flag SF-01 in `docs/decisions.md`).

## Interface status (F6 verification)

Hermes upstream ships eight native memory providers (Honcho, OpenViking, Mem0,
Hindsight, Holographic, RetainDB, ByteRover, Supermemory). enowx-rag is **not**
one of them, and there is no generic, documented "HTTP/MCP memory provider"
interface guaranteeing per-turn auto-injection of an external source
(decisions D-154, D-155).

The exact Hermes memory-provider plugin contract (class shape, method names and
signatures, and whether a plugin may wrap a remote HTTP/MCP endpoint while still
participating in per-turn auto-injection) **must be verified against the Hermes
source at install time (F6)**.

For this reason `provider.py` is a **truthful skeleton only**: it defines the
top-level provider class and its stub surface (`store` / `search` /
`retrieve`), but does not fabricate an HTTP implementation against an
unverified interface.

## Fallback (documented in D-155)

If the verified interface does not support remote per-turn auto-injection,
enowx-rag is exposed as an on-demand MCP tool
(`rag_retrieve_context` / `rag_semantic_search`), and SOUL guidance directs
Hiyuki to call it each turn when relevant.

## Files

| Path | Description |
|---|---|
| `provider.py` | `ENowxRagMemoryProvider` skeleton with stubbed `store`/`search`/`retrieve`. |