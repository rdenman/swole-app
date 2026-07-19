# 0002 — Lint/format via committed configs + git pre-commit

- **Type:** tech
- **Status:** Accepted
- **Date:** 2026-07-18
- **Story:** S02
- **Requirements:** —

## Context

S02 requires SwiftLint + SwiftFormat with committed configs, integrated as a build phase and/or pre-commit so style violations fail locally before CI (S03).

Xcode build-phase linting slows every compile and often races or warns when tools are missing. Pre-commit runs only on commit, on staged Swift files, which matches the “fail locally” acceptance bar without taxing day-to-day builds.

## Decision

- Commit `.swiftlint.yml` and `.swiftformat` at the repo root.
- Enforce via **git pre-commit** (`.githooks/pre-commit`), enabled per clone with `./scripts/install-git-hooks.sh` (`core.hooksPath=.githooks`).
- Do **not** add an Xcode Run Script build phase for lint/format in this story.
- Install tools with Homebrew (`swiftlint` 0.65.0, `swiftformat` 0.62.1 at time of adoption); document check/fix commands in `docs/CONTRIBUTING.md`.
- CI (S03) will re-run the same `swiftlint lint --strict` and `swiftformat --lint .` checks on the full tree.

## Alternatives considered

- **Xcode build phase only** — Catches issues earlier in the edit loop, but slows every build and is awkward when tools are not installed; declined for the initial integration.
- **Both build phase and pre-commit** — Redundant for MVP; can add a build phase later if the team wants in-IDE feedback.
- **pre-commit.com / Lefthook** — Extra stack for two shell commands; a committed bash hook is enough.

## Consequences

- New clones must run `./scripts/install-git-hooks.sh` (or set `core.hooksPath`) and install Homebrew tools, or commits with Swift changes will fail.
- Formatting auto-fixes stay manual (`swiftformat .`); the hook only **lints**.
- S03 should invoke the same CLI commands documented in CONTRIBUTING.
