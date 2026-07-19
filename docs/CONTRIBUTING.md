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
| `SwoleTests` | Unit / logic / snapshot tests (Swift Testing + SnapshotTesting) |
| `SwoleUITests` | UI / launch tests (XCTest) |

Shared harness pieces live under `SwoleTests/Helpers`, `SwoleTests/Fixtures`, and `SwoleUITests/Helpers` (see [Testing](#testing)).

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
# Build + test on any installed iOS ≥ 18 simulator
xcodebuild -project Swole.xcodeproj -scheme Swole \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test
```

List destinations with `xcodebuild -project Swole.xcodeproj -scheme Swole -showdestinations`. Any iOS ≥ 18 simulator is valid.

## Lint & format

Style is enforced with **SwiftLint** and **SwiftFormat** (configs: `.swiftlint.yml`, `.swiftformat`).

```bash
brew install swiftlint swiftformat   # once

# Check (must be clean; same bar as CI / pre-commit)
swiftlint lint --strict
swiftformat --lint .

# Auto-fix formatting
swiftformat .
```

### Pre-commit hook

Commits run lint/format on **staged** `.swift` files via `.githooks/pre-commit`. Enable once per clone:

```bash
./scripts/install-git-hooks.sh
```

That sets `core.hooksPath` to `.githooks`. Missing tools fail the commit with install instructions.

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs on every PR and on pushes to `main`:

1. **Lint & format** — `swiftlint lint --strict` and `swiftformat --lint .`
2. **Build & test** — regenerate the project with XcodeGen, then `xcodebuild test` (unit + UI) on an iOS Simulator

Use the local build/test and lint commands above for day-to-day work; the workflow is the source of truth for what CI runs.

## Testing

### Naming

- Unit / snapshot suites: `*Tests.swift` next to the area they cover (or under `SwoleTests/` until a feature folder exists).
- UI suites: `*UITests.swift` in `SwoleUITests/`.
- Test functions use a behavior-oriented name (`insertAndFetchSampleRecord`, not `test1`).

### Structure (Given / When / Then)

Prefer an explicit three-beat body with comments when the flow is non-trivial:

```swift
@Test func insertAndFetchSampleRecord() throws {
    // given
    let container = try InMemoryModelContainerFactory.make(for: [SampleRecord.self])
    let context = ModelContext(container)

    // when
    context.insert(SampleRecordFixtures.make())
    try context.save()

    // then
    let records = try context.fetch(FetchDescriptor<SampleRecord>())
    #expect(records.count == 1)
}
```

### Helpers

| Helper | Use for |
|--------|---------|
| `InMemoryModelContainerFactory` | Disposable SwiftData containers (`isStoredInMemoryOnly`) |
| `*Fixtures` builders | Deterministic sample models (fixed dates/names) |
| `DesignSystemSnapshots.assertComponent` | Design-system (and simple view) image snapshots |
| `XCUIApplication.launchForUITesting` | UI tests with `-ui-testing` + empty/seeded store args |

Launch arguments (app reads via `UITestLaunchArguments`):

| Argument | Meaning |
|----------|---------|
| `-ui-testing` | Running under UI automation |
| `-ui-testing-empty` | Prefer an empty store |
| `-ui-testing-seeded` | Prefer a seeded store |

### Snapshots

- Dependency: Point-Free [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) (linked only to `SwoleTests`).
- Use `DesignSystemSnapshots.assertComponent` so each component gets **light**, **dark**, and **accessibility ExtraExtraExtraLarge** variants (via `UITraitCollection`).
- Reference PNGs live beside the test file under `__Snapshots__/`. Commit them; re-record with `withSnapshotTesting(record: .all) { … }` (or `.failed`) when intentional UI changes land.
- Prefer a fixed layout canvas (not full-device chrome) so references stay stable across simulators.

## Conventions

- New UI belongs in `DesignSystem/` or a `Features/*` screen that consumes the design system — no ad-hoc colors/spacing.
- Story work follows `.cursor/skills/implement-story/`; requirements live in `docs/DESIGN.md`.
- Non-trivial tech/product/UX choices go in `docs/decisions/`.
