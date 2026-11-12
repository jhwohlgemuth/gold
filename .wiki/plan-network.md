# Dependency network

- [Midas CLI](features/midas-cli.md): MID-02 precedes MID-03. Install the Rust CLI in Gold Terminal images before retiring `my-shell-setup/gold/midas`.
- [Image build matrix](features/image-build-matrix.md): remote builders advertise amd64 and arm64 support; select an explicit working context for IM-01 because local Docker is unavailable. IM-02 follows IM-01; IM-03 follows IM-02. Advertised capability is not build/runtime evidence.
- [Required CI checks](features/ci-validation.md): workflow and contributor documentation exist; CI-03 is the remaining GitHub ruleset operation. It has no upstream plan dependency and requires repository rules editing access.

The plans have no cross-plan semantic dependencies. Review the parallel guide for shared file edits.
