# Gold planning portfolio

This portfolio contains 3 executable plans. Baseline `87ad2c6` was clean after merging PR #8; architecture changes were already committed in `4235e12`. The current execution handoff is tracked in [progress.md](../progress.md). Browser credential requirements are implemented in service configuration and documented in README; entry-link and build-target repairs are preserved in README, ARCHITECTURE, and the release agent configuration.

| Rank | Plan | Impact | Readiness | Remaining outcome |
|---|---|---|---|---|
| 1 | [Require validation checks on main](features/ci-validation.md) | high | CI-03 planned; external settings | Enable the three documented checks in the existing main ruleset |
| 2 | [Package the Rust midas CLI](features/midas-cli.md) | high | ready after exact write-set clarification | Install the Rust command in Terminal images, then retire the shell script |
| 3 | [Verify image architecture builds](features/image-build-matrix.md) | high | remote builders available; select explicit contexts | Establish terminal, notebook, and Gold build and smoke evidence |

The [feature index](features/index.md) is the nearest index. [Dependency network](plan-network.md) records actual gates, and [execution lanes](parallel-execution.md) records write collisions. After any wiki edit, run `python3 .agents/skills/planning/scripts/validate_wiki.py .`.
