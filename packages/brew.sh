#!/usr/bin/env bash
set -euo pipefail

# macOS Homebrew package installations

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

install_packages() {
    echo "Installing Homebrew packages..."

    # Update Homebrew
    brew update

    # Install formulae
    brew install "${PACKAGES[@]}"

    # Install casks (fonts)
    brew install --cask "${CASKS[@]}"

    # Enable fzf shell integrations
    if [ -f "$(brew --prefix)/opt/fzf/install" ]; then
        "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
    fi

    # GNU tar as 'gtar' (keep 'tar' for system version)
    # Add to PATH if needed: export PATH="$(brew --prefix gnu-tar)/libexec/gnubin:$PATH"
}

"$@"
