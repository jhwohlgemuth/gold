---
type: Plan
title: Repair project entry documentation
description: Make repository-local entry links and build instructions match the current tree.
difficulty: low
impact: medium
package: [documentation]
tags: [readme, architecture, links]
status: planned
execution: phased
phase_budget_hours: 5
---

# Goal

Ensure the first two project documents lead to existing resources and describe supported build targets.

# Current evidence

`README.md` links to `./examples/` and `./goldsmith/README.md`, and `ARCHITECTURE.md` also links to `./goldsmith/README.md`; neither directory exists in this worktree. `README.md` still has placeholder project sections. The current `Makefile` contains `gold-image-amd64` but no `gold-image` target, while `.github/agents/release.yml` still names `gold-image` as a manual target. Those facts should be reconciled without assuming how Goldsmith's separate repository is published.

# Boundaries and decisions

Fix only verified local navigation and build instructions. Preserve useful historical context where a stable external link can be verified.

# Validation and acceptance criteria

- No local link in README or ARCHITECTURE points to a missing path.
- Supported image build targets are described accurately; examples and Goldsmith references lead to verified destinations or are removed.
- The release agent target mismatch is either corrected or explicitly tracked with current instructions.

# Execution phases

## DOC-01 — Repair entry links and target descriptions

- Status: ready
- Budget: 5 active hours maximum
- Prerequisites: none
- Exact write set: `README.md`, `ARCHITECTURE.md`, `.github/agents/release.yml`
- Primary integration lock: project entry documentation
- Outcome: Entry documents use working links and the release agent's target names match the Makefile's supported build path.
- Focused validation: check each local Markdown link resolves and run `make -n gold-image-amd64` plus a YAML parse of `.github/agents/release.yml`.
- Handoff: Record any external Goldsmith URL verified and retire the plan once all acceptance criteria hold.
