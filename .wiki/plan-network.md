# Dependency network

- [Midas CLI](features/midas-cli.md): MID-02 precedes MID-03. Install the Rust CLI in Gold Terminal images before retiring `my-shell-setup/gold/midas`.
- [Access defaults](features/access-defaults.md): AD-02 has no upstream plan blocker; the code-server credential contract is implemented and documented. Verify both browser services under the normal container startup path during AD-02.
- [Image build matrix](features/image-build-matrix.md): remote builders advertise amd64 and arm64 support; select an explicit working context for IM-01 because local Docker is unavailable. IM-02 follows IM-01; IM-03 follows IM-02. Advertised capability is not build/runtime evidence.
- [CI validation](features/ci-validation.md): CI-01 implementation passes local checks; its remaining gate is the first passing GitHub PR run after branch publication. CI-02 follows CI-01.

The plans have no cross-plan semantic dependencies. Review the parallel guide for shared file edits.
