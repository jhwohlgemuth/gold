# Execution lanes

Each active phase holds its primary integration lock. Serialize phases whose exact write sets overlap.

| Plan | Primary lock | Phases |
|---|---|---|
| [Midas CLI](features/midas-cli.md) | terminal image packaging; dotfiles command distribution | MID-02, MID-03 |
| [Image build matrix](features/image-build-matrix.md) | image build verification | IM-01, IM-02, IM-03 |
| [Required CI checks](features/ci-validation.md) | required PR check enforcement | CI-03 |

MID-02 and IM-01 both use Terminal image build validation; run them serially. IM-01 through IM-03 use the same build record and must run in order. CI-03 updates GitHub rules and the dated contributor-documentation status independently of image work. Narrow MID-02's repository-wide write set to exact files before parallel implementation. Inspect the current diff before starting new work.
