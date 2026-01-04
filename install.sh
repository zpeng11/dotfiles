#!/bin/bash
# Dotfiles installation script

set -e

echo "Installing dotfiles..."

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Backup existing dotfiles
backup_if_exists() {
    if [ -f "$1" ] || [ -d "$1" ]; then
        echo "Backing up existing $1 to $1.backup"
        mv "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Create symlink
create_symlink() {
    local src="$1"
    local dest="$2"
    backup_if_exists "$dest"
    echo "Creating symlink: $dest -> $src"
    ln -sf "$src" "$dest"
}

# Install tmux config
echo "Installing tmux configuration..."
create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Install zsh config
echo "Installing zsh configuration..."
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Install nvim config
echo "Installing nvim configuration..."
mkdir -p "$HOME/.config"
create_symlink "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"

echo ""
echo "✓ Dotfiles installation complete!"
echo ""
echo "Next steps:"
echo "  1. Install required tools if not already installed:"
echo "     - tmux: sudo apt install tmux (Ubuntu/Debian) or brew install tmux (macOS)"
echo "     - zsh: sudo apt install zsh (Ubuntu/Debian) or brew install zsh (macOS)"
echo "     - neovim: sudo apt install neovim (Ubuntu/Debian) or brew install neovim (macOS)"
echo "  2. Set zsh as your default shell: chsh -s \$(which zsh)"
echo "  3. Restart your terminal or run: source ~/.zshrc"
echo "  4. Start tmux: tmux"
echo "  5. Open nvim: nvim"
echo ""
