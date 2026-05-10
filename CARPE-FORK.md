# Carpe fork notice

This repository is a security-reviewed fork of [`U-C4N/Autocad-MCP`](https://github.com/U-C4N/Autocad-MCP) maintained as part of the [Carpe](https://carpe.work) connector catalog.

## What's different from upstream

Upstream code lives in this fork unchanged. The Carpe-specific additions are confined to:

- [`carpe-fork/run.cmd`](carpe-fork/run.cmd) — the launcher Carpe spawns the connector through.
- [`carpe-fork/build.ps1`](carpe-fork/build.ps1) — the build script that produces a portable Windows zip.
- [`.github/workflows/security-and-build.yml`](.github/workflows/security-and-build.yml) — security gates (Endor SCA + SAST + secrets, TruffleHog) and the release pipeline.
- This file.

Everything else — `server.py`, `backends/`, `engineering/`, `security.py`, `pyproject.toml`, the upstream's tests and docs — is upstream code at the pinned tag noted below. We don't patch upstream.

## Pinned upstream

| Field | Value |
|---|---|
| Upstream repo | `U-C4N/Autocad-MCP` |
| Upstream tag | (no tag — upstream doesn't tag releases; pinning by commit SHA) |
| Forked at commit | `bf952cfbcd9f7bc95187fd2b09fd0ffe3c5b0c45` |
| Upstream server reports | AutoCAD MCP Pro 3.2.4 |
| Last reviewed | 2026-05-10 (preliminary; final sign-off pending CI green) |

Upgrading to a new upstream version is a deliberate PR into this fork's `main`, not a passive pull. The PR re-runs the security gates (CI) and re-triggers manual review against the [security review checklist](https://github.com/EasyCCapp/EasyCC/blob/dev/docs/carpe/architecture/connector-security-review.md) at the catalog repo.

## Distribution

Releases on this fork (`v*` tags) are picked up by Carpe's catalog system via signed `catalog.json`. The SHA-256 of each release artifact is captured at build time and embedded in `catalog.json`; the desktop app verifies bytes before running the connector.

## Reporting issues

For **security issues** in this fork's additions or in the build pipeline: open a security advisory on this repo.

For **issues in the underlying AutoCAD MCP code**: report upstream at [`U-C4N/Autocad-MCP`](https://github.com/U-C4N/Autocad-MCP). We track upstream and pull fixes through deliberate PRs.

For **how the connector behaves in Carpe** (UI, approval gates, scoping): report at [`EasyCCapp/EasyCC`](https://github.com/EasyCCapp/EasyCC).

## License

Inherits the upstream project's license. The Carpe-specific additions in `carpe-fork/` and `.github/workflows/security-and-build.yml` are released under the same license unless otherwise noted.
