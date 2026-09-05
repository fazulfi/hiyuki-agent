# Security Policy

This document describes how security is handled for `hiyuki-agent` and how to
report a vulnerability.

## Supported versions

| Version | Supported |
|---|---|
| `main` (unreleased) | Yes |
| `0.1.x` | Yes |

The Hermes runtime is pinned to a specific upstream commit. Security fixes
upstream are picked up by advancing that pin and re-verifying; there is no
independent patch stream for upstream code.

## Responsible disclosure

If you discover a vulnerability, please report it privately rather than opening
a public issue. Contact the maintainer at the repository owner's contact points
listed in `README.md`.

Please include:

1. A description of the issue and its impact.
2. A minimal reproduction, including versions where relevant.
3. Proposed mitigation or fix, if available.

You can expect an initial response within seven days and a coordinated
disclosure once a fix is available. Do not publicly disclose a vulnerability
before a fix is shipped unless the maintainer is unresponsive after a
reasonable period.

## Secrets policy

All secrets are managed with **SOPS + age**:

- Real credentials live in `.env.sops`, encrypted with a dedicated age key at
  `/etc/gamesim/age.key` (mode `600`) on the VPS.
- Only `.env.sops.example` is stored in version control; it contains
  `${ENV_VAR}` references, never live values.
- Plaintext `.env` files, `*.sops` artifacts, and runtime state (`state.db`)
  are git-ignored.
- Secrets may never appear in commits, issues, pull requests, CI logs, or
  evidence artifacts.

If a secret is accidentally committed, treat it as compromised: rotate it and
purge the value from history rather than attempting to hide it.

## Threat model

`hiyuki-agent` is a single-operator, single-agent deployment. The primary
threats considered are:

| Threat | Mitigation |
|---|---|
| Secret exfiltration via commits or CI logs | SOPS/age encryption, git-ignored secrets, no secrets in CI |
| Unauthorized Discord access | Operator-only allowlist (`allowed_users`) on the gateway |
| Runtime state leakage (`state.db`) | Git-ignored, never shipped in release artifacts |
| Upstream supply chain compromise | Hermes pinned to an exact commit, reviewed on advance |
| Secret leakage from plaintext `.env` | `.env` and `.env.*` ignored; only encrypted or example files tracked |

The deployment intentionally grants the agent unrestricted local access on a
dedicated VPS. This is an accepted property of the design, documented in the
architecture and autonomy documents, not a bug to report.