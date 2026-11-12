---
type: Plan
title: Require validation checks on main
description: Enable the documented PR validation checks in the existing GitHub main ruleset.
difficulty: low
impact: high
package: [github-actions, repository-settings]
tags: [ci, branch-protection, github]
status: planned
execution: phased
phase_budget_hours: 5
---

# Goal

Require the three existing validation checks for changes to `main`, subject to the repository's existing bypass policy.

# Current evidence

The implemented workflow passed `Shell validation`, `Dockerfile validation`, and `Configuration validation` on PR #7 at `2fbb4ad` in [run 43133232599](https://github.com/jhwohlgemuth/gold/actions/runs/43133232599). The check provider is GitHub Actions (app ID 15368). `.github/CONTRIBUTING.md` now documents the exact names, scope, setup steps, and current enforcement status.

On 2026-11-12 UTC, the GitHub API showed classic protection on `main` with no required status checks. The active [main ruleset 1365542](https://github.com/jhwohlgemuth/gold/rules/1365542) targets `~DEFAULT_BRANCH`, blocks deletion and non-fast-forward updates, and requires CodeQL at the configured thresholds. Its effective branch rules contain no `required_status_checks`. It retains an always-bypass entry for repository role ID 5. The three validation jobs therefore run but are not enforced as required checks.

# Boundaries and decisions

This remaining phase changes GitHub repository settings, separately from the completed contributor-documentation work. Add only the three documented checks using the existing ruleset. Preserve its targeting, Active enforcement, CodeQL thresholds, deletion/force-push protections, and bypass actors. Record the effective result in contributor documentation.

# Validation and acceptance criteria

- The active rules for `main` require `Shell validation`, `Dockerfile validation`, and `Configuration validation` from GitHub Actions.
- Existing protections and bypass settings are preserved.
- The PR required-check state and contributor documentation agree with the effective GitHub rules; no merge is needed to validate the setting.

# Execution phases

## CI-03 — Enable the required checks in GitHub

- Status: planned
- Budget: 2 active hours maximum
- Prerequisites: repository rules editing access
- Exact write set: GitHub repository `jhwohlgemuth/gold`, ruleset `1365542`; `.github/CONTRIBUTING.md` dated enforcement statement
- Primary integration lock: required PR check enforcement
- Outcome: The three existing validation checks are required on `main` with the current bypass policy preserved.
- Focused validation: re-read the ruleset and effective branch rules, compare required check names/provider with the workflow and a PR run, verify unchanged existing rules/bypass actors, and inspect required-check status on a PR targeting main.
- Handoff: Record the effective rules and verification time in contributor documentation, then retire this plan and its portfolio references when acceptance criteria hold.
