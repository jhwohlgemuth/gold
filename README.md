# 🏅 Gold &nbsp;
[![CodeFactor](https://www.codefactor.io/repository/github/jhwohlgemuth/gold/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jhwohlgemuth/gold)
[![Code Size](https://img.shields.io/github/languages/code-size/jhwohlgemuth/gold.svg?style=for-the-badge)](#quick-start)

> Gold is a containerized environment for working on provably correct software [and more](#things-you-can-do-with-gold)

## Quick Start

Use VS Code in the browser in **Three Easy Steps™**

1. Install [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/)
2. Export `CODE_SERVER_PASSWORD` and `JUPYTER_PASSWORD` in your shell with unique passwords, then run <sup>[1](#1)</sup>
    ```shell
    docker run -it \
        --privileged \
        --name gold \
        --hostname $(hostname) \
        --env CODE_SERVER_PASSWORD \
        --env JUPYTER_PASSWORD \
        -p 1337:1337 \
        -p 13337:13337 \
        ghcr.io/jhwohlgemuth/gold
    ```
3. Open [VS Code](https://localhost:1337) with `CODE_SERVER_PASSWORD` or [JupyterLab](https://localhost:13337/lab) with `JUPYTER_PASSWORD`. Both services use a self-signed certificate. <sup>[2](#2)</sup>

> [!TIP]
> See [Container Customization section](#container-customization) for more details on how to customize the container.

## What is Gold?
> 🚧 UNDER CONSTRUCTION

## So what, big deal, who cares?
> 🚧 UNDER CONSTRUCTION


## Things you can do with Gold

- Write, run, and debug [Rocq](https://rocq-prover.org/) code from within a browser-based instance of VSCode <sup>[3](#3)</sup>
- Work with modern [Rust](https://www.rust-lang.org/)-based projects to write provably correct software
- Spin up feature-rich development environments for use from a terminal or browser-based IDE <sup>[3](#3)</sup>
- Work with [WebAssembly](https://webassembly.org/)
- Quickly and easily compare multiple languages using interative notebooks
- 🚧 UNDER CONSTRUCTION


## Container Customization
> [!NOTE]
> Use [`install_extensions`](https://github.com/jhwohlgemuth/my-shell-setup/blob/main/gold/install_extensions) to install VS Code extensions.

> [!NOTE]
> [`install_extensions`](https://github.com/jhwohlgemuth/my-shell-setup/blob/main/gold/install_extensions) accepts any number of image names (see [Image Design section](./ARCHITECTURE.md#image-design))</br>
> *Example* `install_extensions development python rust`

The following environment variables are available to customize containers:
- `CODE_SERVER_CONFIG`: Location of code-server server configuration file (within container)
  - Default: `/app/code-server/config/config.yaml`
- `CODE_SERVER_PORT`: Port to use for code-server server
  - Default: `1337`
- `CODE_SERVER_PASSWORD`: Password to use for code-server server
  - Required unless `CODE_SERVER_PASSWORD_HASH` is supplied; there is no default password.
- `CODE_SERVER_PASSWORD_HASH`: Password hash to use for code-server server
  - Alternative to `CODE_SERVER_PASSWORD`; there is no default hash. Takes precedence when both are supplied.
- `JUPYTER_CONFIG`: Optional Python config file inside the container, loaded after the shipped Jupyter defaults and before the required credential settings.
  - Defaults come from `/home/nonroot/.jupyter/jupyter_notebook_config.py`; custom files are read without modification.
- `JUPYTER_PORT`: Port to use for Jupyter server
  - Default: `13337`
- `JUPYTER_PASSWORD`: Password to use for Jupyter server
  - Required unless `JUPYTER_PASSWORD_HASH` is supplied; there is no default password. Jupyter hashes it in memory.
- `JUPYTER_PASSWORD_HASH`: Jupyter-compatible password hash
  - Alternative to `JUPYTER_PASSWORD`; there is no default hash. Takes precedence when both are supplied.

> [!TIP]
> Change environment variables with the `--env` parameter <sup>[4](#4)</sup> (ex. `docker run -it --env CODE_SERVER_PORT=8080 <image>`)

Code-server refuses to start unless `CODE_SERVER_PASSWORD` or `CODE_SERVER_PASSWORD_HASH` is nonempty. A `hashed-password` in a custom `CODE_SERVER_CONFIG` takes precedence over a plaintext password; remove that field to use `CODE_SERVER_PASSWORD`, or override it with `CODE_SERVER_PASSWORD_HASH`.

Jupyter refuses to start unless `JUPYTER_PASSWORD` or `JUPYTER_PASSWORD_HASH` is nonempty. Supplied credentials override custom-config passwords. Jupyter token login and password changes through the login page are disabled; change the supplied credential and recreate the container to rotate it. Missing credentials keep the affected service unavailable and produce a startup error in `docker logs`.

To generate a Jupyter password hash interactively without putting the password in shell history, run:

```shell
docker run --rm -it --entrypoint /home/nonroot/miniconda3/bin/python \
    ghcr.io/jhwohlgemuth/notebook \
    -c 'from jupyter_server.auth import passwd; print(passwd())'
```

Export the result as `JUPYTER_PASSWORD_HASH` and pass it with `--env JUPYTER_PASSWORD_HASH` in place of `--env JUPYTER_PASSWORD`.

## Lean MCP Service

Gold runs the Lean LSP MCP server as an s6 service alongside code-server, Jupyter, Marimo and Verdaccio (migrated from Goldsmith's `mcp-lean` sidecar).

- **Service**: `/etc/services.d/mcp-lean` (`config/mcp-lean/service/run` — `lean-lsp-mcp --transport streamable-http --host 0.0.0.0 --port 11005`)
- **Image**: `ghcr.io/jhwohlgemuth/gold` now embeds `lean-lsp-mcp==0.30.0` via `uv==0.8.22` (see `Dockerfile:16,42`) and reuses `nixpkgs.elan`
- **Endpoint**: `http://127.0.0.1:11005/mcp` (published `EXPOSE 11005:11005`, in-container `http://127.0.0.1:11005/mcp`)
- **Env**: `LEAN_PROJECT_PATH` (default `~/dev` → `/home/nonroot/dev`, must contain `lean-toolchain` + `lakefile.lean|toml` for per-project mode), `MCP_LEAN_PORT`/`MCP_LEAN_HOST`, `LEAN_LOG_LEVEL` (default `INFO`)
- **Client config**: `http://127.0.0.1:11005/mcp` (see `config/agents/opencode.json:4` and `config/agents/codex.toml:3`)
- **Healthcheck**: `provision/healthcheck:40` probes `http://localhost:${MCP_LEAN_PORT}/mcp` (non-`--fail` GET, because Streamable HTTP returns 4xx when healthy)

Run `docker run -p 11005:11005 ghcr.io/jhwohlgemuth/gold` and the MCP is available without an extra Compose profile.

## Architecture
> [!TIP]
> See [ARCHITECTURE.md](./ARCHITECTURE.md)

## Building Images

Run these targets from the repository root with Docker available. See the [build target matrix](./ARCHITECTURE.md#build-targets) for architecture coverage and publishing targets.

```shell
make gold-image-amd64       # Builds Terminal, Notebook, then Gold for amd64
make notebook-image-arm64  # Builds Terminal, then Notebook for arm64
```

These targets build local images without publishing them. Build paths exist for both architectures, but successful builds and startup checks must be verified on the selected builder before publishing.

## Related Projects

- Goldsmith is the independently branded agentic
  development environment that originated in Gold.

## Contributing
> [!TIP]
> See [CONTRIBUTING.md](./.github/CONTRIBUTING.md)

![Alt](https://repobeats.axiom.co/api/embed/bf68a3bfeb0afd8dce0177958ff63b289d2c8d39.svg "Repobeats analytics image")

-------------

## Footnotes

### [1]
> `--privileged` is required to use [Apptainer](https://github.com/apptainer/apptainer) within the container

### [2]
> The default code-server port can be changed with the `CODE_SERVER_PORT` environment variable. See the [Container Customization section](#container-customization) for more details.

### [3]
> See [code-server](https://github.com/coder/code-server) project

### [4]
> See [docker run documentation](https://docs.docker.com/engine/reference/commandline/container_run/)
