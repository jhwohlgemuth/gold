# Gold planning portfolio

This portfolio contains 4 executable plans. Baseline `5000ee6` was clean on 2026-11-11; architecture changes were already committed in `4235e12`. The current access, CI, and documentation implementation is tracked in [progress.md](../progress.md). Entry-link and build-target repairs are preserved in README, ARCHITECTURE, and the release agent configuration.

| Rank | Plan | Impact | Readiness | Remaining outcome |
|---|---|---|---|---|
| 1 | [Replace shipped access defaults](features/access-defaults.md) | high | AD-02 ready | Align Jupyter with the implemented code-server credential contract |
| 2 | [Run validation on pull requests](features/ci-validation.md) | high | CI-01 awaits first GitHub PR run | Verify the implemented workflow on GitHub and document required checks |
| 3 | [Package the Rust midas CLI](features/midas-cli.md) | high | ready after exact write-set clarification | Install the Rust command in Terminal images, then retire the shell script |
| 4 | [Verify image architecture builds](features/image-build-matrix.md) | high | remote builders available; select explicit contexts | Establish terminal, notebook, and Gold build and smoke evidence |

The [feature index](features/index.md) is the nearest index. [Dependency network](plan-network.md) records actual gates, and [execution lanes](parallel-execution.md) records write collisions. After any wiki edit, run `python3 .agents/skills/planning/scripts/validate_wiki.py .`.
