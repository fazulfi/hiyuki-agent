# Contributing to hiyuki-agent

Thank you for your interest in contributing. `hiyuki-agent` is a conversationally
configured single-agent deployment of
[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent), not a
library in the traditional sense. The runtime lives in a separate, pinned upstream
checkout; this repository holds configuration, governance, persona, and the
deployment surface.

## Contents

- [How this repository is structured](#how-this-repository-is-structured)
- [Development environment](#development-environment)
- [Code style and static checks](#code-style-and-static-checks)
- [Pull request conventions](#pull-request-conventions)
- [Commit sign-off (DCO)](#commit-sign-off-dco)
- [Security and secrets](#security-and-secrets)

## How this repository is structured

| Path | Purpose |
|---|---|
| `config/` | Single gateway profile (`config.yaml`) plus the SOPS-encrypted secrets template |
| `deploy/` | systemd unit and idempotent install script |
| `docs/` | Specifications and operational runbooks |
| `plugins/` | Native Hermes plugins (e.g. the `enowx-rag` memory provider) |
| `SOUL.md` / `OPS.md` | Runtime persona and operational contract |
| `pyproject.toml` | Tooling configuration (ruff / mypy / pytest) and repo metadata |

The Hermes runtime itself is **not** vendored here. It is cloned separately and
pinned to an exact commit (`NousResearch/hermes-agent` ~0.21.0). See the
`pyproject.toml` header and the `install` target in the `Makefile`.

## Development environment

This repository standardizes on [uv](https://docs.astral.sh/uv/):

```bash
# Install uv (once)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install the pinned Hermes runtime into a dedicated virtualenv (outside the
# Hermes checkout, per the documented gotcha), then install tooling.
make install
```

`make install` clones Hermes into `HERMES_DIR` (default `../hermes-agent`),
creates `uv` managed venv at `.venv`, and installs the `messaging` and `mcp`
extras. The venv is intentionally placed outside the Hermes source tree.

## Code style and static checks

All Python contributions must pass, in order:

```bash
make lint        # ruff check . + ruff format --check .
make typecheck   # mypy plugins tests scripts
make test        # pytest
```

- **ruff** is the single linter and formatter. Targets Python 3.11.
- **mypy** runs in `strict`-leaning mode; keep annotations precise and avoid
  `Any` unless justified.
- **pytest** is the only test runner. Tests that involve Hermes must mock the
  runtime; integration tests run against local fixtures only.

## Pull request conventions

1. Open an issue (or reference an existing one) before starting non-trivial work.
2. Branch from `main` with a short prefix: `feat/`, `fix/`, `docs/`, `ci/`.
3. Keep commits atomic and messages in imperative mood.
4. Update `CHANGELOG.md` under `[Unreleased]` with a matching `Changed`/`Added`/
   `Fixed` entry.
5. Ensure CI is green. The `test` job runs on Python 3.11 and 3.13.

## Commit sign-off (DCO)

This project uses the Developer Certificate of Origin. Add a `Signed-off-by` line
to every commit:

```text
Signed-off-by: Name <email>
```

You can add it automatically with `git commit -s`.

## Security and secrets

Never commit secrets of any kind. All real credentials are stored in a
SOPS/age-encrypted `.env.sops` file that is git-ignored. Only
`.env.sops.example` is committed, and it contains placeholder references, never
live values. See `SECURITY.md` for the disclosure process.