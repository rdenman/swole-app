# 0003 — GitHub Actions CI on macos-26 / Xcode 26.5

- **Type:** tech
- **Status:** Accepted
- **Date:** 2026-07-18
- **Story:** S03
- **Requirements:** —

## Context

S03 requires automated build, unit + UI tests on a simulator, and lint/format on every change, with caching and PR failure on red. Local development already uses Xcode 26.5 and the iOS 18.0 deployment baseline (0001); S02 defined the lint commands CI must re-run.

## Decision

- Use **GitHub Actions** with workflow `.github/workflows/ci.yml`.
- Runner: **`macos-26`** (Apple Silicon), matching current `macos-latest` and local macOS/Xcode.
- Pin Xcode to **26.5** via `maxim-lobanov/setup-xcode` (same major as the README requirement; default on the image at adoption time).
- Split into two jobs: **lint** (SwiftLint + SwiftFormat) and **test** (XcodeGen → `xcodebuild test`).
- Resolve the simulator destination dynamically (prefer `iPhone 17`, fall back to any iPhone) so runtime/OS churn on the image does not hard-break the workflow.
- Cache Homebrew download caches and `build/DerivedData` for speed.
- Do **not** maintain a separate local `ci.sh` mirror — `.github/workflows/ci.yml` is the single source of truth; local checks use the documented lint/`xcodebuild` commands.

## Alternatives considered

- **`macos-15` only** — Still viable, but `macos-26` aligns with the local Xcode 26.5 toolchain and is the current Actions default path.
- **Single monolithic job** — Simpler YAML, but lint would wait on the longer `xcodebuild`; parallel jobs fail faster on style issues.
- **Hard-coded `OS=18.6` destination** — Matches CONTRIBUTING’s earlier local example, but GitHub images ship iOS 26.x simulators, not iOS 18. Deployment target 18.0 still builds/runs on newer simulators.
- **Skip XcodeGen in CI** — Faster, but would not catch `project.yml` drift from the checked-in `.xcodeproj`.
- **Shared `scripts/ci.sh` invoked by Actions and locally** — Avoids drift, but duplicates maintenance surface for a small pipeline; declined in favor of workflow-only.

## Consequences

- PRs and `main` pushes must stay green for merge confidence; red lint or tests fail the check.
- Bumping the pinned Xcode version is a deliberate follow-up when the team upgrades locally.
- SwiftFormat is used from the image when present; SwiftLint is installed via Homebrew in the lint job.
- Local preflight is manual (lint + `xcodebuild` per CONTRIBUTING), not a scripted CI clone.
