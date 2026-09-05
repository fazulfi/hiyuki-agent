# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Repository scaffold: README, license, contributing guide, security policy, and CI.
- Single-agent gateway configuration profile for Hiyuki (`config/config.yaml`).
- SOUL.md and OPS.md runtime persona and operational contract (retained from the pre-rebuild lineage).

## [0.1.0] - 2026-09

### Added

- Initial public-style repository structure for `hiyuki-agent`.
- Root-level governance files: LICENSE (BSD-3-Clause), SECURITY.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, CHANGELOG.md.
- Tooling: pyproject.toml (ruff / mypy / pytest), Makefile, and GitHub Actions CI.
- Hermes runtime wiring documented as a separate pinned git dependency (NousResearch/hermes-agent ~0.21.0).

[Unreleased]: https://github.com/fazulfi/hiyuki-agent/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fazulfi/hiyuki-agent/releases/tag/v0.1.0