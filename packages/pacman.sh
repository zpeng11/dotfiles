#!/usr/bin/env bash
set -euo pipefail

# Arch Linux package installations

# Source package mapping
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/package_map.sh"

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

# Filter packages that need installation
filter_packages() {
    local filtered=()
    
    for pkg in "${PACKAGES[@]}"; do
        # Always install packages in ALWAYS_INSTALL list
        if is_always_install "$pkg"; then
            filtered+=("$pkg")
            continue
        fi
        
        # Check if the command/package is already available
        if check_package_command "$pkg"; then
            local cmd
            if [[ -n "${PACKAGE_COMMANDS[$pkg]:-}" ]]; then
                cmd="${PACKAGE_COMMANDS[$pkg]}"
            elif [[ -n "${SPECIAL_CHECKS[$pkg]:-}" ]]; then
                cmd="${SPECIAL_CHECKS[$pkg]}"
            else
                cmd="$pkg"
            fi
            echo "  ✓ $pkg already installed (via $cmd)" >&2
        else
            filtered+=("$pkg")
        fi
    done
    
    # Only print if there are packages to install
    if [ ${#filtered[@]} -gt 0 ]; then
        printf '%s\n' "${filtered[@]}"
    fi
}

install_packages() {
    echo "Checking pacman packages..."
    echo ""

    local sudo_cmd=""
    if [ "$EUID" -ne 0 ]; then
        sudo_cmd="sudo"
    fi

    # Filter packages that need installation
    local to_install
    mapfile -t to_install < <(filter_packages)

    # Check if all packages are already installed
    if [ ${#to_install[@]} -eq 0 ]; then
        echo ""
        echo "  All pacman packages already installed!"
        echo ""
        return 0
    fi

    echo ""
    echo "  Installing ${#to_install[@]} package(s)..."
    echo ""

    # Sync package database
    $sudo_cmd pacman -Syu --noconfirm

    # Install filtered packages
    $sudo_cmd pacman -S --noconfirm "${to_install[@]}"

    # Enable fzf keybindings (optional)
    source /usr/share/fzf/key-bindings.zsh 2>/dev/null || true
    source /usr/share/fzf/completion.zsh 2>/dev/null || true
}

"$@"
