#!/usr/bin/env bash
set -euo pipefail

# Arch Linux package installations

PACKAGES=(
    openssh
    tmux
    git
    curl
    neovim
    zsh
    ranger
    w3m
    highlight
    base-devel
    fzf
    less
    ca-certificates
    glibc
    ripgrep
    fd
    unzip
    tar
    python
    python-pip
    node
    npm
    file
    clang
    cmake
    ninja
    gdb
    lldb
    clang
)

install_packages() {
    echo "Installing pacman packages..."

    local sudo_cmd=""
    if [ "$EUID" -ne 0 ]; then
        sudo_cmd="sudo"
    fi

    $sudo_cmd pacman -Syu --noconfirm
    $sudo_cmd pacman -S --noconfirm "${PACKAGES[@]}"

    # Enable fzf keybindings (optional)
    source /usr/share/fzf/key-bindings.zsh 2>/dev/null || true
    source /usr/share/fzf/completion.zsh 2>/dev/null || true
}

"$@"
