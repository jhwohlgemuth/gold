#! /bin/bash
set -e

requires \
    code-server \
    curl \
    jq
main() {
    #
    # Download Extensions listing
    #
    CONFIG="${CODE_SERVER_CONFIG_DIR:-/app/code-server/config}/config.yaml"
    EXTENSIONS_JSON="${CODE_SERVER_CONFIG_DIR:-/app/code-server/config}/Extensions.json"
    curl -o "${EXTENSIONS_JSON}" https://raw.githubusercontent.com/jhwohlgemuth/purple/main/artifacts/Extensions.json
    #
    # Install Code Server extensions
    #
    if [[ -z "$1" ]]; then
        ARGS=development
    else
        ARGS=("$@")
    fi
    for ARG in "${ARGS[@]}"; do
        echo "Installing extensions for ${ARG} VS Code instance"
        EXTENSIONS="$(jq -r ".${ARG}[]" "${EXTENSIONS_JSON}")"
        for EXTENSION in ${EXTENSIONS}; do
            code-server --config "${CONFIG}" --install-extension "${EXTENSION}" --force
        done
    done
}
main "$@"
