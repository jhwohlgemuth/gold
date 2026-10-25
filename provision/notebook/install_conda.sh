#!/usr/bin/env bash
set -euo pipefail

main() {
    local MINIFORGE_VERSION="${1:-26.3.2-3}"
    local home_dir="${HOME:?HOME is not set}"
    local miniforge_arch miniforge_sha

    case "$(dpkg --print-architecture)" in
        arm64)
            miniforge_arch=aarch64
            miniforge_sha=2c113a69297e612b01ca0f320c22a3107a11f2ab9b573d79ac868a175945ce29
            ;;
        amd64)
            miniforge_arch=x86_64
            miniforge_sha=848194851a98903134187fbb4ab50efe87b003e0c0f808f97644b7524a62bf2c
            ;;
        *)
            echo "Unsupported architecture: $(dpkg --print-architecture)" >&2
            return 1
            ;;
    esac

    curl -fsSL \
        "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-${miniforge_arch}.sh" \
        -o /tmp/miniforge.sh
    printf '%s  %s\n' "${miniforge_sha}" /tmp/miniforge.sh | sha256sum --check
    bash /tmp/miniforge.sh -b -p "${home_dir}/miniconda3"
    rm -f /tmp/miniforge.sh
}

main "$@"
