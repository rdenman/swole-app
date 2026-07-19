# Swole — MVP Stories

Ordered, self-contained implementation backlog to take Swole from empty repo to an **App Store submission-ready** MVP that includes the full manual experience **and** on-device Apple Intelligence generation + coaching.

**Source of truth:** all requirement IDs (e.g. `R9`, `AE1`) reference [`ARCHITECTURE.md`](../ARCHITECTURE.md). Read the relevant requirements before starting a story.

## How to use this file

- Stories are listed in **implementation order**. Complete them top to bottom; a story's dependencies are always above it.
- Each story is **self-contained**: an independent agent should be able to pick it up using only the story plus the referenced requirement IDs.
- **Mark progress** by editing the checkbox: `- [ ]` → `- [x]`. Update the status line in the Milestones table when a phase completes.
- **Testing bar (applies to every story):** ship unit tests for logic; critical user flows also get UI tests. A story is not "done" until its tests pass in CI (once CI exists, S03).
- **Definition of Done (per story):** acceptance criteria met, tests passing, lint/format clean, no new accessibility regressions, and any new UI built from the design system (no ad-hoc components).

## Milestones

| Phase | Theme | Stories | Status |
|-------|-------|---------|--------|
| 0 | Foundation & tech initiatives | S01–S14 | Not started |
| 1 | Exercises & catalog | S15–S17 | Not started |
| 2 | Templates | S18–S21 | Not started |
| 3 | Active workout & timers | S22–S31 | Not started |
| 4 | History | S32–S34 | Not started |
| 5 | Training-history summary | S35 | Not started |
| 6 | AI generation & coaching | S36–S43 | Not started |
| 7 | Sync, privacy & App Store | S44–S51 | Not started |

---

## Phase 0 — Foundation & tech initiatives

> Front-loaded so all feature work sits on a sound, consistent base. No feature story should begin before Phase 0 is complete.

### S01 — Project scaffold & platform baseline
- [ ] **Status**
- **Goal:** Create the Xcode project and lock foundational technical choices.
- **Depends on:** —
- **Requirements:** R14; Key Decisions (tech stack); Outstanding Questions (iOS baseline)
- **Scope:**
  - Create the iOS app project (SwiftUI lifecycle), bundle id, and app target.
  - **Decide and record the minimum iOS baseline (17 vs 18)** for the manual app in `ARCHITECTURE.md` (the iOS 26 AI gate is separate). Recommend the highest baseline that doesn't meaningfully shrink the market, to unlock newer SwiftData/SwiftUI APIs.
  - Enable **Swift 6 strict concurrency**.
  - Establish folder/module structure (e.g. `App`, `DesignSystem`, `Data`, `Features/*`, `Domain`, `Support`), documented in a short `docs/CONTRIBUTING.md` or README section.
  - Add unit-test and UI-test targets.
- **Acceptance:**
  - Project builds and runs an empty app on the chosen minimum-iOS simulator.
  - Baseline decision written into `ARCHITECTURE.md` (replacing the Outstanding Question).
  - Strict concurrency enabled with zero warnings.
- **Tests:** A trivial passing unit test in the unit-test target; a smoke UI test that launches the app.

### S02 — Linting & formatting
- [ ] **Status**
- **Goal:** Enforce consistent style automatically.
- **Depends on:** S01
- **Scope:**
  - Add SwiftLint + SwiftFormat with a committed config.
  - Integrate as a build phase and/or pre-commit; document the local command.
- **Acceptance:** `swiftlint` and `swiftformat --lint` run clean on the repo; violations fail locally.
- **Tests:** N/A (tooling); verified by running the linters in CI (S03).

### S03 — CI pipeline
- [ ] **Status**
- **Goal:** Automated build + test + lint on every change.
- **Depends on:** S01, S02
- **Scope:**
  - GitHub Actions workflow: resolve deps, build, run unit + UI tests on a simulator, run lint/format checks.
  - Cache derived data/deps for speed; fail PRs on any red.
- **Acceptance:** A PR runs the workflow; green on a clean branch, red when a test/lint fails.
- **Tests:** The workflow itself executing the existing test suite.

### S04 — Testing harness & fixtures
- [ ] **Goal:** Make writing unit, UI, and snapshot tests easy and consistent.
- **Depends on:** S01
- **Scope:**
  - Add a snapshot-testing dependency; configure a snapshot strategy for design-system components.
  - Create test helpers: in-memory `ModelContainer` factory, sample-data/fixture builders, and UI-test launch arguments for seeded/empty states.
  - Document testing conventions (naming, given/when/then).
- **Acceptance:** A sample snapshot test and a sample model-backed unit test pass; helpers are reusable.
- **Tests:** The sample tests themselves.

### S05 — Design tokens
- [ ] **Goal:** Establish the visual foundation so no screen hardcodes styles.
- **Depends on:** S01
- **Requirements:** R28
- **Scope:**
  - Define semantic tokens: color (light/dark), typography scaled to **Dynamic Type**, spacing, corner radius, elevation.
  - Expose via a `Theme`/environment so components consume tokens, never raw values.
- **Acceptance:** Tokens render correctly in light/dark and scale with Dynamic Type; a demo/catalog screen shows them.
- **Tests:** Snapshot tests of the token catalog in light/dark and at an accessibility text size.

### S06 — Core component library
- [ ] **Goal:** Reusable primitives so features never build ad-hoc UI.
- **Depends on:** S05
- **Requirements:** R28
- **Scope:**
  - Build core components on tokens: primary/secondary/destructive buttons, text field, numeric stepper/entry, card, list row, chip/tag, section header, nav scaffolding.
  - Bake in accessibility: labels, traits, ≥44pt targets, Dynamic Type.
- **Acceptance:** Components appear in a component gallery screen; all meet touch-target and VoiceOver expectations.
- **Tests:** Snapshot tests per component (states + dark + large text); a VoiceOver/traits unit check where feasible.

### S07 — Feedback & state components
- [ ] **Goal:** Standard loading/empty/error surfaces reused everywhere.
- **Depends on:** S06
- **Requirements:** R18, R26
- **Scope:** Empty-state view (icon + message + CTA), loading indicator, error/retry view, inline banner/toast.
- **Acceptance:** Each renders from the gallery; error view exposes a retry action; empty state takes a CTA.
- **Tests:** Snapshot tests for each state.

### S08 — App shell & navigation
- [ ] **Goal:** The top-level structure the whole app hangs off.
- **Depends on:** S06
- **Requirements:** R25, R13
- **Scope:**
  - Tab bar: **Workouts/Templates** (default landing), **History**, and a **capability-gated AI Chat** tab (hidden/disabled when AI unavailable — gating logic stubbed until S36).
  - Landing screen presents a start-workout entry point + template list placeholder.
  - Routing/navigation conventions documented.
- **Acceptance:** App launches to the landing tab; tabs navigate; AI tab visibility is controlled by a single injectable capability flag.
- **Tests:** UI test asserting tab presence/landing; unit test for capability-gated tab visibility.

### S09 — Data layer core (SwiftData + two stores + migration baseline)
- [ ] **Goal:** The persistence foundation for all user data.
- **Depends on:** S01
- **Requirements:** R14, R23, R37
- **Scope:**
  - Define SwiftData models: `Template`, `TemplateExercise`, `TargetSet`, `Session`, `LoggedExercise`, `LoggedSet`, `CustomExercise`, `CatalogExercise` (see `ARCHITECTURE.md` data model).
  - Configure **two `ModelContainer`s**: a local (non-CloudKit) store for the catalog and a **CloudKit private** store for user-authored data.
  - Establish a **versioned schema (v1) + `SchemaMigrationPlan`** baseline; adopt an additive-only discipline and document the dev→prod CloudKit promotion step.
- **Acceptance:** Both containers initialize; a round-trip create/read works in each; a no-op migration from v1→v1 is wired.
- **Tests:** Unit tests for model round-trips in an in-memory container; a migration-plan smoke test.

### S10 — Cross-store exercise reference
- [ ] **Goal:** Reference catalog/custom exercises across store boundaries safely.
- **Depends on:** S09
- **Requirements:** R33, R2
- **Scope:**
  - Define `ExerciseRef { source: catalog|custom, id }` plus a denormalized name snapshot on referencing entities.
  - Build a resolver that, given an `ExerciseRef`, loads from the correct store, with a graceful fallback to the snapshot when unresolved.
- **Acceptance:** A `TemplateExercise`/`LoggedExercise` holding a ref resolves to the right exercise across both stores; unresolved refs still display the snapshot name.
- **Tests:** Unit tests for resolution (catalog hit, custom hit, missing → snapshot).

### S11 — Canonical units
- [ ] **Goal:** One canonical storage unit so history/progression never drift.
- **Depends on:** S01
- **Requirements:** R36
- **Scope:** Value types storing **mass in kg, distance in meters**; conversion + formatting utilities; a display-unit hook (preference wired later in S48).
- **Acceptance:** Values persist in metric and format correctly to lb/kg & mi/km for display; conversions are lossless round-trip within tolerance.
- **Tests:** Unit tests for conversion/formatting and round-trip stability.

### S12 — Catalog seeding
- [ ] **Goal:** Ship the exercise catalog, offline, without duplicates.
- **Depends on:** S09, S10
- **Requirements:** R1, R23, AE8
- **Scope:**
  - Bundle free-exercise-db; key entries by a **stable upstream id** (never array position).
  - Idempotent **upsert** seeder for first launch and app-update refresh; never re-create/renumber.
  - **Verify the free-exercise-db license** permits bundling/redistribution in a paid app; record findings.
- **Acceptance:** First launch seeds the catalog offline; re-running the seeder produces no duplicates; simulated catalog update upserts in place (AE8).
- **Tests:** Unit tests for seed + re-seed idempotency and stable-id keying.

### S13 — MetricKit diagnostics
- [ ] **Goal:** Crash/hang insight without breaking the privacy label.
- **Depends on:** S01
- **Requirements:** R27
- **Scope:** Subscribe to MetricKit; capture crash/hang/metric payloads on-device (log/persist locally). **No third-party analytics/crash SDKs.**
- **Acceptance:** MetricKit payloads are received and handled; dependency audit confirms zero data-collecting SDKs.
- **Tests:** Unit test for the payload handler with a mock payload.

### S14 — Accessibility baseline
- [ ] **Goal:** Bake accessibility into the foundation, not bolt it on.
- **Depends on:** S06
- **Requirements:** R28
- **Scope:** Dynamic Type audit of components, VoiceOver labeling conventions doc, ≥44pt target lint/checklist, one-handed reachability guidance for active-workout controls.
- **Acceptance:** Component gallery passes an accessibility audit at the largest Dynamic Type size; conventions documented.
- **Tests:** Snapshot tests at accessibility text sizes; VoiceOver label assertions where feasible.

---

## Phase 1 — Exercises & catalog

### S15 — Browse & search catalog
- [ ] **Goal:** Let users find exercises from the seeded catalog.
- **Depends on:** S08, S12
- **Requirements:** R1, R3
- **Scope:** List of catalog exercises; search by name; filter by muscle group/equipment; reads the local catalog store.
- **Acceptance:** Search/filter return expected results offline; large list scrolls smoothly.
- **Tests:** Unit tests for search/filter logic; UI test for search flow.

### S16 — Exercise detail
- [ ] **Goal:** Show an exercise's attributes and supported set types.
- **Depends on:** S15
- **Requirements:** R3
- **Scope:** Detail view (name, muscle group, equipment, supported set types). Image bundling remains deferred — text-first.
- **Acceptance:** Opening any catalog/custom exercise shows its details.
- **Tests:** Snapshot test of the detail view.

### S17 — Create & edit custom exercise
- [ ] **Goal:** Users add exercises the catalog lacks.
- **Depends on:** S10, S16
- **Requirements:** R2
- **Scope:** Create/edit a custom exercise (name + attributes) stored in the CloudKit store; usable anywhere via `ExerciseRef`.
- **Acceptance:** A created custom exercise appears in search and is selectable in the builder; editing persists.
- **Tests:** Unit test for persistence; UI test for the create flow.

---

## Phase 2 — Templates

### S18 — Template builder (create)
- [ ] **Goal:** Manually build a reusable template.
- **Depends on:** S10, S15
- **Requirements:** R4, R3
- **Scope:** Name a template, add exercises via picker, order them; scaffolding for target sets (editor in S19).
- **Acceptance:** A template with exercises persists and reopens intact.
- **Tests:** Unit test for template persistence; UI test for create flow.

### S19 — Target set editor
- [ ] **Goal:** Define target sets per exercise, by type.
- **Depends on:** S18, S11
- **Requirements:** R3, R29 (rest duration field)
- **Scope:** Add/remove/edit target sets: weight×reps or time/distance/pace; **optional per-set rest duration**; values stored canonically (S11).
- **Acceptance:** Sets of each type save and display; rest duration optional; units stored in metric.
- **Tests:** Unit tests for set-type modeling & unit storage; UI test for editing sets.

### S20 — Template list & empty state
- [ ] **Goal:** Browse saved templates from the landing tab.
- **Depends on:** S18, S07
- **Requirements:** R25, R26
- **Scope:** Template list on the landing tab; empty state with create/generate CTA.
- **Acceptance:** Empty state shows with no templates; list populates after creation.
- **Tests:** Snapshot tests (empty + populated); UI test navigating list → detail.

### S21 — Edit & delete template
- [ ] **Goal:** Maintain templates over time.
- **Depends on:** S20
- **Requirements:** R34
- **Scope:** Edit a saved template (rename, add/remove exercises, change target sets); delete a single template with confirmation; editing does not alter prior sessions.
- **Acceptance:** Edits persist; delete removes only that template; past sessions unaffected.
- **Tests:** Unit tests for edit/delete semantics; UI test for delete confirmation.

---

## Phase 3 — Active workout & timers

### S22 — Start a workout
- [ ] **Goal:** Begin a live session from empty or a template.
- **Depends on:** S09, S20
- **Requirements:** R5
- **Scope:** Start-workout entry points; instantiate a live `Session` from empty or by copying a template's exercises/target sets (decoupled from the source template).
- **Acceptance:** Starting from a template pre-populates the session; starting empty yields a blank session.
- **Tests:** Unit test for session instantiation from a template; UI test for both entry points.

### S23 — Live workout logging
- [ ] **Goal:** Perform and log sets during a workout.
- **Depends on:** S22, S06
- **Requirements:** R6, R7 (partial)
- **Scope:** Live workout screen listing exercises/sets; log reps/weight/time/distance per set; mark sets complete; one-handed reachable primary controls.
- **Acceptance:** Logged values persist to the live session and survive app backgrounding.
- **Tests:** Unit tests for logging model updates; UI test for logging a set.

### S24 — Rule-based progression engine
- [ ] **Goal:** Deterministic progressive-overload suggestions on all devices.
- **Depends on:** S09
- **Requirements:** R9, R17
- **Scope:** Pure logic service: given prior performance of an exercise, compute an advisory suggestion (e.g. increase load when top of rep range met); **cold start** → no suggestion, prompt for starting load. Exact policy (thresholds/increments) decided here and recorded.
- **Acceptance:** Suggestions match documented rules; no suggestion when no history (AE1, cold start).
- **Tests:** Unit tests across rep-range/increment/cold-start cases.

### S25 — Progression suggestions in UI
- [ ] **Goal:** Surface suggestions where users act.
- **Depends on:** S24, S23
- **Requirements:** R9, R17, AE1
- **Scope:** Show advisory suggestions per exercise in template view and live workout; never auto-apply; starting-load prompt on cold start.
- **Acceptance:** Suggestion appears as advisory (not pre-filled as performed); cold-start prompts instead.
- **Tests:** UI test verifying advisory presentation; snapshot of suggestion + cold-start states.

### S26 — Mid-workout mutation
- [ ] **Goal:** Fully mutable live workouts.
- **Depends on:** S23
- **Requirements:** R6, AE4
- **Scope:** Add/remove exercises, add/remove/edit sets mid-session regardless of start type; changes captured in history without altering the source template.
- **Acceptance:** Adding an unplanned exercise and changing set counts reflects in the session and recorded history; source template unchanged (AE4).
- **Tests:** Unit tests for mutation isolation from templates; UI test for add-exercise mid-workout.

### S27 — Rest timer (foreground) & controls
- [ ] **Goal:** Per-set rest timer with reliable timing and controls.
- **Depends on:** S23
- **Requirements:** R29, R31, R32
- **Scope:** Optional per-set rest timer derived from **persisted wall-clock timestamps** (never an in-process counter); foreground countdown + haptic/sound at end; controls: skip/dismiss, pause/resume, adjust ±; adjustments rewrite the persisted end timestamp.
- **Acceptance:** Timer counts down in foreground and signals at end; controls behave; adjusting changes the persisted target.
- **Tests:** Unit tests for timestamp-derived remaining-time & control math; UI test for start/skip/adjust.

### S28 — Rest timer (background & terminated)
- [ ] **Goal:** Correct behavior when the app isn't foregrounded.
- **Depends on:** S27
- **Requirements:** R29, R31, AE9
- **Scope:** While backgrounded (not terminated), play a short audible cue at completion **honoring the ring/silent switch** (background-audio mechanism decided here); **no signal when fully terminated**; on resume, recompute remaining/elapsed from timestamps. No pre-scheduled local notifications.
- **Acceptance:** Closing the app for N minutes and reopening shows the timer as elapsed accordingly (AE9); backgrounded cue respects the silent switch; terminated → no signal.
- **Tests:** Unit tests for elapsed recompute after simulated gaps; manual/QA note for audio-session behavior.

### S29 — Session duration & manual pause
- [ ] **Goal:** Track total workout time meaningfully.
- **Depends on:** S22
- **Requirements:** R30, R31
- **Scope:** Track total elapsed from start to completion via timestamps; **manual pause/resume** (subtract paused intervals); no auto-pause; long gaps accrue real time (accepted). Model paused intervals as explicit (start,end) pairs.
- **Acceptance:** Duration displays live and stores on completion; manual pause excludes paused time; closed-and-resumed sessions accrue real elapsed.
- **Tests:** Unit tests for duration with/without pauses and across simulated background gaps.

### S30 — Complete workout
- [ ] **Goal:** Persist a finished session to history.
- **Depends on:** S23, S29
- **Requirements:** R7
- **Scope:** Complete action records the performed session (exercises, sets, start/end timestamps, duration) and routes to History.
- **Acceptance:** Completed workout appears in History with correct data.
- **Tests:** Unit test for session finalization; UI test for complete flow.

### S31 — Cancel / discard / resume
- [ ] **Goal:** Never lose an in-progress workout.
- **Depends on:** S23
- **Requirements:** R16, AE7
- **Scope:** Cancel/discard with confirmation; auto-persist incomplete sessions; offer resume after background/terminate/relaunch, restoring the session clock and any running rest timer.
- **Acceptance:** Terminating mid-workout and relaunching offers resume with state intact (AE7); discard removes the session after confirm.
- **Tests:** Unit tests for auto-persist/resume state; UI test for resume prompt.

---

## Phase 4 — History

### S32 — History list
- [ ] **Goal:** Review past workouts.
- **Depends on:** S30, S07
- **Requirements:** R8, R26
- **Scope:** Reverse-chronological list of performed sessions; empty state guiding to a first workout.
- **Acceptance:** Sessions list newest-first; empty state shows when none.
- **Tests:** Snapshot (empty + populated); UI test list → detail.

### S33 — Session detail
- [ ] **Goal:** Inspect a performed session.
- **Depends on:** S32
- **Requirements:** R8
- **Scope:** Detail view of exercises/sets performed, duration, date.
- **Acceptance:** Opening a session shows accurate details.
- **Tests:** Snapshot of the detail view.

### S34 — Edit & delete past session
- [ ] **Goal:** Correct mistakes in history.
- **Depends on:** S33
- **Requirements:** R35
- **Scope:** Edit logged exercises/sets of a past session; delete a single session (distinct from full reset); edits/deletes propagate via CloudKit and feed progression (S24).
- **Acceptance:** Editing a mis-logged set updates history and subsequent suggestions; delete removes only that session.
- **Tests:** Unit tests for edit/delete + progression re-read; UI test for correcting a set.

---

## Phase 5 — Training-history summary

### S35 — History summary builder
- [ ] **Goal:** Compact on-device training summary feeding AI and the app.
- **Depends on:** S30, S24
- **Requirements:** R12, R22
- **Scope:** Build a rolling summary (recent lifts, PRs, volume trends) from logged history, entirely on-device; sized for the on-device model's context; reusable by app surfaces.
- **Acceptance:** Summary reflects recent history and stays within a defined size budget; never leaves the device.
- **Tests:** Unit tests for summary contents and size bounds.

---

## Phase 6 — AI generation & coaching (capability-gated)

### S36 — Foundation Models availability gating
- [ ] **Goal:** Light up AI only where supported; never block manual use.
- **Depends on:** S08
- **Requirements:** R13, R22, AE2
- **Scope:** Runtime capability detection for Apple Intelligence / Foundation Models; drive the AI Chat tab + entry-point visibility; disable AI (no server/PCC fallback) when unavailable.
- **Acceptance:** On an incapable device, no AI entry points are actionable and all manual features remain (AE2); capable device exposes AI.
- **Tests:** Unit tests for capability flag → UI gating; UI test asserting AI hidden when flag off.

### S37 — AI chat interface
- [ ] **Goal:** Conversational surface for generation.
- **Depends on:** S36, S07
- **Requirements:** R11
- **Scope:** Chat UI (message list, input, send); wired to the generation service (S38); reachable only when capable.
- **Acceptance:** User can send a message and see request/response turns with proper states.
- **Tests:** UI test for the chat send flow (mock backend); snapshot of chat states.

### S38 — Guided generation → typed workout
- [ ] **Goal:** Produce a structured single workout from chat.
- **Depends on:** S37, S35
- **Requirements:** R11, R12
- **Scope:** Assemble prompt with the history summary; use **guided generation** to emit a typed single-workout/template object (schema-locked); on-device only.
- **Acceptance:** A described workout yields a schema-valid typed object populated from intent + summary.
- **Tests:** Unit tests for prompt assembly and schema decoding (mock model output).

### S39 — Generation interaction states
- [ ] **Goal:** Robust UX around a fallible model.
- **Depends on:** S38
- **Requirements:** R18, AE6
- **Scope:** Generating indicator; error state with retry/rephrase; defined handling for empty/invalid output.
- **Acceptance:** Failure/timeout/invalid output shows an error+retry rather than a frozen/empty screen (AE6).
- **Tests:** Unit tests for state transitions; UI test for the error/retry path.

### S40 — Post-generation validation
- [ ] **Goal:** Ensure generated content is real and usable.
- **Depends on:** S38, S12
- **Requirements:** R20
- **Scope:** Validate exercise references resolve against catalog/custom; reject/regenerate implausible output or offer unknowns as new custom exercises. Judge success by semantic acceptance, not schema alone.
- **Acceptance:** Unresolvable/implausible output is caught and handled (regenerate or offer-as-custom); valid output passes.
- **Tests:** Unit tests for validation (resolvable, unresolvable, implausible).

### S41 — Generated workout → editable builder
- [ ] **Goal:** Put the user in control of AI output.
- **Depends on:** S40, S18
- **Requirements:** R19
- **Scope:** Open validated output pre-populated in the standard template/workout builder; user edits, then Save as template or Start now.
- **Acceptance:** Generated workout is fully editable and can be saved or started (reusing S18/S22).
- **Tests:** UI test: generate → edit → save/start.

### S42 — Cold-start generation
- [ ] **Goal:** Generation works before any history exists.
- **Depends on:** S38
- **Requirements:** R21
- **Scope:** With empty/short history, generate from stated goals, equipment, and experience rather than failing.
- **Acceptance:** A brand-new user gets a reasonable generated workout without accrued history.
- **Tests:** Unit test for cold-start prompt path.

### S43 — AI progression coaching
- [ ] **Goal:** Richer, context-aware suggestions where available.
- **Depends on:** S36, S24, S35
- **Requirements:** R10
- **Scope:** On capable devices, layer AI progression suggestions alongside rule-based ones (S25); clearly additive, never replacing the deterministic baseline.
- **Acceptance:** Capable devices show AI suggestions in addition to rule-based; incapable devices unaffected.
- **Tests:** Unit tests for merge/gating of AI vs rule-based suggestions.

---

## Phase 7 — Sync, privacy & App Store

### S44 — CloudKit sync & offline reconcile
- [ ] **Goal:** Automatic sync/backup with offline resilience.
- **Depends on:** S09
- **Requirements:** R14, R15, AE3
- **Scope:** Wire CloudKit private-database sync for user-authored data; ensure offline edits reconcile on reconnect.
- **Acceptance:** A session logged offline syncs on reconnect without data loss (AE3); multi-device data converges.
- **Tests:** Unit/integration tests for offline→online reconcile (as feasible); QA note for device sync.

### S45 — Sync status & conflict handling
- [ ] **Goal:** Make sync legible and conflicts defined.
- **Depends on:** S44, S07
- **Requirements:** R24
- **Scope:** Surface syncing/synced/offline status and a distinct signed-out-of-iCloud state (sync paused); **decide and record the conflict-resolution strategy** (e.g. last-writer-wins vs field-merge; whether sessions are append-only) and reflect it in behavior.
- **Acceptance:** Status states display accurately; signed-out state explains paused sync; conflict behavior is documented and observable.
- **Tests:** Unit tests for status derivation; snapshot of each state.

### S46 — Data deletion / reset
- [ ] **Goal:** User-controlled full data deletion.
- **Depends on:** S44
- **Requirements:** R27, AE5
- **Scope:** User-facing deletion/reset path removing local data and propagating to the private CloudKit database; no developer-server copy exists.
- **Acceptance:** Confirming deletion clears local + CloudKit data (AE5).
- **Tests:** Unit/integration test for local+CloudKit deletion propagation.

### S47 — Privacy label & policy
- [ ] **Goal:** Ship an accurate, defensible privacy posture.
- **Depends on:** S13, S46
- **Requirements:** R27
- **Scope:** Configure App Store **"Data Not Collected"** label; write a short privacy policy; confirm no data-collecting SDKs (audit) and on-device-only AI.
- **Acceptance:** Privacy label and policy match actual behavior; dependency audit is clean.
- **Tests:** N/A (compliance); dependency audit checklist committed.

### S48 — Units display preference
- [ ] **Goal:** Let users choose lb/kg without touching stored data.
- **Depends on:** S11
- **Requirements:** R36
- **Scope:** Settings preference for display units (per-user default; decide whether per-exercise override is in scope); wired to canonical-metric storage from S11.
- **Acceptance:** Switching units changes display only; stored values and history comparisons are unaffected.
- **Tests:** Unit tests for preference-driven formatting; UI test for toggling units.

### S49 — First-launch onboarding
- [ ] **Goal:** Orient a brand-new user.
- **Depends on:** S08, S20
- **Requirements:** R26
- **Scope:** First-launch orientation to building/starting a workout; empty states polished across tabs.
- **Acceptance:** A fresh install guides the user to a first action; empty states are helpful.
- **Tests:** UI test for first-launch flow; snapshots of empty states.

### S50 — Visual polish, icon & launch screen
- [ ] **Goal:** Ship-quality look and feel.
- **Depends on:** S06, S49
- **Requirements:** R28
- **Scope:** App icon, launch screen, spacing/typography polish pass across screens using the design system; dark-mode and Dynamic Type QA.
- **Acceptance:** App looks cohesive in light/dark at varied text sizes; icon/launch screen present.
- **Tests:** Snapshot regression pass on key screens.

### S51 — App Store submission prep
- [ ] **Goal:** Get to a submittable build.
- **Depends on:** all prior
- **Requirements:** Distribution (Goal Capsule); R27
- **Scope:** App Store Connect setup, metadata & keywords, screenshots, privacy label (S47), pricing (paid, no IAP), TestFlight beta, release checklist; final device QA on capable + incapable hardware.
- **Acceptance:** Build passes validation and is submittable to App Store review; TestFlight build usable by beta testers.
- **Tests:** Full regression suite green in CI; manual release-checklist sign-off.

---

## Deferred (post-MVP)

Tracked here so they aren't lost, but explicitly **out of MVP** (see `ARCHITECTURE.md` → Scope Boundaries):

- Apple Watch companion app.
- HealthKit integration (write workouts; read bodyweight/HR).
- Multi-day programs / splits scheduling (entity shape already reserved).
- Exercise images/animations bundling (revisit app-size/licensing).
- Data export/portability (decide in/out; see Outstanding Questions).
- Bodyweight tracking (confirm scope during planning).
