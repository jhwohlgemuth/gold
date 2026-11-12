---
type: Plan
title: Run validation on pull requests
description: Add an actual GitHub Actions validation workflow for repository checks.
difficulty: medium
impact: high
package: [github-actions, build]
tags: [ci, lint, shell, dockerfile]
status: waiting-on-validation
execution: phased
phase_budget_hours: 5
---

# Goal

Make code quality checks visible as required pull request results.

# Current evidence

`.github/workflows/validate.yml` now defines PR and manual validation with SHA-pinned actions, checksum-verified shell/Dockerfile tools, and fixed Checkov/Python versions. The jobs are `Shell validation`, `Dockerfile validation`, and `Configuration validation`. Local validation passed with actionlint 1.7.7, shfmt 3.12.0, ShellCheck 0.11.0, Hadolint 2.15.1, and Checkov 3.2.471 (589 Dockerfile and 84 Actions checks). Hadolint warnings/errors fail while informational diagnostics remain visible; negative fixtures confirmed warning and Checkov failure propagation. Checkov's wildcard hard-fail overrides `.checkov.yaml`'s soft-fail; parsing errors also fail. No GitHub PR run has occurred for this uncommitted implementation; see `progress.md` for the handoff.

# Boundaries and decisions

Add validation before image build automation. Pin third-party actions and tools according to the repository's workflow practice. Keep any required branch protection change as a named external system step, after the check names exist.

# Validation and acceptance criteria

- A pull request changing scripts, Dockerfiles, or configuration triggers checks for shell formatting, shell analysis, Dockerfile lint, and Checkov.
- A failed check makes the workflow fail; the workflow does not rewrite source files.
- Documentation names the exact status check to require in GitHub branch protection.

# Execution phases

## CI-01 — Verify read-only source validation on GitHub

- Status: blocked
- Budget: 5 active hours maximum
- Prerequisites: publish the implementation branch and open a pull request so GitHub Actions can run the new workflow
- Exact write set: GitHub Actions for `jhwohlgemuth/gold`, `.github/workflows/validate.yml` for workflow-specific corrections
- Primary integration lock: pull request validation workflow
- Outcome: Record the first passing PR run of the implemented workflow and its exact status check names.
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
