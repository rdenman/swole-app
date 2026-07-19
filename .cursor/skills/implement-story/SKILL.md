---
name: implement-story
description: >-
  Implement a story from docs/STORIES.md for the Swole app end to end: find the
  story, build it against the design docs, run its tests, mark it complete and
  update phase status, and record any tech/product/UX decisions as decision docs
  so the project stays self-documenting. Use when the user asks to implement,
  work on, or pick up a story, names a story ID (e.g. "do S07"), or says "the
  next story".
---

# Implement a Story

Drives one story from `docs/STORIES.md` to a verified, documented, complete state.

## Project map

- **Canonical design doc:** `docs/DESIGN.md`. Single source of truth for requirements (`R#`), acceptance examples (`AE#`), flows (`F#`), data model, and key decisions. If it has been renamed, find the file with `artifact_contract: ce-unified-plan/v1` in its frontmatter.
- **Backlog:** `docs/STORIES.md`. Ordered stories `S01`–`S51`, a Milestones table, and status conventions.
- **Decision records:** `docs/decisions/`. One markdown file per non-trivial tech/product/UX decision (created on demand — see below).

## Workflow

Copy this checklist and track it:

```
- [ ] 1. Select the story
- [ ] 2. Load context (story + referenced R#/AE# + relevant decisions)
- [ ] 3. Mark the story In progress + phase In progress
- [ ] 4. Implement per Scope, honoring Definition of Done
- [ ] 5. Verify: run tests + lint; confirm every Acceptance bullet
- [ ] 6. Record decisions (docs/decisions/) + update docs/DESIGN.md if a decision resolves an Outstanding Question
- [ ] 7. Mark the story Complete + update the Milestones table
- [ ] 8. Summarize to the user
```

### 1. Select the story
- If the user named an ID (e.g. `S12`), use it. Otherwise pick the **first** story whose status is `- [ ] **Status:** Not started`, top to bottom.
- **Check dependencies:** read the story's `Depends on:` line. Every listed story must be `Complete`. If not, stop and tell the user which dependency is unmet — do not skip ahead unless they confirm.

### 2. Load context
- Read the entire story (Goal, Scope, Acceptance, Tests, Requirements).
- Open `docs/DESIGN.md` and read every referenced `R#`/`AE#`/`F#`. Implement to the requirement text, not just the story summary.
- Skim `docs/decisions/` for records relevant to this area so you stay consistent with prior choices.
- Confirm reuse: build UI from the design system (Phase 0 stories S05–S07); never introduce ad-hoc components or hardcoded tokens.

### 3. Mark In progress
- Set the story's status marker to `- [ ] **Status:** In progress`.
- In the Milestones table, set the story's phase to `In progress` if it is currently `Not started`.

### 4. Implement
Follow the story's **Scope**. Honor the per-story **Definition of Done** from `docs/STORIES.md`:
acceptance criteria met, tests passing, lint/format clean, no accessibility regressions, all new UI from the design system.
- Keep the change scoped to this one story. If you discover necessary work outside its scope, note it for a follow-up story rather than expanding silently.
- Some stories embed a decision as their first task (e.g. iOS baseline in S01, progression policy in S24, background-audio mechanism in S28, conflict-resolution strategy in S45). Make the decision, implement it, and record it (step 6).

### 5. Verify (evidence before "done")
- Run the story's tests (unit; plus UI tests for critical flows). Once S03 lands, run the CI-equivalent commands locally (build + test + `swiftlint` + `swiftformat --lint`).
- Walk each **Acceptance** bullet and confirm it is actually satisfied. Do not mark complete on unverified claims. If something fails, fix it and re-run.

### 6. Record decisions (keep the project self-documenting)
Create a decision record whenever the story involved a non-trivial, hard-to-reverse, or preference-setting choice in any of these areas:
- **tech** — architecture, libraries, data/schema, patterns, tooling.
- **product** — scope, behavior, or feature-shape choices.
- **ux** — interaction, navigation, or visual/design-system decisions.

Do **not** write a record for trivial or obvious implementation details. When in doubt for a genuinely load-bearing choice, write it.

Also: if a decision resolves an item in `docs/DESIGN.md` → **Outstanding Questions**, update that doc (move it out of Outstanding Questions into the relevant section or Key Decisions) and cite the decision record.

See [decision record format](#decision-record-format) below.

### 7. Mark Complete
- Set the story's status marker to `- [x] **Status:** Complete`.
- Update the Milestones table: set the phase to `Complete` if **all** its stories are now Complete; otherwise leave it `In progress`.

### 8. Summarize
Report concisely: what was built, files touched, tests run and their result, decision records created, any Outstanding-Question updates, and the next Not-started story.

## Decision record format

- **Location:** `docs/decisions/`
- **Filename:** `NNNN-<type>-<slug>.md` — `NNNN` is the next zero-padded sequence number across the folder; `<type>` is `tech` | `product` | `ux`; `<slug>` is a short kebab title. Example: `0003-ux-rest-timer-controls.md`.
- On first use, create `docs/decisions/README.md` as an index (a table of `ID | Type | Title | Story | Date`) and append a row for each new record.

Template:

```markdown
# NNNN — <Title>

- **Type:** tech | product | ux
- **Status:** Accepted
- **Date:** YYYY-MM-DD
- **Story:** S## (or —)
- **Requirements:** R##, AE## (or —)

## Context
Why a decision was needed; the forces at play.

## Decision
What was decided, stated plainly.

## Alternatives considered
- <option> — why not chosen.

## Consequences
Trade-offs, follow-ups, and any affected requirements, stories, or future work.
```

## Guardrails
- **Dependencies:** whenever you add or update a dependency (Swift Package, tool, etc.), use the latest stable version available. Resolve it via the package manager rather than hardcoding a guessed version, and note the resolved version in the story summary (and a decision record if the choice is load-bearing).
- Never mark a story Complete without running its tests and confirming its Acceptance bullets.
- Never start a story with unmet dependencies without explicit user confirmation.
- Never invent scope or requirements — if the story or a requirement is ambiguous, ask before building.
- Edit `docs/STORIES.md` status only for the story in flight (plus its Milestones row).
- Prefer editing existing docs over creating redundant ones; keep `docs/DESIGN.md` authoritative and decision records specific.
