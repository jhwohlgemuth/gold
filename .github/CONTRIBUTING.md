# Getting Started

- Read this guide (including the [Code of Conduct](CODE_OF_CONDUCT.md))
- Check out our [Trello page](https://trello.com/b/WEMB9CEL/gold) to see what features and fixes are planned
- Fork this repository and clone your fork locally
- [Setup your environment](#project-setup) to use development tasks (test, lint, etc...)
- Adhere to the [project standards](#project-standards)
- Write some code and stuff
- Push your changes and create a pull request

## Code of Conduct
> Please read and adhere to the [code of conduct](CODE_OF_CONDUCT.md)

## Introduction
> First off, thank you for considering contributing to `Gold`!

If you would like to make a feature request or enhancement suggestion, please open an issue.

If you would like to generously provide a pull request to correct a verified issue, please adhere to this project's [standards](#project-standards). Before making a pull request for a desired feature, please socialize the concept by opening an issue first.

## Project Setup
> 🚧 UNDER CONSTRUCTION
### Requirements
- [Docker](https://www.docker.com/get-started/) and/or [Podman](https://podman.io/get-started)
- [dos2unix](https://dos2unix.sourceforge.io/#DOS2UNIX)
    - Format scripts for execution within a Unix environment
    - Used in [Makefile](../Makefile) `format` and `build-image` tasks
- [hadolint](https://github.com/hadolint/hadolint)
    - Analyze Dockerfiles
    - Configured via [.hadolint.yaml](../.hadolint.yaml)
- [yamllint](https://github.com/adrienverge/yamllint)
    - Analyze YAML files
    - Configure via [.yamllint](../.yamllint)
- [checkov](https://github.com/bridgecrewio/checkov)
    - Provides more checks for Dockerfiles and YAML files
    - Checks are security focused
    - Configure via [.checkov.yaml](../.checkov.yaml)
- [shfmt](https://github.com/patrickvane/shfmt)
    - Format shell scripts
    - Configured via [.editorconfig](../.editorconfig)
- [shellcheck](https://github.com/koalaman/shellcheck)
    - Analyze shell scripts

## Project Standards
- Code changes should never <sup>[1](#1)</sup> introduce issues detected by `make lint` or `make check`
- When in doubt, write code consistent with preponderance of existing codebase. Let's call this the "***priority of pre-existing preponderance (P3) rule***".
- Exceptions to any of these standards should be supported by strong reasoning and sufficient effort

-------------

## *Footnotes*

## [1]
> "Never" is strong language. Sometimes you might need to accept an issue or skip/ignore it. **BUT**, you should always have a good reason for doing so and such scenarios should be few and far between.
