# 0004 — Testing harness (SnapshotTesting + fixtures)

- **Type:** tech
- **Status:** Accepted
- **Date:** 2026-07-18
- **Story:** S04
- **Requirements:** —

## Context
S04 requires an easy, consistent way to write unit, UI, and snapshot tests before design-system and SwiftData domain models land. We need a snapshot library, a strategy for component variants, reusable in-memory persistence helpers, and UI-test launch switches for empty vs seeded data.

## Decision
- Adopt **Point-Free SnapshotTesting** (`swift-snapshot-testing`, from **1.19.3**) as a `SwoleTests`-only SPM dependency.
- Standardize design-system snapshots via `DesignSystemSnapshots.assertComponent`, which always captures **light**, **dark**, and **accessibility ExtraExtraExtraLarge** on a fixed 390×200 canvas using `UITraitCollection` (so system colors and Dynamic Type resolve correctly under SnapshotTesting).
- Provide `InMemoryModelContainerFactory` and fixture builders under `SwoleTests/`; document Given/When/Then naming in `docs/CONTRIBUTING.md`.
- Drive UI-test data modes with process arguments `-ui-testing`, `-ui-testing-empty`, and `-ui-testing-seeded` (`UITestLaunchArguments` in the app; `XCUIApplication.launchForUITesting` in UI tests). Real seeding wires in with S09/S12; the harness only exposes the mode surface for now.

## Alternatives considered
- **iOSSnapshotTestCase (FBSnapshotTestCase)** — older UIKit-centric API; weaker SwiftUI ergonomics than SnapshotTesting.
- **Swift Testing–only image diffs / custom render** — more maintenance for no gain over a mature library.
- **Full-device snapshot layouts** — more brittle across simulators; deferred in favor of a fixed component canvas.
- **Environment variables instead of launch arguments** — launch arguments are the usual XCUITest pattern and show up clearly in process args.

## Consequences
- Snapshot PNGs under `__Snapshots__/` are committed and must be re-recorded when UI intentionally changes.
- CI uses the same simulator family as local runs; fixed layout reduces (but does not eliminate) cross-machine pixel drift.
- `SampleRecord` in `SwoleTests/Fixtures` is harness scaffolding and should be replaced by domain fixtures once S09 models exist.
- Resolved package version at build time: **1.19.3** (and its transitive Point-Free deps).
- SwiftLint `trailing_comma` is disabled so it does not fight SwiftFormat `--commas always`.
