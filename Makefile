# hiyuki-agent — developer convenience targets.
#
# The Hermes runtime is a separate pinned git dependency (decision D-86). The
# venv is created OUTSIDE the Hermes checkout (decision D-150 gotcha: a venv
# inside the checkout is at risk of being removed by the runtime).

# Pinned upstream reference. The exact commit SHA is fixed during phase F6.
HERMES_REF  ?= v0.21.0
HERMES_DIR  ?= ../hermes-agent
VENV        ?= .venv
PY          := $(VENV)/bin/python

.PHONY: help install lint format typecheck test clean

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

install: ## Clone pinned Hermes and install runtime into an out-of-tree venv
	@test -d "$(HERMES_DIR)" || git clone --depth 1 --branch "$(HERMES_REF)" \
		https://github.com/NousResearch/hermes-agent.git "$(HERMES_DIR)"
	uv venv "$(VENV)"
	cd "$(HERMES_DIR)" && uv venv --relocatable >/dev/null 2>&1 || true
	cd "$(HERMES_DIR)" && uv pip install -e ".[messaging,mcp]"
	uv pip install ruff mypy pytest

lint: ## Run ruff check and format check
	uv run ruff check .
	uv run ruff format --check .

format: ## Auto-format with ruff
	uv run ruff format .
	uv run ruff check --fix .

typecheck: ## Run mypy over plugin and test sources
	uv run mypy plugins tests scripts

test: ## Run the pytest suite
	uv run pytest

clean: ## Remove runtime state, caches, and the local venv
	rm -rf "$(VENV)" .pytest_cache .mypy_cache .ruff_cache
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	rm -f state.db state.db-wal state.db-shm