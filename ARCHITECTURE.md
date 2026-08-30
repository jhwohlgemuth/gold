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

## Lean MCP Service

`config/mcp-lean/service` defines the s6 service `mcp-lean` (lean-lsp-mcp 0.30.0 via `uv 0.8.22`, `Dockerfile:16,34`). It runs alongside `code-server`, `jupyter`, `marimo` and `verdaccio` under s6-overlay (`/etc/services.d/mcp-lean`), listening on `MCP_LEAN_PORT=11005` (streamable-http, `LEAN_PROJECT_PATH`, `LEAN_LOG_LEVEL`). The image already ships `nixpkgs.elan`, so no sidecar or `lean-cache`/`elan` volumes are needed.

## Related Environments

[Goldsmith](./goldsmith/README.md), formerly Gold's agentic image, is maintained
as a separate product. Its initial release consumes a pinned Notebook image as a
documented base-image dependency while keeping its versioning, runtime services,
and release lifecycle independent from Gold. Formal verification (Lean LSP MCP, formerly Goldsmith's `mcp-lean --profile formal` sidecar) now lives in Gold as an s6 service alongside code-server/Jupyter.

## Service Topology

```mermaid
graph LR
    subgraph Gold["Gold container / s6"]
        Code["code-server :1337"]
        Jupyter["jupyter :13337"]
        Marimo["marimo :13338"]
        Verdaccio["verdaccio :4873"]
        Lean["mcp-lean :11005"]
    end
```

-------------

## Footnotes

### [1]
> Default Verdaccio proxy npm registry port is `4873` ([documentation](https://verdaccio.org/docs/configuration#listen-port))
