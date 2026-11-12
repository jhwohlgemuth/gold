# Implementation — Jupyter credentials (AD-02)

- Authorized scope: AD-02, plus reconciliation of completed CI-01 evidence. CI-02 and the image/CLI phases remain future work.
- Baseline: clean `main` at `cc1af0d`, merging PR #7; implementation branch `feat/jupyter-credentials`. Changes remain uncommitted and unpublished.
- State: AD-02 complete; the access-defaults plan is retired. The portfolio now contains three executable plans. Next phase: [CI-02](.wiki/features/ci-validation.md).
- Product write set: `config/jupyter/jupyter_notebook_config.py`, `config/jupyter/service/run`, `README.md`.
- Budget: estimated less than one active hour of the five-hour maximum; external waiting excluded.

## Implemented behavior

Jupyter requires `JUPYTER_PASSWORD` or `JUPYTER_PASSWORD_HASH`; a supplied hash wins when both are set. Its shipped config loads an optional custom Python config, then applies the environment credential and disables token login and login-page password changes. Plaintext is hashed in memory and removed from Jupyter's environment; the hash remains available for extension config reloads. Custom files and the shipped config are not rewritten, and secrets are not passed as process arguments. Missing credentials and invalid custom-config paths prevent service startup with visible errors.

The service directly launches the base environment's `jupyter` executable so s6 receives its output and can deliver signals. README documents both browser login URLs, required environment variables, credential precedence, and interactive hash generation.

## Validation evidence

All results below apply to this branch's current uncommitted product files. On 2026-11-11 local time, a disposable derivative was built on Docker context `oklahoma` from `ghcr.io/jhwohlgemuth/notebook:1.0.5-amd64`, base image `sha256:bab8ca98f4198de9f69e927718a1aac5775061acbdd174a43c7ec6549c490677`, with only the changed browser service/config files and the temporary test harness copied in. Tested derivative ID: `sha256:c4278f33ddbeda00722edd3ab745a875b0b879b5fb185aa45f7daeb953fe5b07`. Installed Jupyter Server: 2.21.1; code-server: 4.143.1.

Seven scenarios passed in fresh containers using the normal `/init` entrypoint and s6 supervision:

- Plaintext containing punctuation and a newline: supplied logins work on ports 1337 and 13337.
- Hash plus plaintext: the hash wins and the ignored plaintext is rejected.
- Hash only: the existing `JUPYTER_PASSWORD_HASH` path works without a plaintext variable.
- Custom config: its base URL is preserved; its old password and token cannot log in; the supplied credential works; the service port takes precedence over the custom-config port.
- Missing credentials: both browser ports remain unavailable and startup errors identify the required variables.
- Empty credentials: same fail-closed result.
- Missing custom-config file: Jupyter remains unavailable and logs the configuration error.

For successful-start scenarios, unauthenticated/wrong/default-password requests were rejected; accepted credentials established a session and authenticated access. Jupyter's protected API rejected the stale custom token. Checksums confirmed shipped configuration files were unchanged. No config-load exceptions occurred after the reload fix. This also resolves the previous unverified normal-s6-startup check; it does not establish full source image builds or the architecture matrix.

Focused checks passed:

```sh
shfmt -d config/jupyter/service/run
shellcheck config/jupyter/service/run
python3 -B .agents/skills/planning/scripts/validate_wiki.py .
git diff --check
```

Python AST parsing and README local-link checks passed. Checkov 3.2.471 with `CKV_PARSE_ERROR_FAIL=true`, `--hard-fail-on '*'`, and `--skip-download` passed 589 Dockerfile and 84 Actions checks with zero failures.

Temporary reproduction assets are `/tmp/gold-ad02-runtime-check.py`, `/tmp/gold-ad02-http-check.py`, and build context `/var/folders/j8/zdr2cnr934x80qdkddy48nshjhbsm8/T/gold-ad02-cy3ezrgo`. Rebuild the disposable `gold-ad02-validation:cy3ezrgo` image from that context on `oklahoma`, then run the runtime-check script from the repository root. The script creates and removes each scenario container. These are temporary execution artifacts, not a committed test suite.

Cleanup is complete: the initial test containers and the final disposable image tag were removed; a name-filtered container listing returned no remaining AD-02 containers.

An initial `docker cp` attempt failed because the Mac UID could not map into rootless Docker's user namespace. Packaging the harness with explicit Linux ownership resolved it. The product config also needed to retain its computed hash for repeated extension loads; the final seven scenarios validate that correction.

## CI evidence and next action

PR #7 merged as `cc1af0d`. At `2fbb4ad`, all three jobs passed in [run 43133232599](https://github.com/jhwohlgemuth/gold/actions/runs/43133232599): **Shell validation**, **Dockerfile validation**, **Configuration validation**. SonarCloud reported zero new issues after HTTPS-only downloads and wheel-only Checkov installation. CI-01 is removed and CI-02 is ready.

Next action: review/commit the AD-02 changes, then execute CI-02 to document the exact required checks and inspect branch-protection status. No future run has been scheduled.
