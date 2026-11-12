# Implementation — required-check enforcement (CI-03)

- Authorized scope: execute CI-03 by updating GitHub ruleset 1365542, preserving existing settings, verifying enforcement, and reconciling contributor documentation and the portfolio.
- Baseline: clean `main` at `ea79e7f`, merging PR #9; local branch `docs/ci-enforcement`.
- State: CI-03 complete and the CI plan retired. The GitHub ruleset change is live. Local documentation/planning changes remain uncommitted and unpublished.
- Budget: estimated less than one active hour of the two-hour maximum.

## Live ruleset result

On 2026-11-12 UTC, the existing active [main ruleset 1365542](https://github.com/jhwohlgemuth/gold/rules/1365542) gained one `required_status_checks` rule containing:

- `Shell validation`, GitHub Actions integration ID 15368.
- `Dockerfile validation`, GitHub Actions integration ID 15368.
- `Configuration validation`, GitHub Actions integration ID 15368.

`strict_required_status_checks_policy` is false: the change requires the three checks without introducing an up-to-date-branch requirement. GitHub returned `do_not_enforce_on_create: false`.

Before updating, the current ruleset was compared with the inspected snapshot to prevent overwriting intervening edits. The update retained its name, branch target, Active enforcement, `~DEFAULT_BRANCH` targeting, empty exclude list, CodeQL thresholds (`high_or_higher` / `errors`), deletion/non-fast-forward protections, and always-bypass entry for repository role ID 5. The before/after comparison confirmed those fields and all prior rules were unchanged.

Temporary audit snapshots: `/var/folders/j8/zdr2cnr934x80qdkddy48nshjhbsm8/T/gold-ci03-an0nt3tn/before.json`, `update.json`, `after.json`, and `effective-main.json`. The mutation used `PUT /repos/jhwohlgemuth/gold/rulesets/1365542`; readbacks used that ruleset endpoint and `GET /repos/jhwohlgemuth/gold/rules/branches/main`.

## Verification

The effective branch rules include exactly the three expected names/provider IDs from ruleset 1365542. GitHub GraphQL also returned `isRequired(pullRequestNumber: 9): true` for each job on [PR #9](https://github.com/jhwohlgemuth/gold/pull/9), whose base is `main`; each check concluded `SUCCESS` at `ad6d0899fc77a6a2dc474536c7dc975de21e79c4`.

There were no open PRs, so required-check flags were inspected on the existing merged PR #9. No merge or bypass attempt was performed. The ruleset retains its existing bypass policy.

Contributor instructions now describe the active enforcement and how to maintain it. CI plan/index/network/lane references were removed; the portfolio contains two executable plans. Local validation compares documented check names to the workflow, resolves local Markdown links, runs the wiki validator, and checks the diff for whitespace errors.

## Next action

Review/commit the local documentation changes. The next executable work is [MID-02](.wiki/features/midas-cli.md): first narrow its repository-wide write set to exact files, then package the Rust CLI. Its Terminal image validation shares a lock with IM-01. No later phase has been started or scheduled.
