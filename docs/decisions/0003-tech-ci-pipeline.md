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
- Pin Xcode to **26.5** via `maxim-lobanov/setup-xcode` (same major as the README requirement).
- After selecting Xcode, run `xcrun simctl list > /dev/null` to warm CoreSimulator (common fix when destinations are missing right after `xcode-select`).
- Split into two jobs: **lint** (SwiftLint + SwiftFormat) and **test** (XcodeGen → `xcodebuild test`).
- Use a simple destination: `platform=iOS Simulator,arch=arm64,name=iPhone 17` (matches devices on current `macos-26` images; `arch` avoids the arm64/x86_64 dual-match warning).
- Cache Homebrew download caches and `build/DerivedData` for speed.
- Do **not** download iOS platforms in CI, probe multiple Xcodes, or maintain a separate local `ci.sh` — `.github/workflows/ci.yml` is the single source of truth; local checks use the documented lint/`xcodebuild` commands.

## Alternatives considered

- **Probe multiple Xcodes for preinstalled sims** — More resilient when one pin lacks devices, but overbuilt vs common community practice; declined for trim CI.
- **`xcodebuild -downloadPlatform iOS` when missing** — Reliable, but can add many minutes; declined to keep CI fast.
- **`macos-15` only** — Still viable, but `macos-26` aligns with the local Xcode 26.5 toolchain and is the current Actions default path.
- **Single monolithic job** — Simpler YAML, but lint would wait on the longer `xcodebuild`; parallel jobs fail faster on style issues.
- **Hard-coded `OS=18.6` destination** — Matches CONTRIBUTING’s earlier local example, but GitHub images ship iOS 26.x simulators, not iOS 18. Deployment target 18.0 still builds/runs on newer simulators.
- **Dynamic destination resolution / UDID pick** — Useful under heavy image churn; unnecessary while `iPhone 17` is listed on the runner image.
- **Skip XcodeGen in CI** — Faster, but would not catch `project.yml` drift from the checked-in `.xcodeproj`.
- **Xcode Cloud** — Apple’s recommended CI product; deferred while the repo standardizes on GitHub Actions for lint + test.

## Consequences

- PRs and `main` pushes must stay green for merge confidence; red lint or tests fail the check.
- Bumping the pinned Xcode or simulator name is a deliberate follow-up when the team upgrades locally or the image drops that device.
- If the image lacks iPhone 17 (or CoreSimulator is still empty after the warm step), the job fails; fix by updating the pin/destination or (as a last resort) downloading the platform.
- SwiftFormat is used from the image when present; SwiftLint is installed via Homebrew in the lint job.
- Local preflight is manual (lint + `xcodebuild` per CONTRIBUTING), not a scripted CI clone.
