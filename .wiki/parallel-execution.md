# Execution lanes

Each active phase holds its primary integration lock. Serialize phases whose exact write sets overlap.

| Plan | Primary lock | Phases |
|---|---|---|
| [Midas CLI](features/midas-cli.md) | terminal image packaging; dotfiles command distribution | MID-02, MID-03 |
| [Access defaults](features/access-defaults.md) | browser service authentication | AD-02 |
| [Image build matrix](features/image-build-matrix.md) | image build verification | IM-01, IM-02, IM-03 |
| [CI validation](features/ci-validation.md) | pull request validation workflow | CI-01, CI-02 |

MID-02 and IM-01 both use Terminal image build validation; run them serially. IM-01 through IM-03 use the same build record and must run in order. AD-02 and CI-01 have separate write sets and may proceed independently; CI-01 waits on a published PR run. AD-02 owns README login instructions after the entry-documentation repair. Narrow MID-02's repository-wide write set to exact files before parallel implementation. Inspect the current diff before starting new work.
