# Gold planning portfolio

This portfolio contains 5 executable plans. It tracks remaining work against the working tree inspected on 2026-10-24 at `bda6457`. Several image-build files already have local changes; recheck their diff before executing a phase and preserve those edits.

| Rank | Plan | Impact | Readiness | Remaining outcome |
|---|---|---|---|---|
| 1 | [Package the Rust midas CLI](features/midas-cli.md) | high | ready | Install the Rust command in Terminal images, then retire the shell script |
| 2 | [Replace shipped access defaults](features/access-defaults.md) | high | ready | Require an operator supplied credential for browser services |
| 3 | [Verify image architecture builds](features/image-build-matrix.md) | high | blocked on Docker builders | Establish terminal, notebook, and Gold build and smoke evidence |
| 4 | [Run validation on pull requests](features/ci-validation.md) | high | ready | Make repository checks execute in GitHub Actions |
| 5 | [Repair project entry documentation](features/documentation-links.md) | medium | ready | Remove dead local links and align build instructions |

The [feature index](features/index.md) is the nearest index. [Dependency network](plan-network.md) records actual gates, and [execution lanes](parallel-execution.md) records write collisions. After any wiki edit, run `python3 .agents/skills/planning/scripts/validate_wiki.py .`.
