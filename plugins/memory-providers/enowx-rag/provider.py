"""enowx-rag memory provider plugin for Hiyuki.

Interface contract status
-------------------------
Hermes upstream ships eight native memory providers (Honcho, OpenViking, Mem0,
Hindsight, Holographic, RetainDB, ByteRover, Supermemory). enowx-rag is not one
of them, and there is no generic, documented "HTTP/MCP memory provider"
interface that guarantees per-turn auto-injection of an external retrieval
(see decisions D-154 and D-155).

The exact Hermes memory-provider plugin contract (class shape, method names and
signatures, and whether a plugin may wrap a remote HTTP/MCP endpoint while still
participating in per-turn auto-injection) must be verified against the Hermes
source at install time (F6) before any real HTTP call is implemented.

This module is therefore a truthful skeleton only: it defines a top-level
provider class and a stable module surface, and each memory operation is
stubbed rather than a fabricated HTTP implementation against an unverified
interface.

Fallback path (documented in D-155): if the verified interface does not support
remote per-turn auto-injection, enowx-rag is exposed as an on-demand MCP tool
(``rag_retrieve_context`` / ``rag_semantic_search``), and SOUL guidance directs
Hiyuki to call it each turn when relevant.
"""

from __future__ import annotations

__all__ = ["ENowxRagMemoryProvider"]

REMOTE_HOST = "rag.zrouter.dev"
TOP_K_DEFAULT = 8


class ENowxRagMemoryProvider:
    """Memory provider backed by the remote enowx-rag service on rag.zrouter.dev.

    Retrieval returns the top-k (5..10) most relevant chunks and injects them
    per turn under a ``MEMORY CONTEXT`` block carrying source metadata (source,
    timestamp) so the provenance of every injected chunk can be verified (D-78).

    Embeddings are produced by the remote TEI service managed by enowx-rag; no
    local embedding model is used.
    """

    def __init__(self, *, top_k: int = TOP_K_DEFAULT) -> None:
        self.top_k = top_k

    async def store(self, content: str, *, metadata: dict | None = None) -> str:
        """Ingest a document or chunk into the remote RAG store.

        F6-gated: the wire call (HTTP vs MCP, auth, path) is defined only after
        the Hermes plugin interface is verified against source.
        """
        raise NotImplementedError(
            "enowx-rag store() requires the F6-verified Hermes memory-provider interface"
        )

    async def search(self, query: str) -> list[dict]:
        """Retrieve the top-k most relevant chunks for a query.

        F6-gated: the return shape matches the verified interface. Each result
        is expected to carry at least {text, source, timestamp} for the
        ``MEMORY CONTEXT`` block.
        """
        raise NotImplementedError(
            "enowx-rag search() requires the F6-verified Hermes memory-provider interface"
        )

    async def retrieve(self, query: str) -> list[dict]:
        """Alias of :meth:`search` kept for provider-convention compatibility."""
        return await self.search(query)

    def render_memory_context(self, chunks: list[dict]) -> str:
        """Render retrieved chunks into a ``MEMORY CONTEXT`` block with source
        metadata (source, timestamp) for per-turn injection (D-78)."""
        if not chunks:
            return ""
        lines = ["MEMORY CONTEXT"]
        for chunk in chunks:
            source = chunk.get("source", "unknown")
            timestamp = chunk.get("timestamp", "unknown")
            text = chunk.get("text", "")
            lines.append(f"- [{source} @ {timestamp}] {text}")
        return "\n".join(lines)