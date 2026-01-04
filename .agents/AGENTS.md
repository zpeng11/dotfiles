# AGENTS.md

This repository contains TUI (Terminal User Interface) dotfiles. Currently minimal - this file serves as guidance for future development.

## Build/Lint/Test Commands

This is a dotfiles repository without traditional build systems. Common validation commands:

```bash
# Shell script syntax checking
shellcheck *.sh **/*.sh

# Validate shell scripts are executable
find . -name "*.sh" -type f ! -perm +111

# Test stow/symlink creation (if using GNU Stow)
stow -n -t ~ dotfiles_directory

# Check for broken symlinks in dotfiles
find . -xtype l

# Validate configuration syntax (example for TUI tools)
# nvim --headless -c "lua print('config OK')" -c "qa"
# tmux -f ~/.tmux.conf new-session -d -s test
```

## Code Style Guidelines

### File Organization
- Group configs by tool/category (e.g., `config/nvim/`, `config/tmux/`, `shell/`)
- Use descriptive filenames that indicate purpose
- Include a `README.md` in each subdirectory explaining setup/usage

### Shell Scripts
- **Shebang**: Always use `#!/usr/bin/env bash` for portability
- **Formatting**: 4 space indentation, no tabs
- **Naming**: Lowercase with underscores (e.g., `install_scripts.sh`, `setup_env.sh`)
- **Quoting**: Always quote variables: `"$VAR"`, not `$VAR`
- **Error handling**: Use `set -euo pipefail` at script start
- **Functions**: Snake_case names, clear single purpose

```bash
#!/usr/bin/env bash
set -euo pipefail

install_package() {
    local package="$1"
    echo "Installing $package..."
    # implementation
}
```

### Configuration Files
- **Editor**: Use editorconfig if possible
- **Comments**: Explain why, not what (for non-obvious configs)
- **Maintenance**: Mark customizations with `# CUSTOM:` or similar tags
- **Version control**: Never commit secrets, use `.env` files or secret managers

### Documentation
- README.md at root explains overall setup
- Each tool's directory has its own README
- Document dependencies and installation steps
- Include troubleshooting section

### Git Practices
- Commit messages: imperative mood, describe change not state
- `fix: correct tmux status bar colors` (good)
- `fixed tmux` (bad)
- Never commit:
  - SSH keys (`id_rsa`, `id_ed25519`)
  - API tokens or passwords
  - Personal email/phone numbers
  - Machine-specific paths

### Imports/Requires (for scripts using external tools)
- Check tool availability before use:
```bash
command -v nvim >/dev/null 2>&1 || { echo "nvim not found"; exit 1; }
```

### Error Messages
- Be descriptive and actionable
- Include what failed and how to fix
- Example: `Failed to create symlink: ~/.vimrc already exists. Backup or remove it first.`

### Testing Approach
- Test installation in temporary directory
- Verify configs load without errors
- Test keybindings and TUI functionality
- Use headless mode where available (e.g., `nvim --headless`)

### Naming Conventions
- Directories: lowercase_with_underscores (e.g., `bin`, `config`, `scripts`)
- Config files: tool-specific names (e.g., `.tmux.conf`, `init.lua`)
- Install scripts: `install.sh`, `setup_*.sh`
- Utility scripts: descriptive action names (e.g., `backup_configs.sh`, `update_plugins.sh`)

### Code Review Checklist
- [ ] Scripts have proper shebang and error handling
- [ ] No hardcoded personal paths or secrets
- [ ] Configs are commented for complex settings
- [ ] Documentation is up to date
- [ ] Shellcheck passes with no errors
- [ ] Scripts are executable when needed
