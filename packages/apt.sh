#!/usr/bin/env bash
set -euo pipefail

# Ubuntu/Debian package installations

PACKAGES=(
    openssh-server
    tmux
    git
    curl
    neovim
    zsh
    ranger
    w3m
    highlight
    build-essential
    fzf
    less
    ca-certificates
    locales
    fonts-powerline
    ripgrep
    fd-find
    unzip
    tar
    python3
    python3-pip
    python3-venv
    nodejs
    npm
    file
    clangd
    cmake
    ninja-build
    gdb
    lldb
    clang-format
)

install_packages() {
    echo "Installing apt packages..."

    local sudo_cmd=""
    if [ "$EUID" -ne 0 ]; then
        sudo_cmd="sudo"
    fi

    $sudo_cmd apt-get update
    $sudo_cmd apt-get install -y "${PACKAGES[@]}"

    # Create fd symlink for fd-find
    if command -v fdfind >/dev/null 2>&1; then
        $sudo_cmd ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi

    # Generate locale
    $sudo_cmd locale-gen en_US.UTF-8
}

"$@"
