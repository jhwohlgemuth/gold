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

`.github/workflows/` contains only `prune.yml`, which runs on schedule and manual dispatch. `.github/agents/development.yml` describes pull request checks, but it is an agent configuration file, not a GitHub Actions workflow. `Makefile` defines `check` and `lint`; `check` runs formatting, shellcheck, and Checkov, while `lint` runs Hadolint. No pull request execution of these targets is present in the current workflow directory.

# Boundaries and decisions

Add validation before image build automation. Pin third-party actions and tools according to the repository's workflow practice. Keep any required branch protection change as a named external system step, after the check names exist.

# Validation and acceptance criteria

- A pull request changing scripts, Dockerfiles, or configuration triggers checks for shell formatting, shell analysis, Dockerfile lint, and Checkov.
- A failed check makes the workflow fail; the workflow does not rewrite source files.
- Documentation names the exact status check to require in GitHub branch protection.

# Execution phases

## CI-01 — Add read-only source validation

- Status: ready
- Budget: 5 active hours maximum
- Prerequisites: none
- Exact write set: `.github/workflows/validate.yml`
- Primary integration lock: pull request validation workflow
- Outcome: A pull request workflow runs the shell, Dockerfile, and configuration checks with pinned actions and deterministic tool versions.
- Focused validation: parse the workflow YAML, run `actionlint` if available, and inspect a pull request run in GitHub Actions.
- Handoff: Record job names and the first passing run; make CI-02 ready.

## CI-02 — Document the branch protection gate

- Status: planned
- Budget: 2 active hours maximum
- Prerequisites: CI-01
- Exact write set: `.github/CONTRIBUTING.md`
- Primary integration lock: pull request validation workflow
- Outcome: Contributor instructions name the validation jobs and how maintainers make them required in GitHub branch protection.
- Focused validation: compare documented job names with `.github/workflows/validate.yml` and inspect the linked pull request run.
- Handoff: Record the configured status in GitHub branch protection if available; otherwise leave that external operation explicit and retire only after acceptance criteria hold.
