#! /bin/sh
set -e

main() {
    DOTNET_VERSION="${1:-8.0}"
    repo_candidates=""
    repo_url=""
    # shellcheck disable=SC1091
    . /etc/os-release
    # /etc/os-release defines these at runtime.
    ID="${ID:-}"
    VERSION_ID="${VERSION_ID:-}"
    case "${ID}" in
        debian)
            repo_candidates="https://packages.microsoft.com/config/debian/${VERSION_ID}/packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb"
            ;;
        ubuntu)
            repo_candidates="https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb"
            ;;
        *)
            echo "Unsupported distro for dotnet install: ${ID}" >&2
            exit 1
            ;;
    esac
    for candidate in ${repo_candidates}; do
        if curl -fsSL -o /tmp/packages-microsoft-prod.deb "${candidate}"; then
            repo_url="${candidate}"
            break
        fi
    done
    if [ -z "${repo_url}" ]; then
        echo "Unable to download Microsoft package source for ${ID} ${VERSION_ID}" >&2
        exit 1
    fi
    #
    # Add Microsoft package source
    #
    dpkg -i /tmp/packages-microsoft-prod.deb
    rm -f /tmp/packages-microsoft-prod.deb
    #
    # Install dotnet and PowerShell core
    #
    apt-get update
    apt-get install --no-install-recommends --yes \
        "dotnet-sdk-${DOTNET_VERSION}" \
        "dotnet-runtime-${DOTNET_VERSION}" \
        powershell
}

main "$@"
