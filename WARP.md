# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Gold is a containerized development environment for working on provably correct software. The project builds three layered Docker images:
- **Terminal** (`ghcr.io/jhwohlgemuth/terminal`) - Base image with system dependencies
- **Notebook** (`ghcr.io/jhwohlgemuth/notebook`) - Adds Jupyter, code-server (VS Code), and Verdaccio
- **Gold** (`ghcr.io/jhwohlgemuth/gold`) - Adds Rust, WebAssembly, proof assistants (Rocq, Lean), and formal verification tools

Image dependency chain: `terminal` → `notebook` → `gold`

## Common Development Commands

### Preparation and Validation
```bash
# Run all preparation steps (convert, lint, check)
make prepare

# Validate shell scripts and configuration
make check

# Lint Dockerfiles and YAML files
make lint

# Convert line endings to Unix format
make convert
```

### Building Images
```bash
# Build all images
make images

# Build individual images
make terminal-image
make notebook-image
make gold-image
```

### Publishing Images
```bash
# Push all images to ghcr.io
make push-all

# Push individual images
make push-terminal
make push-notebook
make push-gold
```

### Documentation
```bash
# Generate CHANGELOG.md (requires GITHUB_TOKEN environment variable)
make changelog
```

## Development Tools Required

The following tools are required for local development:
- **Docker** or **Podman** - Container runtime
- **dos2unix** - Convert line endings for Unix environments
- **hadolint** - Dockerfile linter (configured via `.hadolint.yaml`)
- **yamllint** - YAML validator (configured via `.yamllint.yaml`)
- **checkov** - Infrastructure-as-code security scanner (configured via `.checkov.yaml`)
- **shfmt** - Shell script formatter (configured via `.editorconfig`)
- **shellcheck** - Shell script analyzer (configured via `.shellcheckrc`)

See `.github/CONTRIBUTING.md` for installation instructions.

## Architecture

### Image Layering
Each image builds on the previous one:
1. **Terminal** (`Dockerfile.terminal`) - Starts from `bitnami/minideb:bookworm`, installs system dependencies, creates non-root user, sets up shell environment (zsh, Oh My Zsh), installs Homebrew, Nix, pkgx, and .NET
2. **Notebook** (`Dockerfile.notebook`) - Adds code-server, Jupyter Lab, Marimo, Verdaccio, conda/mamba environments, and configures s6-overlay service management
3. **Gold** (`Dockerfile`) - Adds Rust toolchain (with nightly and musl target), evcxr (Rust REPL/Jupyter kernel), Lean 4, Rocq (Coq) proof assistant via opam/elan

### Service Management
Services in notebook and gold images are managed by **s6-overlay**. Service definitions are in `config/`:
- `config/code-server/service/` - Browser-based VS Code (port 1337)
- `config/jupyter/service/` - Jupyter Lab server (port 13337)
- `config/marimo/service/` - Marimo notebook server (port 13338)
- `config/verdaccio/service/` - Private npm registry proxy (port 4873)

### Provisioning Scripts
Shell scripts in `provision/` handle image setup:
- `provision/terminal/` - Base system configuration, user creation, locale, dependencies
- `provision/notebook/` - Notebook-specific dependencies and setup
- `provision/gold/` - Tools for formal verification and correctness
- `provision/healthcheck.sh` - Container health monitoring

## Project Standards

### Code Quality
- **Never** commit code that fails `make lint` or `make check`
- Use the "Priority of Pre-existing Preponderance (P3) rule": write code consistent with the existing codebase
- All shell scripts must pass shfmt formatting and shellcheck validation
- All Dockerfiles must pass hadolint validation
- All YAML files must pass yamllint validation

### Line Endings
- Scripts must use Unix line endings (LF, not CRLF)
- Run `make convert` before building images to ensure proper formatting
- This is critical for scripts to execute correctly within containers

### Container Customization
Key environment variables available for customization:
- `CODE_SERVER_PORT` - Code-server port (default: 1337)
- `CODE_SERVER_PASSWORD` - Code-server password (default: password)
- `JUPYTER_PORT` - Jupyter server port (default: 13337)
- `JUPYTER_PASSWORD_HASH` - Jupyter password hash
- `NPM_PROXY_PORT` - Verdaccio proxy port (default: 4873)

### Version Management
- Version is defined in `.env` file (`VERSION=1.0.0`)
- Images are tagged with both version-specific tags and `latest`
- Registry is defined in `.env` as `REGISTRY=ghcr.io`

## Testing and Development Workflow

1. **Before starting work:**
   - Ensure all required development tools are installed
   - Run `make prepare` to validate the current state

2. **During development:**
   - Edit Dockerfiles, shell scripts, or configuration files
   - Run `make check` to validate shell scripts
   - Run `make lint` to validate Dockerfiles and YAML
   - Test changes by building the affected image locally

3. **Before committing:**
   - Run `make prepare` to ensure all validations pass
   - Test the built image to verify functionality
   - Update documentation if behavior changes

4. **Image build order:**
   - If changing terminal dependencies, rebuild: terminal → notebook → gold
   - If changing notebook dependencies, rebuild: notebook → gold
   - If changing gold dependencies, rebuild: gold only

## Important Notes

### Windows Development
This repository is designed to work in Windows environments (PowerShell) but builds Linux containers:
- Use PowerShell commands for local operations
- Scripts within containers use bash/zsh
- Line ending conversion (dos2unix) is critical for cross-platform compatibility

### Multi-stage Image Design
The three-image structure allows:
- Reuse of base layers to speed up builds
- Smaller terminal-only images for lightweight development
- Full-featured gold image for formal verification work
- Independent versioning and deployment of each layer

### Container Features
The gold container includes:
- Browser-based VS Code via code-server
- Jupyter Lab for interactive notebooks
- Multiple language kernels (Python, Rust via evcxr)
- Proof assistants: Lean 4, Rocq (Coq)
- WebAssembly development tools
- Private npm registry for offline/airgapped workflows
