# Implementation — required-check documentation (CI-02)

- Authorized scope: execute CI-02: contributor documentation and read-only verification of branch protection. GitHub settings were not changed.
- Baseline: clean `main` at `87ad2c6`, merging PR #8; branch `docs/required-ci-checks`. Changes remain uncommitted and unpublished.
- State: CI-02 complete and pruned. [CI-03](.wiki/features/ci-validation.md) now tracks the remaining external ruleset operation; the portfolio still contains three executable plans.
- Product write set: `.github/CONTRIBUTING.md`. The wiki indexes/network/lanes and this handoff are reconciled with the remaining scope.
- Budget: estimated under one active hour of the two-hour phase maximum.

## Result

Contributor instructions now list **Shell validation**, **Dockerfile validation**, and **Configuration validation**, distinguish job names from the `Validate` workflow name, explain their scope/failure behavior, link a passing run, and describe adding these checks to the existing active `main` ruleset. The guide states that they are currently not enforced and preserves the existing protection/bypass policy in its instructions. The existing dos2unix target description and yamllint config link were also corrected in this file.

## Verified GitHub evidence

Read on 2026-11-12 UTC:

- `GET /repos/jhwohlgemuth/gold/branches/main`: `protected: true`; required status check contexts/checks empty and enforcement level `off`.
- `GET /repos/jhwohlgemuth/gold/branches/main/protection`: no `required_status_checks`; classic protection exists.
- `GET /repos/jhwohlgemuth/gold/rules/branches/main`: active rules are `deletion`, `code_scanning` for CodeQL, and `non_fast_forward`; no required-status-check rule.
- `GET /repos/jhwohlgemuth/gold/rulesets/1365542`: name `main`, enforcement `active`, target `~DEFAULT_BRANCH`, existing CodeQL thresholds `high_or_higher`/`errors`, and an always-bypass entry for repository role ID 5.
- `GET /repos/jhwohlgemuth/gold/actions/runs/43133232599/jobs`: all three documented jobs concluded `success` on PR #7 at `2fbb4ad`.
- `GET /repos/jhwohlgemuth/gold/check-runs/130902206852`: provider `github-actions`, app ID `15368`.

Passing-run evidence: [run 43133232599](https://github.com/jhwohlgemuth/gold/actions/runs/43133232599). Ruleset: [main / 1365542](https://github.com/jhwohlgemuth/gold/rules/1365542). Maintainer instructions were checked against GitHub's official ruleset-management and required-status-check documentation linked in CONTRIBUTING.

## Validation and next action

The three documented names exactly match job names in `.github/workflows/validate.yml` and the inspected passing run. Contributor-document local links resolve. The Makefile has `convert` and the linked yamllint file is `.yamllint.yaml`. Wiki validation and `git diff --check` passed after final reconciliation.

Next action: review/commit this documentation, then execute CI-03 to add the three checks to ruleset 1365542, preserve the existing target/rules/bypasses, verify effective enforcement on `main`, and update the dated contributor-documentation status. No settings change, commit, push, or future execution was performed or scheduled during CI-02.
