# Project Architecture
> 🚧 UNDER CONSTRUCTION

## Image Design
> [!NOTE]
> Images are built using GitHub Actions and deployed to the Github Container Registry, `ghcr.io`, under the username, `jhwohlgemuth`

The following images are available:
- `ghcr.io/jhwohlgemuth/terminal`: Core image with all necessary system dependencies (intended for terminal-only development)
- `ghcr.io/jhwohlgemuth/notebook`: Images with [Jupyter notebook](https://github.com/jupyter/notebook) server, [code-server](https://github.com/coder/code-server) and [Verdaccio](https://verdaccio.org/) proxy npm registry <sup>[1](#1)</sup> services managed by [s6-overlay](https://github.com/just-containers/s6-overlay)
- `ghcr.io/jhwohlgemuth/gold`: The primary purpose of this repository.
    - All the features of `notebook`
    - Rust and WebAssembly (WASM) development environment
    - Proof assistants
    - Provers
    - Other tools for software correctness

The images are build according to the following dependency graph:
```mermaid
graph LR
    terminal --> notebook
    notebook --> gold
```

## Related Environments

[Goldsmith](./goldsmith/README.md), formerly Gold's agentic image, is maintained
as a separate product. Its initial release consumes a pinned Notebook image as a
documented base-image dependency while keeping its versioning, runtime services,
and release lifecycle independent from Gold.

-------------

## Footnotes

### [1]
> Default Verdaccio proxy npm registry port is `4873` ([documentation](https://verdaccio.org/docs/configuration#listen-port))
