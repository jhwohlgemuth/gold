#! /bin/sh
set -e

main() {
    DOTNET_VERSION="${1:-8.0}"
    POWERSHELL_VERSION="${2:-7.5.11}"
    POWERSHELL_SHA256=830ebda118c731ece3fa7e6b7e8573a21346387cbbca5b2f5e3b9bfe24f96672
    architecture="$(dpkg --print-architecture)"
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
    if [ "${architecture}" = arm64 ]; then
        # Microsoft's Debian 13 feed publishes ARM64 .NET 10 packages
        # PowerShell's ARM64 Linux build is distributed as a release archive
        apt-get install --no-install-recommends --yes dotnet-sdk-10.0 dotnet-runtime-10.0
        curl -fsSL -o /tmp/powershell-arm64.tar.gz \
            "https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-arm64.tar.gz"
        printf '%s  %s\n' "${POWERSHELL_SHA256}" /tmp/powershell-arm64.tar.gz | sha256sum --check
        install -d -m 0755 /opt/microsoft/powershell/7
        tar -C /opt/microsoft/powershell/7 -xzf /tmp/powershell-arm64.tar.gz
        chmod 0755 /opt/microsoft/powershell/7/pwsh
        ln -s /opt/microsoft/powershell/7/pwsh /usr/local/bin/pwsh
        rm -f /tmp/powershell-arm64.tar.gz
    else
        apt-get install --no-install-recommends --yes \
            "dotnet-sdk-${DOTNET_VERSION}" \
            "dotnet-runtime-${DOTNET_VERSION}" \
            powershell
    fi
}

main "$@"
