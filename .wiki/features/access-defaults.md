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

`config/code-server/config.yaml` contains `auth: password` and `password: password`. `README.md` documents `password` as the code-server default and lists a Jupyter password default. `config/jupyter/jupyter_notebook_config.py` embeds a fixed password hash. The quick start publishes code-server port 1337. This establishes shared image defaults; it does not establish whether a runtime override is already applied in any deployment.

# Boundaries and decisions

Preserve password authentication and the existing service ports. Decide how the entrypoint rejects a missing credential or generates a unique one, then document how a user obtains it. Do not claim TLS trust from the image's self-signed certificate.

# Validation and acceptance criteria

- A fresh container has no known reusable browser login.
- A supplied credential works for code-server and Jupyter, and a missing or invalid credential cannot log in.
- The quick start and environment documentation match actual runtime behavior.

# Execution phases

## AD-01 — Remove the reusable code-server password

- Status: ready
- Budget: 5 active hours maximum
- Prerequisites: none
- Exact write set: `config/code-server/config.yaml`, `config/code-server/service/run`, `config/code-server/service/finish`
- Primary integration lock: browser service authentication
- Outcome: code-server starts with an operator supplied secret or an individually generated secret, with a clear startup failure or retrieval path.
- Focused validation: inspect rendered service config and run a local container login check when Docker is available; run `shellcheck config/code-server/service/run config/code-server/service/finish`.
- Handoff: Record the startup and login result, then make AD-02 ready.

## AD-02 — Align Jupyter credentials and user instructions

- Status: planned
- Budget: 5 active hours maximum
- Prerequisites: AD-01
- Exact write set: `config/jupyter/jupyter_notebook_config.py`, `config/jupyter/service/run`, `README.md`
- Primary integration lock: browser service authentication
- Outcome: Jupyter uses a container-specific or supplied credential and the quick start explains both service login paths.
- Focused validation: start a fresh notebook container with and without supplied credentials; verify accepted and rejected logins on ports 1337 and 13337.
- Handoff: Preserve the tested login contract in README and retire the plan when criteria hold.
