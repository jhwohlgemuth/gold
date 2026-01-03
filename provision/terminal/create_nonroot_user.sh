#!/bin/bash
set -e

create_nonroot_user() {
    local uid="${1:-1000}"
    local gid="${2:-1000}"
    local username="${3:-nonroot}"
    local home_dir="${4:-/home/nonroot}"

    addgroup --gid "${gid}" "${username}"
    adduser --uid "${uid}" --gid "${gid}" --disabled-password --gecos "" "${username}"
    echo "${username} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    mkdir -p "${home_dir}"
    chmod 755 "${home_dir}"
    chown -R "${username}:${username}" "${home_dir}"
    chmod 755 /usr/local/bin
    chown -R "${username}:${username}" /usr/local/bin
}

create_nonroot_user "$@"
