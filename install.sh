#!/usr/bin/env bash
set -euo pipefail

# Main installation script for dotfiles

# Color codes for output
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m' # No Color

# Compare two version strings
# Returns: 0 if version1 < version2, 1 if version1 >= version2
compare_versions() {
    local version1="$1"
    local version2="$2"
    
    # Split versions into arrays
    IFS='.' read -r -a v1_parts <<< "$version1"
    IFS='.' read -r -a v2_parts <<< "$version2"
    
    # Compare each part
    for ((i=0; i<${#v1_parts[@]} || i<${#v2_parts[@]}; i++)); do
        local v1_part=${v1_parts[$i]:-0}
        local v2_part=${v2_parts[$i]:-0}
        
        if (( v1_part < v2_part )); then
            return 0
        elif (( v1_part > v2_part )); then
            return 1
        fi
    done
    
    # Versions are equal
    return 1
}

# Get package manager type
get_package_manager() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case "$ID" in
            ubuntu|debian)
                echo "apt"
                ;;
            arch|manjaro|endeavouros)
                echo "pacman"
                ;;
            fedora|rhel|centos)
                echo "dnf"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# Show upgrade instructions for a tool
show_upgrade_instructions() {
    local tool="$1"
    local pkg_manager
    pkg_manager=$(get_package_manager)
    
    echo ""
    echo -e "${YELLOW}  Upgrade instructions:${NC}"
    
    case "$pkg_manager" in
        apt)
            echo "    sudo apt update"
            echo "    sudo apt install --only-upgrade $tool"
            ;;
        pacman)
            echo "    sudo pacman -Syu $tool"
            ;;
        dnf)
            echo "    sudo dnf upgrade $tool"
            ;;
        brew)
            echo "    brew upgrade $tool"
            ;;
        *)
            echo "    Please update $tool using your system's package manager"
            ;;
    esac
    echo ""
}

# Check if a tool meets minimum version requirement
check_tool_version() {
    local tool="$1"
    local min_version="$2"
    local version_cmd=""
    local version_pattern=""
    
    # Set up command and pattern for each tool
    case "$tool" in
        zsh)
            version_cmd="zsh --version"
            version_pattern="[0-9]+\.[0-9]+(\.[0-9]+)?"
            ;;
        nvim)
            version_cmd="nvim --version"
            version_pattern="v[0-9]+\.[0-9]+\.[0-9]+"
            ;;
        git)
            version_cmd="git --version"
            version_pattern="[0-9]+\.[0-9]+\.[0-9]+"
            ;;
        *)
            echo -e "${RED}  ❌ Unknown tool: $tool${NC}"
            return 1
            ;;
    esac
    
    # Check if tool is installed
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${RED}  ❌ $tool is not installed${NC}"
        echo -e "     Required version: $min_version or later"
        show_upgrade_instructions "$tool"
        return 1
    fi
    
    # Get current version
    local current_version
    current_version=$($version_cmd | grep -oP "$version_pattern" | head -1)
    
    # Strip 'v' prefix from nvim version
    current_version="${current_version#v}"
    
    # Extract just the version numbers
    current_version=$(echo "$current_version" | grep -oP '[0-9]+\.[0-9]+(\.[0-9]+)?')
    
    if [ -z "$current_version" ]; then
        echo -e "${RED}  ❌ Failed to detect $tool version${NC}"
        return 1
    fi
    
    # Normalize version to 3 parts (e.g., 5.8 -> 5.8.0)
    local v_parts
    IFS='.' read -r -a v_parts <<< "$current_version"
    if [ ${#v_parts[@]} -eq 2 ]; then
        current_version="${current_version}.0"
    fi
    
    # Compare versions
    if compare_versions "$current_version" "$min_version"; then
        echo -e "${RED}  ❌ $tool version $current_version is too old (required: $min_version or later)${NC}"
        show_upgrade_instructions "$tool"
        return 1
    else
        echo -e "${GREEN}  ✅ $tool version $current_version${NC}"
        return 0
    fi
}

# Check all required tool versions
check_versions() {
    echo "Step 2: Checking version requirements..."
    echo ""
    
    local errors=0
    
    # Check zsh (required 4.3.11+ for zsh-syntax-highlighting, zsh-autosuggestions, fzf-tab)
    if ! check_tool_version "zsh" "4.3.11"; then
        ((errors++))
    fi
    
    # Check neovim (required 0.8.0+ for tokyonight.nvim, lazy.nvim)
    if ! check_tool_version "nvim" "0.8.0"; then
        ((errors++))
    fi
    
    # Check git (required 2.19.0+ for lazy.nvim partial clone support)
    if ! check_tool_version "git" "2.19.0"; then
        ((errors++))
    fi
    
    echo ""
    
    # Abort if any errors
    if [ $errors -gt 0 ]; then
        echo ""
        echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║    ⚠️  INSTALLATION ABORTED: VERSION REQUIREMENTS NOT MET   ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "Please upgrade the tools listed above and run this script again."
        echo ""
        exit 1
    fi
    
    echo -e "${GREEN}  ✅ All tools meet version requirements${NC}"
    echo ""
}

main() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    echo "=== Dotfiles Installation ==="
    echo ""
    
    # Step 1: Install system packages
    echo "Step 1: Installing system packages..."
    bash "${script_dir}/scripts/install_packages.sh"
    echo ""
    
    # Step 2: Check version requirements
    check_versions
    
    # Step 3: Install Oh My Zsh
    echo "Step 3: Installing Oh My Zsh..."
    install_oh_my_zsh
    echo ""
    
    # Step 4: Create symlinks
    echo "Step 4: Creating symlinks..."
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
