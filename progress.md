# Implementation — access, CI, and entry documentation

- Authorized scope: AD-01, CI-01, and DOC-01 only, executed in parallel with separate file ownership. AD-02 and CI-02 remain future work.
- Baseline: clean worktree at `5000ee6`; branch `feat/access-ci-docs` starts from `main` because no local or origin tracking `develop` branch exists. Changes remain uncommitted and unpublished.
- Active plans: [access defaults](.wiki/features/access-defaults.md) and [CI validation](.wiki/features/ci-validation.md). DOC-01 is retired; durable outcomes are in README, ARCHITECTURE, and the release agent configuration.
- State: AD-01 and DOC-01 complete; CI-01 implementation locally validated and waiting on its first GitHub PR run. Full `/init`/s6 smoke validation remains unverified; focused real-server login checks passed.
- Budget: estimated less than one active hour per selected phase; each has a five-hour maximum. External waiting does not consume active phase time.

## Authentication evidence

The code-server service requires a nonempty `CODE_SERVER_PASSWORD` or `CODE_SERVER_PASSWORD_HASH`, uses native credential environment variables, forces password authentication, and preserves custom configuration without secret interpolation. Supplied hashes win over plaintext. A custom configuration hash also wins over plaintext, as documented in README. Jupyter retains its existing default until AD-02.

Changed paths: `config/code-server/config.yaml`, `config/code-server/service/run`, `config/code-server/service/finish`. README quick-start alignment was included in DOC-01 to keep the new startup contract usable.

On 2026-11-11, actual HTTPS login checks passed on Docker context `oklahoma`, Notebook `1.0.5-amd64`, image `sha256:bab8ca98f4198de9f69e927718a1aac5775061acbdd174a43c7ec6549c490677`, code-server `4.143.1`, with the changed config and run script copied into a disposable container:

- Missing/empty credentials failed before launching the server, including when ambient native password variables were present.
- A password containing punctuation and a newline worked without configuration rewriting.
- Unauthenticated requests redirected to login; wrong/default passwords received no session cookie; correct credentials received a cookie and access to an authenticated route.
- Hash precedence, custom `auth: none` being overridden, custom hash precedence, and a supplied hash overriding the custom hash all passed.
- The shipped config checksum was unchanged.

Temporary reproduction harness: `/tmp/gold-ad01-test/check.sh`; it runs the changed service using `CODE_SERVER_CONFIG`, `CODE_SERVER_PORT=14437`, and temporary test credentials, and probes `/healthz`, `/`, and `/login` with curl. This validates the existing image with changed service files, not a fresh full-image build or the architecture matrix.

```sh
tar -cf - -C config/code-server config.yaml -C service run \
  -C /tmp/gold-ad01-test check.sh |
docker --context oklahoma run --rm -i --entrypoint /bin/bash \
  ghcr.io/jhwohlgemuth/notebook:1.0.5-amd64 \
  -c 'mkdir -p /tmp/gold-ad01; tar -xf - -C /tmp/gold-ad01; bash /tmp/gold-ad01/check.sh'
```

A separate full `/init`/s6 test using `/tmp/gold-ad01-test/check-s6.sh` was interrupted after 224 seconds without a result. It establishes neither a pass nor a defect. The earlier login container exited successfully with `--rm`; afterward `docker --context oklahoma ps -a --no-trunc` confirmed no remaining containers. Normal supervisor startup remains a verification item for AD-02's fresh-container checks.

## CI evidence and recovery

Changed path: `.github/workflows/validate.yml`. Jobs: **Shell validation**, **Dockerfile validation**, **Configuration validation**. PR/manual triggers, read-only contents permission, SHA-pinned actions, checksum-verified binary downloads, and fixed tool versions are implemented. Shell checks cover the existing provision scope and code-server run/finish scripts. Hadolint warnings/errors fail while informational diagnostics remain visible. Checkov uses `--hard-fail-on '*'` and `CKV_PARSE_ERROR_FAIL=true` to override local soft-fail and reject parse errors.

Local commands passed against the uncommitted implementation:

```sh
/tmp/gold-ci-actionlint/actionlint .github/workflows/validate.yml
ruby -ryaml -e 'p YAML.load_file(".github/workflows/validate.yml")["jobs"].keys'
/tmp/gold-ci-shfmt -d provision/healthcheck provision/terminal/*.sh provision/notebook/*.sh provision/gold/*.sh
/tmp/gold-ci-shfmt -d config/code-server/service/run config/code-server/service/finish
shellcheck provision/healthcheck provision/terminal/*.sh provision/notebook/*.sh provision/gold/*.sh
shellcheck --shell=bash config/code-server/service/run
shellcheck config/code-server/service/finish
hadolint --failure-threshold warning Dockerfile Dockerfile.terminal Dockerfile.notebook
CKV_PARSE_ERROR_FAIL=true UV_TOOL_DIR=/tmp/gold-ci-uv-tools uv --cache-dir /tmp/gold-ci-uv-cache tool run --python /opt/homebrew/bin/python3.11 --from checkov==3.2.471 checkov --config-file .checkov.yaml --hard-fail-on '*' --skip-download
```

Versions: actionlint 1.7.7, shfmt 3.12.0, ShellCheck 0.11.0, Hadolint 2.15.1, Checkov 3.2.471. Checkov passed 589 Dockerfile and 84 Actions checks. Hadolint retained seven existing informational DL3066 diagnostics. Deliberate temporary Hadolint warning and Checkov defect fixtures both exited 1. `--hard-fail-on ALL` was tested and did not override soft-fail; the implemented quoted wildcard did.

Local Checkov used Python 3.11 on macOS; CI specifies Python 3.12.11 on Ubuntu 24.04. This environment difference, Linux binary execution, and GitHub event/status behavior remain for CI-01's first PR run. Action pins were checked against GitHub tag refs for `actions/checkout` v4.3.1 and `actions/setup-python` v5.6.0; binary checksums against official release asset digests for `mvdan/sh` v3.12.0, `koalaman/shellcheck` v0.11.0, and `hadolint/hadolint` v2.15.1.

## Documentation evidence

Changed paths: `README.md`, `ARCHITECTURE.md`, `.github/agents/release.yml`. Removed missing local examples/Goldsmith destinations, preserved Goldsmith context without an unverified URL, documented architecture targets and local-versus-publishing behavior, and corrected `gold-image` to `gold-image-amd64`.

Local Markdown paths and anchors resolve; release-agent YAML parses; every referenced Make target exists; `make -n gold-image-amd64` succeeds and shows Terminal → Notebook → Gold. `git diff --check`, actionlint, and the wiki validator passed after integration. No full image build or publishing was performed.

## Remaining cursor

- AD-01 was pruned after its focused credential/login checks passed; AD-02 is ready and remains outside this request. Its fresh-container tests must also verify normal supervisor startup.
- CI-01 is blocked on publishing this branch and opening a PR, then recording a passing run and exact status names. CI-02 follows that evidence and remains outside this request.
- The portfolio now contains four executable plans. Image-builder availability evidence was corrected: local Docker is unavailable but remote builders advertise the required platforms; no architecture-matrix phase was executed.
- Next action: publish the implementation branch and open a PR, then inspect all three validation jobs, record the run URL, and finish CI-01. If checks expose defects, define a bounded repair phase rather than widening the original work silently.
