#! /bin/bash
set -e

requires curl
install_docker() {
    #
    # Install Docker
    #
    ulimit -n 65536
    apt-get install --yes \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    systemctl enable docker.service
    systemctl enable containerd.service
    service docker start
}
install_nvidia_container_toolkit() {
    #
    # Install NVIDIA Container Toolkit
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
    #
    local NVIDIA_URL = 'https://nvidia.github.io/libnvidia-container'
    curl -fsSL "${NVIDIA_URL}/gpgkey" | \gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L "${NVIDIA_URL}/stable/deb/nvidia-container-toolkit.list" | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    apt-get update
    apt-get install --yes nvidia-container-toolkit
    service docker restart
}
main() {
    # https://docs.docker.com/engine/install/debian/
    #
    # Add Docker GPG key
    #
    # shellcheck source=/dev/null
    . /etc/os-release
    local ID="${ID:-"debian"}"
    local CODENAME="${VERSION_CODENAME:-"bullseye"}"
    local KEY_ROOT="/etc/apt/keyrings"
    local KEY="${KEY_ROOT}/docker.gpg"
    apt-get update
    apt-get install --yes \
        ca-certificates \
        gnupg
    install -m 0755 -d "${KEY_ROOT}"
    curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | gpg --dearmor -o "${KEY}"
    chmod a+r "${KEY}"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=${KEY}] https://download.docker.com/linux/${ID} ${CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    install_docker
    if is_command nvidia-smi; then
        install_nvidia_container_toolkit
    fi
}
main "$@"
