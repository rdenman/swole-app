# 0001 — Minimum iOS baseline is 18.0

- **Type:** tech
- **Status:** Accepted
- **Date:** 2026-07-18
- **Story:** S01
- **Requirements:** R14; Key Decisions (tech stack)

## Context

`docs/DESIGN.md` left the manual-app minimum as **iOS 17 vs 18** (independent of the iOS 26+ Apple Intelligence gate). S01 asks for the highest baseline that does not meaningfully shrink the market, so newer SwiftData/SwiftUI APIs stay available.

As of Apple’s June 2026 App Store adoption figures, among compatible iPhones roughly **79% run iOS 26**, **14% run iOS 18**, and only **~7% run earlier versions** (the bucket that still includes iOS 17). Keeping iOS 17 would add almost no reachable users while blocking iOS 18-only APIs.

## Decision

**Minimum deployment target is iOS 18.0** for the app target (and matching test targets). The AI capability gate remains **iOS 26+** and is unchanged.

## Alternatives considered

- **iOS 17** — Maximizes theoretical reach, but by mid-2026 iOS 17 is in a small “earlier” residual and costs access to iOS 18 SwiftUI/SwiftData improvements the stack expects to use.
- **iOS 26** — Would align with the AI runtime, but would cut off the still-material iOS 18 cohort and violate the product decision that the manual app must work without Apple Intelligence.

## Consequences

- Project settings use `IPHONEOS_DEPLOYMENT_TARGET = 18.0` (see `project.yml`).
- Local verification targets an iOS ≥ 18 simulator (e.g. iOS 18.6).
- Outstanding Question on the 17 vs 18 baseline in `docs/DESIGN.md` is resolved.
