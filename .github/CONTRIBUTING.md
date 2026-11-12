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
    - Used by the [Makefile](../Makefile) `convert` target
- [hadolint](https://github.com/hadolint/hadolint)
    - Analyze Dockerfiles
    - Configured via [.hadolint.yaml](../.hadolint.yaml)
- [yamllint](https://github.com/adrienverge/yamllint)
    - Analyze YAML files
    - Configure via [.yamllint.yaml](../.yamllint.yaml)
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

## Pull Request Validation

The [Validate workflow](workflows/validate.yml) runs on every pull request and supports manual dispatch. It checks source files without rewriting them. Contributors should wait for these three jobs to pass before merging:

| Exact status check name | Validation |
| --- | --- |
| `Shell validation` | shfmt and ShellCheck for provision scripts and the code-server run/finish scripts |
| `Dockerfile validation` | Hadolint for all three Dockerfiles; warnings and errors fail, informational diagnostics remain visible |
| `Configuration validation` | Checkov; policy failures and configuration parse errors fail, overriding the local soft-fail setting |

These are the job/check names, not the workflow name `Validate`. They passed on PR #7 in [run 43133232599](https://github.com/jhwohlgemuth/gold/actions/runs/43133232599). After pushing a fix, inspect the checks for the latest PR commit. Keep this table and the required-check configuration synchronized when renaming workflow jobs.

### Required Checks on Main

Verified on 2026-11-12 UTC: `main` is protected, but the three validation checks above are **not required by GitHub**. Classic branch protection has no required status checks. The active [main ruleset](https://github.com/jhwohlgemuth/gold/rules/1365542) requires CodeQL results and blocks branch deletion and force pushes; it has no required-status-check rule. Passing CI and enforcing it as a merge requirement are separate settings.

A maintainer with permission to edit repository rules can enable the gate:

1. Open repository **Settings → Rules → Rulesets** and edit the existing **main** ruleset targeting `main`.
2. Enable **Require status checks to pass before merging** and add `Shell validation`, `Dockerfile validation`, and `Configuration validation` exactly as listed above. Select **GitHub Actions** as the expected source where offered.
3. Keep enforcement **Active** and preserve the existing CodeQL, deletion, force-push, targeting, and bypass settings. Save the ruleset.
4. Re-read the effective rules for `main` and confirm all three names appear. On a PR targeting `main`, verify they are marked required; an actor without a bypass must be unable to merge while a required check is pending or failing.

GitHub documents [editing repository rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository) and [required status checks](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets#require-status-checks-to-pass-before-merging). Enabling this gate is a separate repository-settings operation; update the dated verification statement above after confirming it is active.

-------------

## *Footnotes*

## [1]
> "Never" is strong language. Sometimes you might need to accept an issue or skip/ignore it. **BUT**, you should always have a good reason for doing so and such scenarios should be few and far between.
