# Dependency network

- [Midas CLI](features/midas-cli.md): MID-02 precedes MID-03. Install the Rust CLI in Gold Terminal images before retiring `my-shell-setup/gold/midas`.
- [Image build matrix](features/image-build-matrix.md): remote builders advertise amd64 and arm64 support; select an explicit working context for IM-01 because local Docker is unavailable. IM-02 follows IM-01; IM-03 follows IM-02. Advertised capability is not build/runtime evidence.
- [CI validation](features/ci-validation.md): the workflow passed on PR #7 and is merged; CI-02 is ready to document required checks and external branch-protection status.

The plans have no cross-plan semantic dependencies. Review the parallel guide for shared file edits.
