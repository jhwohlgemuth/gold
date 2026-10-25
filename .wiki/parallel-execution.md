# Execution lanes

Each active phase holds its primary integration lock. Serialize phases whose exact write sets overlap.

| Plan | Primary lock | Phases |
|---|---|---|
| [Midas CLI](features/midas-cli.md) | terminal image packaging; dotfiles command distribution | MID-02, MID-03 |
| [Access defaults](features/access-defaults.md) | browser service authentication | AD-01, AD-02 |
| [Image build matrix](features/image-build-matrix.md) | image build verification | IM-01, IM-02, IM-03 |
| [CI validation](features/ci-validation.md) | pull request validation workflow | CI-01, CI-02 |
| [Documentation links](features/documentation-links.md) | project entry documentation | DOC-01 |

MID-02 and IM-01 both use Terminal image build validation; run them serially. AD-02 and DOC-01 both write `README.md`; run them serially. IM-01 through IM-03 use the same build record and must run in order. Existing local edits to `Makefile`, Dockerfiles, `AGENTS.md`, and `ARCHITECTURE.md` are outside these initial phase write sets; inspect them before changing scope.
