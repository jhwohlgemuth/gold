# GitHub Agents Configuration

This document describes the GitHub Agents used in the Gold project for automation and AI-assisted development.

## Project Details

**Gold** is a containerized environment for working on provably correct software and more. The project maintains three Docker images with the following dependency structure:

- **Terminal** (`ghcr.io/jhwohlgemuth/terminal`) - Core image with system dependencies
- **Notebook** (`ghcr.io/jhwohlgemuth/notebook`) - Terminal + Jupyter, code-server, and Verdaccio services  
- **Gold** (`ghcr.io/jhwohlgemuth/gold`) - Notebook + Rust, WebAssembly, proof assistants, and correctness tools

**Key Capabilities:**
- Write and debug Rocq code in browser-based VS Code
- Rust-based provably correct software development
- WebAssembly development environments
- Interactive notebook support with Jupyter
- Proof assistants and formal verification tools

**Container Registry:** Images are built and deployed to GitHub Container Registry (`ghcr.io/jhwohlgemuth/`)

**Primary Tools:**
- [code-server](https://github.com/coder/code-server) - Browser-based IDE
- [Jupyter](https://jupyter.org/) - Interactive notebooks
- [Verdaccio](https://verdaccio.org/) - Private npm registry proxy
- [s6-overlay](https://github.com/just-containers/s6-overlay) - Service manager

## Overview

GitHub Agents are configured to assist with various development workflows including:
- Code analysis and quality checks
- Documentation generation
- Build and deployment automation
- Issue triage and routing
- Automated code reviews

## Agent Configurations

### Development Agent

**Location:** [.github/agents/development.yml](.github/agents/development.yml)

Handles day-to-day development tasks:
- Code quality analysis
- Automated formatting and linting
- Documentation updates
- Dependency management

**Trigger Events:**
- Pull requests
- Push to main branches
- Issue creation

### Release Agent

**Location:** [.github/agents/release.yml](.github/agents/release.yml)

Manages release workflows:
- Version bumping
- Changelog generation
- Docker image building and pushing
- Release note creation

**Trigger Events:**
- Release creation
- Version tag pushes

### Documentation Agent

**Location:** [.github/agents/documentation.yml](.github/agents/documentation.yml)

Maintains project documentation:
- Architecture documentation validation
- README consistency checks
- API documentation generation
- Example verification

**Trigger Events:**
- Documentation file changes
- Schema or configuration updates

### Security Agent

**Location:** [.github/agents/security.yml](.github/agents/security.yml)

Handles security-related tasks:
- Vulnerability scanning
- Dependency audits
- Security policy enforcement
- Secret detection

**Trigger Events:**
- Dependency updates
- Security-related issues
- Scheduled security scans

## Configuration Format

Agents use YAML configuration files with the following structure:

```yaml
name: Agent Name
description: Brief description of agent purpose
triggers:
  - event_type: trigger event
    conditions:
      - pattern matching conditions
enabled: true
rules:
  - action: action to perform
    when: conditions
    then: resulting behavior
```

## Usage Guidelines

### Adding New Agents

1. Create a new YAML file in `.github/agents/`
2. Define triggers, rules, and actions
3. Add documentation to this file
4. Enable in workflow if needed

### Modifying Existing Agents

1. Update the corresponding YAML file
2. Test changes in a feature branch
3. Document changes in PR description
4. Update this file if behavior changes

### Disabling Agents

Set `enabled: false` in the agent configuration file to temporarily disable an agent without removing it.

## Best Practices

- Keep agent configurations simple and focused
- Use clear, descriptive names for agent actions
- Document any custom logic or unusual patterns
- Regular review of agent execution logs
- Test agents in development before production use
- Version control all agent configurations

## Running Development Tasks

The Gold project uses GNU Make for common development tasks. The Makefile includes targets that align with the agents' responsibilities.

### Available Targets

**Code Quality & Validation:**
- `make prepare` - Run convert, lint, and check tasks
- `make check` - Validate shell scripts and configuration files (shfmt, shellcheck, checkov)
- `make convert` - Convert script line endings to Unix format (dos2unix)
- `make lint` - Validate Dockerfiles and YAML configuration (hadolint, yamllint)

**Image Building:**
- `make images` - Build all images (terminal, notebook, gold)
- `make terminal-image` - Build Terminal image only
- `make notebook-image` - Build Notebook image only
- `make gold-image` - Build Gold image with version tag

**Publishing:**
- `make push-all` - Push all images to container registry
- `make push-terminal` - Push Terminal image
- `make push-notebook` - Push Notebook image
- `make push-gold` - Push Gold image

**Documentation:**
- `make changelog` - Generate CHANGELOG.md using git-cliff

### Running a Development Task

```bash
# Run all preparation checks before committing
make prepare

# Build and test a specific image
make terminal-image

# Generate changelog (requires GITHUB_TOKEN environment variable)
make changelog
```

### Development Workflow

1. **Before Starting Work:**
   - Create a feature branch from `develop`
   - Set up required development tools (see [CONTRIBUTING.md](.github/CONTRIBUTING.md#project-setup))

2. **While Developing:**
   - Make code changes to scripts, Dockerfiles, or configuration
   - Regularly run `make check` and `make lint` to validate changes
   - Commit changes with clear messages

3. **Before Creating a Pull Request:**
   - Run `make prepare` to ensure all checks pass
   - Update documentation if behavior or features changed
   - Test image builds locally with appropriate `make` target

4. **During Code Review:**
   - Development Agent automatically runs on pull requests
   - Security Agent scans for vulnerabilities
   - Documentation Agent validates markdown and links
   - Address any reported issues in follow-up commits

## Project Requirements

Development work requires the following tools:

- **Docker** or **Podman** - Container runtime
- **dos2unix** - Unix line ending converter
- **hadolint** - Dockerfile linter
- **yamllint** - YAML validator
- **checkov** - Infrastructure-as-code scanner
- **shfmt** - Shell script formatter
- **shellcheck** - Shell script analyzer

See [CONTRIBUTING.md](.github/CONTRIBUTING.md#project-setup) for installation instructions.

## Agent Workflow Triggers

### Pull Request Workflow

When you open a pull request:

1. **Development Agent** runs:
   - Validates shell scripts and configuration files
   - Checks Dockerfile syntax and best practices
   - Ensures YAML files are properly formatted

2. **Documentation Agent** runs:
   - Validates markdown syntax
   - Checks all internal links are valid
   - Verifies code examples if present

3. **Security Agent** runs:
   - Scans Dockerfiles for vulnerabilities
   - Detects potential secrets in code
   - Audits dependencies

### Release Workflow

When you create a release or push a version tag:

1. **Release Agent** triggers:
   - Builds all Docker images with version tags
   - Pushes images to container registry
   - Updates release notes with image information

### Continuous Scanning

**Security Agent** runs scheduled weekly scans:
- Full security audit across the codebase
- Vulnerability detection in dependencies
- Infrastructure-as-code validation

## Contributing Guidelines

### For Feature Development

1. **Start with an issue:**
   - Open an issue describing the feature or enhancement
   - Discuss the approach with maintainers
   - Get feedback before implementing

2. **Create a pull request:**
   - Branch from `develop`
   - Follow [project standards](#project-standards)
   - Ensure all agent checks pass
   - Include clear description of changes

3. **Code Review:**
   - Address review comments promptly
   - Push additional commits to the same branch
   - Agents will automatically re-run on updates

### For Bug Fixes

1. **Verify the bug:**
   - Create an issue with clear reproduction steps
   - Provide context about the environment

2. **Implement the fix:**
   - Branch from the affected branch (usually `main` or `develop`)
   - Add test cases if applicable
   - Ensure all automated checks pass

### Project Standards

- **Code Quality:** Never introduce issues detected by `make lint` or `make check`
- **Consistency:** Follow the preponderance of existing codebase patterns (P3 rule)
- **Documentation:** Update docs when behavior or features change
- **Testing:** Test changes locally before pushing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for additional details.

## Related Documentation

- [Contributing Guidelines](.github/CONTRIBUTING.md)
- [Workflows Documentation](.github/workflows/)
- [Architecture Guide](ARCHITECTURE.md)
