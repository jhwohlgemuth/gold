---
type: Plan
title: Replace shipped access defaults
description: Make browser service access require a credential supplied by the container operator.
difficulty: medium
impact: high
package: [notebook, code-server, jupyter]
tags: [authentication, configuration, container]
status: planned
execution: phased
phase_budget_hours: 5
---

# Goal

Make the published quick start safe to expose on a host without a shared, documented password.

# Current evidence

Code-server no longer ships a password. Its service requires `CODE_SERVER_PASSWORD` or `CODE_SERVER_PASSWORD_HASH`, forces password authentication, and passes secrets through native environment variables without editing configuration. README documents startup and hash precedence. On 2026-11-11, ShellCheck and shfmt passed, and actual HTTPS login tests passed using the changed files in an existing Notebook 1.0.5-amd64 container on Docker context `oklahoma`: missing/empty credentials fail, wrong/default credentials are rejected, supplied plaintext/hash credentials work, custom auth/hash behavior is enforced, and config remains unchanged. See `progress.md` for image identity and test details. A separate full `/init`/s6 smoke attempt yielded no result and remains unverified; no new full image was built. Jupyter's config and service still contain a fixed password hash, so browser credential migration is not yet complete.

# Boundaries and decisions

Preserve password authentication and the existing service ports. Code-server now rejects a missing operator supplied credential. Align Jupyter's credential contract and document its startup behavior without claiming TLS trust from the image's self-signed certificate.

# Validation and acceptance criteria

- A fresh container has no known reusable browser login.
- A supplied credential works for code-server and Jupyter, and a missing or invalid credential cannot log in.
- The quick start and environment documentation match actual runtime behavior.

# Execution phases

## AD-02 — Align Jupyter credentials and user instructions

- Status: ready
- Budget: 5 active hours maximum
- Prerequisites: none; code-server's operator-supplied credential contract is implemented and documented
- Exact write set: `config/jupyter/jupyter_notebook_config.py`, `config/jupyter/service/run`, `README.md`
- Primary integration lock: browser service authentication
- Outcome: Jupyter uses a container-specific or supplied credential and the quick start explains both service login paths.
- Focused validation: start a fresh notebook container with and without supplied credentials; verify accepted and rejected logins on ports 1337 and 13337.
- Handoff: Preserve the tested login contract in README and retire the plan when criteria hold.
