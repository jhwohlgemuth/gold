# Dependency network

- [Midas CLI](plans/midas-cli.md): MID-02 precedes MID-03. Install the Rust CLI in Gold Terminal images before retiring `my-shell-setup/gold/midas`.
- [Access defaults](plans/access-defaults.md): no upstream plan blocker. AD-02 follows AD-01.
- [Image build matrix](plans/image-build-matrix.md): IM-01 needs a working amd64 and arm64 Docker builder; IM-02 follows IM-01; IM-03 follows IM-02. This is an external availability gate, not phase work.
- [CI validation](plans/ci-validation.md): no upstream plan blocker. CI-02 follows CI-01.
- [Documentation links](plans/documentation-links.md): no upstream plan blocker.

The plans have no cross-plan semantic dependencies. Review the parallel guide for shared file edits.
