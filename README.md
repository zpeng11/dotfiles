# dotfiles

My TUI (Terminal User Interface) dotfiles for a productive terminal environment.

## Features

This repository contains configuration files for a complete terminal-based development environment:

- **tmux** - Terminal multiplexer for managing multiple terminal sessions
- **neovim** - Modern, extensible text editor
- **zsh** - Powerful shell with better defaults than bash

## Quick Start

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/zpeng11/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

3. Install the required tools (if not already installed):
   - **Ubuntu/Debian:**
     ```bash
     sudo apt update
     sudo apt install tmux zsh neovim
     ```
   - **macOS:**
     ```bash
     brew install tmux zsh neovim
     ```

4. Set zsh as your default shell:
   ```bash
   chsh -s $(which zsh)
   ```

5. Restart your terminal or source the config:
   ```bash
   source ~/.zshrc
   ```

## Configuration Details

### tmux (.tmux.conf)

- **Prefix key:** `Ctrl-a` (instead of default `Ctrl-b`)
- **Mouse support:** Enabled
- **Window/pane numbering:** Starts from 1
- **Split commands:**
  - `Prefix + |` - Split vertically
  - `Prefix + -` - Split horizontally
- **Pane navigation:**
  - `Prefix + h/j/k/l` - Vim-style navigation
- **Reload config:** `Prefix + r`

### neovim (.config/nvim/init.lua)

- **Leader key:** `Space`
- **Line numbers:** Enabled (relative)
- **Colorscheme:** Desert (built-in)
- **Key bindings:**
  - `Space + w` - Save file
  - `Space + q` - Quit
  - `Space + e` - File explorer
  - `Ctrl + h/j/k/l` - Navigate between windows
  - `Shift + h/l` - Navigate between buffers
- **Features:**
  - System clipboard integration
  - Persistent undo
  - Auto-remove trailing whitespace
  - Highlight on yank

### zsh (.zshrc)

- **Vi mode:** Enabled
- **History:** 10,000 entries with deduplication
- **Auto-completion:** Enhanced with menu select
- **Prompt:** Clean, colorful prompt showing user@host:path
- **Aliases:**
  - `vim` → `nvim`
  - `ll` → `ls -lah`
  - `la` → `ls -A`
- **Editor:** Set to neovim

## Usage

### Starting a tmux session

```bash
tmux                    # Start a new session
tmux new -s mysession   # Start a new named session
tmux attach             # Attach to the last session
tmux ls                 # List sessions
```

### Working with tmux

- `Ctrl-a + c` - Create new window
- `Ctrl-a + n` - Next window
- `Ctrl-a + p` - Previous window
- `Ctrl-a + d` - Detach from session
- `Ctrl-a + [` - Enter scroll mode (use arrow keys or vi keys, `q` to exit)

### Using neovim

```bash
nvim filename           # Open a file
nvim .                  # Open file explorer in current directory
```

Inside neovim:
- `:w` or `Space + w` - Save
- `:q` or `Space + q` - Quit
- `Space + e` - Toggle file explorer
- `i` - Insert mode
- `Esc` - Normal mode
- `v` - Visual mode

## Customization

Feel free to modify the configuration files to suit your preferences:

- **tmux:** Edit `.tmux.conf`
- **neovim:** Edit `.config/nvim/init.lua`
- **zsh:** Edit `.zshrc`

After making changes:
- **tmux:** Press `Ctrl-a + r` to reload
- **neovim:** Run `:source %` or restart neovim
- **zsh:** Run `source ~/.zshrc` or restart your terminal

## Uninstallation

To restore your original configurations, the install script creates backups with timestamps. You can restore them:

```bash
mv ~/.tmux.conf.backup.TIMESTAMP ~/.tmux.conf
mv ~/.zshrc.backup.TIMESTAMP ~/.zshrc
mv ~/.config/nvim.backup.TIMESTAMP ~/.config/nvim
```

Or simply delete the symlinks:

```bash
rm ~/.tmux.conf ~/.zshrc
rm -rf ~/.config/nvim
```

## License

MIT
