#!/usr/bin/env bash
set -euo pipefail

# Detect OS and package manager, then install packages

detect_os() {
    local os=""
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            source /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    os="apt"
                    ;;
                arch|manjaro|endeavouros)
                    os="pacman"
                    ;;
                *)
                    echo "Unsupported Linux distro: $ID"
                    exit 1
                    ;;
            esac
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os="brew"
    fi

    if [ -z "$os" ]; then
        echo "Unable to detect OS/package manager"
        exit 1
    fi

    echo "$os"
}

main() {
    local package_manager
    package_manager=$(detect_os)
    echo "Detected package manager: $package_manager"

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local package_script="${script_dir}/../packages/${package_manager}.sh"

    if [ ! -f "$package_script" ]; then
        echo "Package script not found: $package_script"
        exit 1
    fi

    echo "Installing packages..."
    chmod +x "$package_script"
    bash "$package_script" install_packages

    echo "Package installation complete!"
}

main
