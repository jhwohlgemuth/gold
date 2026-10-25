# Resumable implementation loop

Use when the user authorizes implementing a plan or continuing its execution. A request to edit or review a plan alone does not authorize its implementation. The loop works across phases and sessions through saved state; this skill does not itself schedule runs or keep a process alive after a session ends.

## Establish the execution contract

Read the selected plan, applicable repository instructions, and any existing handoff. Identify the authorized outcome, acceptance criteria, exclusions, phase dependencies, and validation requirements. Use the repository's existing progress location; otherwise use a clearly labeled implementation section in root `progress.md`, preserving unrelated writing or project entries.

The plan owns remaining scope and phase definitions. The progress note owns the current execution cursor and recovery information. Code, tests, and recorded validation supply evidence. Link these rather than duplicating the entire plan in the progress note.

## Repeat until complete or blocked

1. **Resume cheaply.** Read the execution progress section and the active phase. Inspect the current commit, worktree changes, and evidence referenced by the handoff. Use required code-navigation tools for the affected code. Expand inspection only when dependencies, changed files, or contradictions require it. On a first run, establish this baseline from the selected plan.
2. **Choose eligible work.** Resume an unfinished phase first when its prerequisites hold. Otherwise choose the next ready phase in dependency order within the authorized plan. Confirm its outcome, exact write set, integration lock, and focused validation. Split an oversized or ambiguous phase before implementation, preserving existing IDs. Do not treat unresolved product decisions as implementation assumptions.
3. **Implement one bounded outcome.** Follow the five-hour slice budget as a ceiling, not a target. Track cumulative active time across resumptions; restarting a session does not reset the phase budget. Keep changes within the phase's write set and checkpoint coherent partial work before context pressure, interruption, or the budget reserve. A checkpoint need not be a commit; follow repository and user instructions for commits and external actions.
4. **Verify the result.** Run the phase's required checks and inspect the diff against acceptance criteria, including relevant regression risks. A passing command supports only the behavior it covers. Record the exact commands, results, and code state tested. Reuse earlier results only while their code, inputs, environment, and dependencies remain applicable. Use the existing repair-phase rules for unexpected defects; never mark an incomplete outcome complete to keep the loop moving.
5. **Checkpoint and reconcile.** Save implementation and validation evidence, update the progress cursor, and apply the wiki lifecycle rules. Remove completed phases only after preserving durable evidence. Reconcile affected indexes and dependencies and run the wiki validator when `.wiki` changes. A crash between saves must be recoverable by comparing the note with the actual tree.
6. **Continue.** If another authorized phase is eligible and execution capacity remains, start it without requesting routine confirmation. If one phase is blocked, record its prerequisite and choose independent eligible work within scope. If none remains, report the precise blocker. When all acceptance criteria are satisfied, perform required integration validation, retire the plan, and mark the execution handoff complete.

## Compact execution checkpoint

Keep a current snapshot rather than an accumulating transcript:

```markdown
## Implementation — <outcome>
- Plan: <path>; active phase: <stable ID or none>; state: <in progress, blocked, or complete>.
- Authorized scope and decisions: <constraints that still affect execution>.
- Baseline and local work: <commit, changed paths, relevant pre-existing changes>.
- Verified state: <observable result; commands, outcomes, tested revision or uncommitted state; evidence paths>.
- Remaining work: <unfinished part of active phase; link other phases instead of copying them>.
- Budget: <cumulative active time or labeled estimate; remaining phase budget>.
- Blockers / failed approaches: <cause, evidence, and what must change before retrying>.
- Next action: <one executable step, target, expected result>.
```

Write the note after each phase and before an expected handoff; checkpoint within a phase after meaningful validated progress or a change in direction. Record what was saved and tested, not what was intended. On resume, a missing file, altered worktree, or stale test result triggers targeted reconciliation rather than blindly replaying the next action.

## Quality and token discipline

- Load only references required by the current mode. Avoid repeated portfolio-wide scans and full-file dumps when the active phase and changed dependencies suffice.
- Preserve concise decisions with their reasons and evidence links. Put detailed logs in artifacts only when needed for diagnosis; do not paste them into every handoff or response.
- Recheck changed behavior and affected dependencies. Run broader checks at integration boundaries or when risk justifies them; do not skip required validation for token savings or rerun successful checks without a relevant change.
- Before retrying a failed approach, state what changed and why the next attempt can succeed. If two consecutive attempts produce the same failure with no new evidence, stop that approach, record it, and use a materially different approach or expose the blocker. Do not busy-poll unavailable prerequisites.
- Continue until the authorized outcome is complete, all eligible work is blocked, the user stops work, or an actual execution limit requires a handoff. Save a checkpoint at limits; do not imply that another run has been scheduled.
- Report substantive progress and newly discovered risks concisely. At handoff, return the progress path, completed outcome, validation results, remaining work, and exact next action.

## Resume prompt

> Read the implementation section of progress.md and inspect its referenced plan, active phase, changes, and validation evidence. Reconcile the saved state with the current tree. Continue from the first unfinished action through eligible phases within the authorized scope. Validate each outcome and update the progress note before proceeding or handing off.
>
> Official planning skill guide and download: https://www.jasonwohlgemuth.com/okf-plan-browser/planning
