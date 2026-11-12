---
type: Plan
title: Run validation on pull requests
description: Add an actual GitHub Actions validation workflow for repository checks.
difficulty: medium
impact: high
package: [github-actions, build]
tags: [ci, lint, shell, dockerfile]
status: planned
execution: phased
phase_budget_hours: 5
---

# Goal

Make code quality checks visible as required pull request results.

# Current evidence

`.github/workflows/validate.yml` defines PR/manual validation with pinned tools and actions, HTTPS-only binary downloads, and wheel-only Checkov installation. `Shell validation`, `Dockerfile validation`, and `Configuration validation` passed on PR #7 at `2fbb4ad` in [run 43133232599](https://github.com/jhwohlgemuth/gold/actions/runs/43133232599), verified from the GitHub jobs API. PR #7 merged as `cc1af0d`. Hadolint warnings/errors fail while informational diagnostics remain visible; Checkov overrides local soft-fail and rejects parse errors. Contributor documentation and the external branch-protection status remain to be reconciled.

# Boundaries and decisions

Add validation before image build automation. Pin third-party actions and tools according to the repository's workflow practice. Keep any required branch protection change as a named external system step, after the check names exist.

# Validation and acceptance criteria

- A pull request changing scripts, Dockerfiles, or configuration triggers checks for shell formatting, shell analysis, Dockerfile lint, and Checkov.
- A failed check makes the workflow fail; the workflow does not rewrite source files.
- Documentation names the exact status check to require in GitHub branch protection.

# Execution phases

## CI-02 — Document the branch protection gate

- Status: ready
- Budget: 2 active hours maximum
- Prerequisites: none; the validation jobs passed on PR #7
- Exact write set: `.github/CONTRIBUTING.md`
- Primary integration lock: pull request validation workflow
- Outcome: Contributor instructions name the validation jobs and how maintainers make them required in GitHub branch protection.
- Focused validation: compare documented job names with `.github/workflows/validate.yml` and inspect the linked pull request run.
- Handoff: Record the configured status in GitHub branch protection if available; otherwise leave that external operation explicit and retire only after acceptance criteria hold.
