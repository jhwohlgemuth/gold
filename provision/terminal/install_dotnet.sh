#! /bin/bash
set -e

main() {
    #
    # Add Microsoft PPA
    #
    curl -O https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    rm -f packages-microsoft-prod.deb
    #
    # Install dotnet and PowerShell core
    #
    local VERSION="${1:-"7.0"}"
    apt-get update
    apt-get install --no-install-recommends --yes \
        "dotnet-sdk-${VERSION}" \
        "dotnet-runtime-${VERSION}" \
        powershell
}
main "$@"
