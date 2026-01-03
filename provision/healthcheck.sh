#! /bin/bash
set -euo pipefail

LOG_FILE="${HOME:-/home/nonroot}/healthcheck.log"
exec 1>> "${LOG_FILE}" 2>&1

HOST="${HEALTHCHECK_HOST:-localhost}"
CODE_SERVER_PORT="${CODE_SERVER_PORT:-1337}"
VERDACCIO_PORT="${VERDACCIO_PORT:-4873}"
JUPYTER_PORT="${JUPYTER_PORT:-13337}"
MARIMO_PORT="${MARIMO_PORT:-13338}"

echo "[$(date)] Healthcheck started"
curl_opts=(
	--fail
	--silent
	--show-error
	--max-time 5
	--insecure
)
status=0
check() {
	local name="$1"
	local url="$2"
	if curl "${curl_opts[@]}" "${url}" >/dev/null; then
		echo "OK: ${name} (${url})"
	else
		echo "FAIL: ${name} (${url})" >&2
		status=1
	fi
}
check "code-server" "https://${HOST}:${CODE_SERVER_PORT}"
check "verdaccio" "https://${HOST}:${VERDACCIO_PORT}"
check "jupyter" "https://${HOST}:${JUPYTER_PORT}"
check "marimo" "http://${HOST}:${MARIMO_PORT}"

echo "[$(date)] Healthcheck exiting with status ${status}"
exit "${status}"
