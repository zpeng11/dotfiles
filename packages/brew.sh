#!/usr/bin/env bash
set -euo pipefail

# macOS Homebrew package installations

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
    fzf
    less
    ripgrep
    fd
    unzip
    gnu-tar
    python
    node
    file
    llvm
    cmake
    ninja
    gdb
    lldb
)

CASKS=(
    font-hack-nerd-font
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

# Filter casks that need installation
filter_casks() {
    local filtered=()
    
    for cask in "${CASKS[@]}"; do
        # Check if cask is already installed via brew list --cask
        if brew list --cask 2>/dev/null | grep -q "^${cask}$"; then
            echo "  ✓ $cask already installed" >&2
        else
            filtered+=("$cask")
        fi
    done
    
    # Only print if there are casks to install
    if [ ${#filtered[@]} -gt 0 ]; then
        printf '%s\n' "${filtered[@]}"
    fi
}

install_packages() {
    echo "Checking Homebrew packages..."
    echo ""

    # Update Homebrew
    brew update

    # Filter packages that need installation
    local to_install
    mapfile -t to_install < <(filter_packages)

    # Check if all packages are already installed
    if [ ${#to_install[@]} -eq 0 ]; then
        echo ""
        echo "  All Homebrew packages already installed!"
    else
        echo ""
        echo "  Installing ${#to_install[@]} package(s)..."
        echo ""

        # Install filtered formulae
        brew install "${to_install[@]}"
    fi

    # Filter casks that need installation
    local to_install_casks
    mapfile -t to_install_casks < <(filter_casks)

    if [ ${#to_install_casks[@]} -gt 0 ]; then
        echo ""
        echo "  Installing ${#to_install_casks[@]} cask(s)..."
        echo ""

        # Install filtered casks
        brew install --cask "${to_install_casks[@]}"
    fi

    # Enable fzf shell integrations (only if fzf was just installed)
    if [ -f "$(brew --prefix)/opt/fzf/install" ]; then
        "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
    fi

    # GNU tar as 'gtar' (keep 'tar' for system version)
    # Add to PATH if needed: export PATH="$(brew --prefix gnu-tar)/libexec/gnubin:$PATH"
}

"$@"
