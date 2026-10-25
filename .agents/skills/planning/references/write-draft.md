# Write a draft

Draft an article on the requested topic from local sources and verify its factual claims. Treat `$ARGUMENTS` in the starting prompt as the user's requested topic, not literal article text. If no topic can be inferred from the request or project context, ask for it before drafting.

Resolve `sources/`, `drafts/`, and `progress.md` relative to the working project root unless the user specifies another location. Read existing outputs before revising them and preserve unrelated progress entries. Create `drafts/` if needed.

## Workflow

1. Read relevant files in `sources/` and open their primary-source links. Record which files and primary sources support the article. If a source is missing or inaccessible, record that gap; do not treat its claims as verified.
2. Write an outline before the prose, saving it as `drafts/outline.md`. Then save the article as `drafts/article.md`, with citations close to factual claims so the reviewer can trace them.
3. Read [evidence-reviewer.md](evidence-reviewer.md) and ask an independent subagent named `evidence-reviewer` to perform that review. Give it the draft, source locations, and reviewer brief. If delegation is unavailable, apply the same evidence standard directly and disclose that independent review could not be completed.
4. Correct errors supported by the review. Mark unresolved claims inline with `[REVIEW: reason]` and record what evidence is still needed. Check revised claims against their evidence before labeling them verified; do not label an entire article verified while unresolved claims remain.
5. Save the final claim-checking table as `drafts/checks.md`. Include the reviewer used, any source-access limitations, and counts of verified, incorrect, and unresolved claims. Retain the original issue and applied correction for revised claims, separately from their final verdicts.
6. Update `progress.md` using the progress-note guidance below. If there are no open issues, say so; distinguish completion of the requested drafting work from any optional next step without implying publication approval.
7. Return `drafts/article.md` and `drafts/checks.md`, plus verification results and remaining limitations. Mention the outline and progress paths when useful.

## Resume from progress

When asked to continue existing writing work:

1. Read `progress.md` first, then inspect the draft and checks it references. Follow its recorded paths instead of assuming the default filenames. Read the outline or source material as needed for the next action.
2. Compare the recorded next action and open issues with the actual artifacts and the user's latest instructions. Continue from the first still-needed action; if it is already complete or stale, record the adjustment and proceed to the next supported action. A progress note is a handoff, not proof that a claim was verified.
3. Perform the recorded work within the authorized scope, preserving existing decisions and unaffected prose. Reuse applicable review findings; recheck changed claims, their affected premises, and evidence that is stale or was never opened. Expand the review when changes undermine earlier conclusions. Do not restart the outline or repeat the entire review without a concrete reason.
4. Keep the draft and checks consistent. Apply the evidence-reviewer standard to factual changes, update verdicts and counts, and retain unresolved markers until evidence resolves them. If a referenced artifact is missing, locate it from available project context; if it cannot be recovered, record the gap and continue only work that does not depend on it.
5. Update `progress.md` after saving the artifacts, including when blocked or stopping partway through. Return the draft and checks paths, what advanced, verification results, and any remaining blocker or next action.

## Progress note

Maintain a concise current handoff for this draft, preserving unrelated entries. Include:

- Draft and checks paths, plus outline or source locations needed to resume.
- Decisions that still govern the writing and review.
- Work completed in this continuation and current verification state, including any review limitations.
- Open issues with claim locations and the exact missing evidence or input; explicitly state when none remain.
- One concrete next action with its target artifact and expected result, or a statement that the requested work is complete. If blocked, name the prerequisite that would unblock it.

Replace stale next-action text rather than accumulating competing instructions. Record the state actually saved, not intended work, so the next session can continue without reconstructing the conversation.

## Claim-checking table

Use the table and verdict definitions in [evidence-reviewer.md](evidence-reviewer.md): claim, verdict, source URL, required correction. Each unresolved row must state which evidence is missing. Label inference in the draft and check its factual premises.

These outputs are writing artifacts, not active `.wiki` plans. Do not prune a finished article, its checks, or its writing decisions under the plan-retirement rules.
