#!/usr/bin/env bash
set -euo pipefail

# Main installation script for dotfiles

main() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    echo "=== Dotfiles Installation ==="
    echo ""
    
    # Step 1: Install system packages
    echo "Step 1: Installing system packages..."
    bash "${script_dir}/scripts/install_packages.sh"
    echo ""
    
    # Step 2: Install Oh My Zsh
    echo "Step 2: Installing Oh My Zsh..."
    install_oh_my_zsh
    echo ""
    
    # Step 3: Create symlinks
    echo "Step 3: Creating symlinks..."
    create_symlinks "$script_dir"
    echo ""
    
    echo "=== Installation Complete ==="
    echo ""
    echo "To apply changes:"
    echo "  1. Change your default shell: chsh -s \$(which zsh)"
    echo "  2. Restart your terminal or run: source ~/.zshrc"
}

install_oh_my_zsh() {
    # Check if already installed
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "  Oh My Zsh already installed at $HOME/.oh-my-zsh"
        echo "  To reinstall: rm -rf $HOME/.oh-my-zsh and run this script again"
        return 0
    fi
    
    # Check for curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        echo "  Error: curl or wget required to install Oh My Zsh"
        exit 1
    fi
    
    # Install Oh My Zsh (unattended)
    if command -v curl &> /dev/null; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Verify installation
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "  ✓ Oh My Zsh installed successfully"
    else
        echo "  ✗ Failed to install Oh My Zsh"
        exit 1
    fi
}

create_symlinks() {
    local script_dir="$1"
    
    # Prompt user for existing configs
    prompt_and_backup() {
        local target="$1"
        local name="$2"
        
        if [[ -e "$target" && ! -L "$target" ]]; then
            echo ""
            echo "  Existing $name found at $target"
            read -p "  Backup and replace? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
                echo "  Backing up $name to $backup"
                mv "$target" "$backup"
                return 0
            else
                echo "  Skipping $name"
                return 1
            fi
        fi
        return 0
    }
    
    # Create symlink
    create_link() {
        local source="$1"
        local target="$2"
        local name="$3"
        
        if [[ -L "$target" ]]; then
            # Update existing symlink
            echo "  Updating symlink: $name"
            ln -sf "$source" "$target"
        else
            # Create new symlink
            echo "  Creating symlink: $name"
            ln -s "$source" "$target"
        fi
    }
    
    # Neovim config
    if prompt_and_backup "$HOME/.config/nvim" "nvim config"; then
        create_link "${script_dir}/nvim/.config/nvim" "$HOME/.config/nvim" "nvim config"
    fi
    
    # Zsh config
    if prompt_and_backup "$HOME/.zshrc" "zsh config"; then
        create_link "${script_dir}/zsh/.zshrc" "$HOME/.zshrc" "zsh config"
    fi
    
    # Tmux config
    if prompt_and_backup "$HOME/.tmux.conf" "tmux config"; then
        create_link "${script_dir}/tmux/.tmux.conf" "$HOME/.tmux.conf" "tmux config"
    fi
    
    echo "  ✓ Symlinks created/updated"
}

main
