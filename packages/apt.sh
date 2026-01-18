#!/usr/bin/env bash
set -euo pipefail

# Ubuntu/Debian package installations

# Source package mapping
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/package_map.sh"

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
    bat
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
    echo "Checking apt packages..."
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
        echo "  All apt packages already installed!"
        echo ""
        return 0
    fi

    echo ""
    echo "  Installing ${#to_install[@]} package(s)..."
    echo ""

    # Update package list
    $sudo_cmd apt-get update

    # Install filtered packages
    $sudo_cmd apt-get install -y "${to_install[@]}"

    # Create fd symlink for fd-find (only if fdfind was just installed)
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        $sudo_cmd ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi

    # Generate locale
    $sudo_cmd locale-gen en_US.UTF-8
}

"$@"
