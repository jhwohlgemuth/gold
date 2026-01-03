# 🏅 Gold &nbsp;
[![CodeFactor](https://www.codefactor.io/repository/github/jhwohlgemuth/gold/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jhwohlgemuth/gold)
[![Code Size](https://img.shields.io/github/languages/code-size/jhwohlgemuth/gold.svg?style=for-the-badge)](#quick-start)

> Gold is a containerized environment for working on provably correct software [and more](#things-you-can-do-with-gold)

## Quick Start

Use VS Code in the browser in **Three Easy Steps™**

1. Install [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/)
2. Run the command <sup>[1](#1)</sup>
    ```shell
    docker run -it \
        --privileged \
        --name gold \
        --hostname $(hostname) \
        -p 1337:1337 \
        ghcr.io/jhwohlgemuth/gold
    ```
3. Open a browser and navigate to [https://localhost:1337](https://localhost:1337) <sup>[2](#2)</sup>

> [!TIP]
> See [Container Customization section](#container-customization) for more details on how to customize the container.

## What is Gold?
> 🚧 UNDER CONSTRUCTION

## So what, big deal, who cares?
> 🚧 UNDER CONSTRUCTION


## Things you can do with Gold
> [!TIP]
> See the [examples directory](./examples/) for details on all the things you can do with Gold.

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
  - Default: `password`
- `JUPYTER_CONFIG`: Location of code-server server configuration file (within container)
  - Default: `/root/.jupyter/jupyter_notebook_config.py`
- `JUPYTER_PORT`: Port to use for Jupyter server
  - Default: `13337`
- `JUPYTER_PASSWORD_HASH`: Password to use for Jupyter server
  - Default: `password`

> [!TIP]
> Change environment variables with the `--env` parameter <sup>[4](#4)</sup> (ex. `docker run -it --env CODE_SERVER_PORT=8080 <image>`)

## Architecture
> [!TIP]
> See [ARCHITECTURE.md](./ARCHITECTURE.md)

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
