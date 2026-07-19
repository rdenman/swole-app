# Contributing to Swole

## Project layout

Source lives under `Swole/`, grouped by responsibility (not by file type):

| Folder | Role |
|--------|------|
| `App/` | App entry point, root scene, and top-level composition |
| `DesignSystem/` | Tokens, theme, and reusable UI primitives (Phase 0) |
| `Data/` | SwiftData models, persistence, seeding, CloudKit wiring |
| `Domain/` | Pure domain types and rules (e.g. progression) with no UI |
| `Features/` | Feature modules (templates, active workout, history, AI chat, …) |
| `Support/` | Cross-cutting helpers (formatting, identifiers, logging) |
| `Resources/` | Asset catalogs and bundled resources |

Tests:

| Target | Role |
|--------|------|
| `SwoleTests` | Unit / logic tests (Swift Testing) |
| `SwoleUITests` | UI / launch smoke tests (XCTest) |

## Platform baseline

- **Minimum iOS:** 18.0 (see `docs/decisions/` and `docs/DESIGN.md`)
- **Language:** Swift 6 with **strict concurrency** (`SWIFT_STRICT_CONCURRENCY=complete`)
- **UI:** SwiftUI lifecycle

## Regenerating the Xcode project

The checked-in `Swole.xcodeproj` is generated from [`project.yml`](../project.yml) via [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen   # once
xcodegen generate
```

Prefer editing `project.yml` (targets, settings, deployment target) over hand-editing the `.pbxproj`.

## Local build & test

```bash
# Build + test on an iOS 18 simulator (matches the deployment baseline)
xcodebuild -project Swole.xcodeproj -scheme Swole \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' \
  test
```

List destinations with `xcodebuild -project Swole.xcodeproj -scheme Swole -showdestinations`. Any iOS ≥ 18 simulator is valid.

## Conventions

- New UI belongs in `DesignSystem/` or a `Features/*` screen that consumes the design system — no ad-hoc colors/spacing.
- Story work follows `.cursor/skills/implement-story/`; requirements live in `docs/DESIGN.md`.
- Non-trivial tech/product/UX choices go in `docs/decisions/`.
