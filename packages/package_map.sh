#!/usr/bin/env bash

# Package to command mapping for checking if tools are already installed
# Format: package_name:command_to_check

# Tools with direct command-line checks
declare -A PACKAGE_COMMANDS=(
    # Core tools
    [openssh-server]="ssh"
    [openssh]="ssh"
    [tmux]="tmux"
    [git]="git"
    [curl]="curl"
    [neovim]="nvim"
    [zsh]="zsh"
    [ranger]="ranger"
    [w3m]="w3m"
    [highlight]="highlight"
    
    # Search/navigate tools
    [fzf]="fzf"
    [less]="less"
    [ripgrep]="rg"
    [fd-find]="fdfind"
    [fd]="fd"
    
    # Archive tools
    [unzip]="unzip"
    [tar]="tar"
    [gnu-tar]="gtar"
    
    # Python
    [python3]="python3"
    [python]="python3"
    
    # Node.js
    [nodejs]="node"
    [node]="node"
    [npm]="npm"
    
    # File tools
    [file]="file"
    
    # C/C++ toolchain
    [clangd]="clangd"
    [clang]="clang"
    [clang++]="clang++"
    [cmake]="cmake"
    [ninja-build]="ninja"
    [ninja]="ninja"
    [gdb]="gdb"
    [lldb]="lldb"
    [clang-format]="clang-format"
    
    # Rust tools (if using cargo)
    [ripgrep]="rg"
)

# Packages without direct commands (always install)
declare -a ALWAYS_INSTALL=(
    "build-essential"
    "base-devel"
    "ca-certificates"
    "locales"
    "glibc"
    "fonts-powerline"
    "font-hack-nerd-font"
    
    # Python modules (check via python -m)
    "python3-pip"
    "python3-venv"
    "python-pip"
    
    # Meta-packages (install multiple tools)
    "llvm"
)

# Packages that need special checks
declare -A SPECIAL_CHECKS=(
    [python3-pip]="python3 -m pip --version"
    [python3-venv]="python3 -m venv --help"
    [python-pip]="python -m pip --version"
)

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if a package needs special command verification
check_package_command() {
    local pkg="$1"
    
    # Check special checks first
    for special_pkg in "${!SPECIAL_CHECKS[@]}"; do
        if [[ "$pkg" == "$special_pkg" ]]; then
            local check_cmd="${SPECIAL_CHECKS[$pkg]}"
            if eval "$check_cmd" &> /dev/null; then
                return 0
            else
                return 1
            fi
        fi
    done
    
    # Check regular command mapping
    if [[ -n "${PACKAGE_COMMANDS[$pkg]:-}" ]]; then
        local cmd="${PACKAGE_COMMANDS[$pkg]}"
        command_exists "$cmd"
        return $?
    fi
    
    # No mapping, assume needs installation
    return 1
}

# Check if package should always be installed
is_always_install() {
    local pkg="$1"
    for always in "${ALWAYS_INSTALL[@]}"; do
        if [[ "$pkg" == "$always" ]]; then
            return 0
        fi
    done
    return 1
}
