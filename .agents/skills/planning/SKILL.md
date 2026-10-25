---
name: planning
description: Maintain and execute a repository's .wiki planning portfolio in bounded, resumable phases, or draft source-backed articles with claim verification. Use when creating, reviewing, updating, executing, pruning, or retiring plans in .wiki, continuing long implementation plans, writing and checking article drafts from sources/, or resuming from progress.md.
---

# Planning

Official guide, examples, and skill download: https://www.jasonwohlgemuth.com/okf-plan-browser/planning. Canonical source: https://github.com/jhwohlgemuth/okf-plan-browser/tree/main/.agents/skills/planning.

Keep `.wiki` aligned with the current repository and useful as a queue of remaining work. Plans are not historical ledgers: remove completed plans and prune completed sections, phases, and tasks after preserving durable evidence in code, tests, user documentation, architecture documentation, release history, or a concise current-evidence statement.

## Route the task

- For implementing or resuming a long plan, read [execution-loop.md](references/execution-loop.md) and [five-hour-slices.md](references/five-hour-slices.md). Continue through eligible phases within the user's authorized scope, checkpointing between phases.
- For writing an article draft from sources, read [write-draft.md](references/write-draft.md). Use that workflow instead of the plan workflow and invariants below; apply those only when also changing `.wiki` plans.
- For continuing draft work, use the resume workflow in [write-draft.md](references/write-draft.md#resume-from-progress): read `progress.md`, inspect its referenced draft and checks, then continue from the recorded next action.
- For factual claim verification, read [evidence-reviewer.md](references/evidence-reviewer.md), including when reviewing an existing draft without rewriting it.
- Read [wiki-lifecycle.md](references/wiki-lifecycle.md) whenever adding, reviewing, pruning, or retiring plans.
- Read [five-hour-slices.md](references/five-hour-slices.md) whenever creating or executing phases.
- Use [templates.md](references/templates.md) when authoring plan or phase structure.
- Read [portfolio-review.md](references/portfolio-review.md) for portfolio-wide reviews, rankings, dependency changes, or parallel scheduling.
- Run `python3 <planning-skill>/scripts/validate_wiki.py <repository-root>` after changing `.wiki`, resolving `<planning-skill>` to this skill's installed directory.

## Evidence

Evidence is inspected primary material that supports a specific claim within its stated scope and time. A citation, search snippet, prior plan, or reviewer assertion alone is not verification. Open the underlying source and record a precise locator and the passage or observation supporting the claim.

For repository claims, use current code, tests, execution results, and relevant history as primary evidence. Distinguish a test's existence from a passing run and implementation from observed behavior. For external factual claims, open primary-source links and check dates, versions, and qualifications. Label inference separately and identify missing evidence rather than treating uncertainty as completion.

Use `verified`, `incorrect`, or `unresolved` for claim verdicts as defined in the evidence-reviewer reference. These are evidence verdicts, not phase statuses. Keep plan evidence concise; use the full claim table for draft reviews or when requested.

## Required plan workflow

1. Inspect the current worktree, recent history, relevant code, tests, and documentation before trusting plan evidence. Use the repository's required code-navigation tools when present.
2. Separate completed facts from remaining work. Prune completed sections, phases, checked tasks, and stale dependencies; delete a plan when no work remains.
3. Express every remaining executable outcome as a phase with at most five active hours, one exact write set or named external system, one primary integration lock, focused validation, and a mergeable handoff.
4. Update plan metadata, current evidence, dependencies, acceptance criteria, nearest index, root index, dependency network, and parallel lane together when their truth changes.
5. Preserve stable IDs for unfinished phases after pruning. Never renumber remaining work merely to close gaps.
6. Validate the wiki and inspect the diff. Do not implement product work unless the user separately authorized implementation.

## Plan invariants

- Executable plans use `execution: phased` and `phase_budget_hours: 5`. Non-executable portfolio or coordination records use `execution: coordination` and contain no executable phases.
- Phase statuses are `planned`, `ready`, `blocked`, or `in-progress`. A completed phase is removed, not marked `done`.
- External waiting is a prerequisite, not active phase time.
- A validation defect becomes a new bounded repair phase; it does not silently expand the active phase.
- A finished plan is deleted with every index, network, and lane entry. Durable information must survive somewhere outside the active plan.
- Never retain checked-off task lists as planning history.
