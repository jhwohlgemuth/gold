---
type: Plan
title: Verify image architecture builds
description: Prove the current architecture work builds and starts in the intended terminal, notebook, and Gold matrix.
difficulty: high
impact: high
package: [terminal, notebook, gold]
tags: [docker, arm64, amd64, release]
status: waiting-on-validation
execution: phased
phase_budget_hours: 5
---

# Goal

Record reproducible build and startup evidence before advertising the new architecture paths as publishable.

# Current evidence

The working tree changes `Makefile` to define terminal and notebook amd64/arm64 targets and a Gold amd64 target; it changes s6 archive selection in `Dockerfile.terminal`, introduces `provision/notebook/install_conda.sh`, and changes ARM64 .NET/PowerShell installation. `ARCHITECTURE.md` calls out Terminal and Notebook 1.0.5 build paths. `docker info` failed here because no Docker daemon was available. No build or runtime pass is inferred from the target definitions.

# Boundaries and decisions

Keep this as validation of the existing local architecture changes. Record failures before proposing repairs; a failure requiring product edits becomes a separate bounded repair phase with an exact write set. Publishing is outside this plan.

# Validation and acceptance criteria

- Each documented architecture target produces an image for its named platform.
- Terminal and Notebook start on amd64 and arm64; Gold starts on amd64; service health and one representative tool command are recorded for each.
- `docs/image-build-matrix.md` records builder, command, digest or local image ID, result, and any limitation. A failed row remains explicit.

# Execution phases

## IM-01 — Verify Terminal on both architectures

- Status: blocked
- Budget: 5 active hours maximum
- Prerequisites: working amd64 and arm64 Docker builders
- Exact write set: `docs/image-build-matrix.md`
- Primary integration lock: image build verification
- Outcome: Record Terminal amd64 and arm64 build and shell smoke results, including s6 and PowerShell availability.
- Focused validation: `make terminal-image-amd64` and `make terminal-image-arm64`, then run each image on its target platform.
- Handoff: Save command, builder, image ID, and result for both rows; make IM-02 ready only after the base-image gate passes.

## IM-02 — Verify Notebook on both architectures

- Status: planned
- Budget: 5 active hours maximum
- Prerequisites: IM-01
- Exact write set: `docs/image-build-matrix.md`
- Primary integration lock: image build verification
- Outcome: Record Notebook amd64 and arm64 build, service startup, and Miniforge installation results.
- Focused validation: `make notebook-image-amd64` and `make notebook-image-arm64`, followed by container health checks and `mamba --version`.
- Handoff: Save both platform results and make IM-03 ready when their base images work.

## IM-03 — Verify Gold amd64 inheritance

- Status: planned
- Budget: 5 active hours maximum
- Prerequisites: IM-02
- Exact write set: `docs/image-build-matrix.md`
- Primary integration lock: image build verification
- Outcome: Record whether Gold builds from the Notebook image and starts its Lean MCP service on amd64.
- Focused validation: `make gold-image-amd64`, then start the image and run `/healthcheck` plus a Lean MCP endpoint probe.
- Handoff: Keep build evidence in the matrix and retire this plan only when every required row passes.
