---
type: Plan
title: Replace midas with a Gold Rust CLI
description: Package Gold's Rust midas CLI in images and retire the shell script.
difficulty: medium
impact: high
package: [gold, my-shell-setup]
tags: [rust, cli, dotfiles, migration]
status: planned
execution: phased
phase_budget_hours: 5
---

# Replace midas with a Gold Rust CLI

## Current evidence and decision

`my-shell-setup/gold/midas` still discards tracked edits with `git checkout -- .`. Gold now has a standalone `tools/midas` Rust crate. The CLI keeps `update`, `gold`, `opencode`, and `GOLD_DOTFILES`; it rejects a dirty checkout, pulls with `--ff-only`, and reports Git or Stow failures. Five temporary-repository integration tests pass, along with `cargo fmt --check` and Clippy. `../../Dockerfile.terminal` still installs these dotfiles before `../../Dockerfile` installs Rust, so image packaging remains.

Build a Linux binary for each supported terminal-image architecture, then replace the old stowed `/usr/local/bin/midas` link with that binary after dotfiles setup. Retire the shell script only after the image exposes the Rust command.

## Acceptance criteria

The installed CLI updates a clean checkout, refuses a dirty checkout without changing it, reports Git or Stow failure, and preserves the documented command arguments. Gold's terminal image contains the CLI on amd64 and arm64. `my-shell-setup` no longer installs the shell `midas`.

# Execution phases

## MID-02 — Package the CLI in Gold images

- Status: ready
- Budget: 5 active hours maximum
- Prerequisites: none.
- Exact write set: Gold repository `/Users/o9w/dev/gold`, terminal image build and its focused build validation.
- Primary integration lock: terminal image build.
- Outcome: The terminal image builds the CLI separately and replaces the legacy stowed command after dotfiles setup without requiring a runtime Rust toolchain.
- Focused validation: Build or smoke-test terminal images for Linux amd64 and arm64 and run `midas --help` inside each.
- Handoff: Record the installed binary path and image build evidence before retiring the shell script.

## MID-03 — Retire the shell script

- Status: planned
- Budget: 5 active hours maximum
- Prerequisites: MID-02.
- Exact write set: `my-shell-setup/gold/midas`, `my-shell-setup/Makefile`, `my-shell-setup/README.md`.
- Primary integration lock: dotfiles command distribution.
- Outcome: Remove the shell implementation, its formatting-list entry, and replace its usage documentation with the Gold CLI.
- Focused validation: Run `make check` if available, otherwise ShellCheck and shfmt checks for remaining scripts; confirm the Gold image's `midas` command is the only installed implementation.
- Handoff: Record the Gold release or commit supplying the replacement and the local diff.
