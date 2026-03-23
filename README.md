# dotfiles

`chezmoi`-managed TUI dotfiles with deterministic tool bootstrapping.

## Layout

- `home/`: `chezmoi` source state
- `home/.chezmoidata/`: package and tool metadata rendered into scripts
- `home/.chezmoiscripts/`: package/tool install hooks
- `home/.chezmoiexternal.toml`: third-party dependencies managed by `chezmoi`
- `scripts/verify_docker_ubuntu.sh`: Docker validation for Ubuntu 20.04 / 22.04 / 24.04
- `scripts/verify_tart_macos.sh`: Tart + SSH validation for macOS 15 / 26 on Apple Silicon hosts

## Apply Locally

```bash
./install.sh
```

`install.sh` bootstraps `chezmoi` if needed and applies this repo as the source directory.

On macOS, the apply flow:

- requires Xcode Command Line Tools
- bootstraps Homebrew if needed
- installs the managed CLI dependencies via Homebrew
- keeps `/bin/zsh` as the login-shell target
- honors `DOTFILES_SKIP_SHELL_CHANGE=1` when you want to suppress shell changes during validation

## Validate In Docker

```bash
./scripts/verify_docker_ubuntu.sh
```

The validation script provisions fresh Ubuntu containers, applies the repo with `chezmoi`, and checks:

- `git >= 2.19.0`
- `zsh >= 4.3.11`
- `nvim == 0.10.4`
- `tmux == 3.5a`
- `nvm` is installed under `~/.nvm` and loads from the managed zsh config
- if `node` and `npm` are absent before install, `nvm` bootstraps the current `stable` release
- the install flow changes the login shell to `zsh` when it can do so safely
- required dotfiles and externals land in the expected paths
- a second `chezmoi apply` is idempotent

## Validate In Tart

```bash
./scripts/verify_tart_macos.sh
```

The Tart validation script is intended for Apple Silicon macOS hosts with Xcode Command Line Tools installed. It bootstraps `tart` and `sshpass` with Homebrew when needed, clones the official Cirrus Labs macOS base images for:

- `macOS 15 Sequoia`
- `macOS 26 Tahoe`

For each guest VM it mounts this repo read-only, connects over SSH as `admin`, applies the repo with `chezmoi`, and checks:

- `git >= 2.19.0`
- `zsh >= 4.3.11`
- `nvim >= 0.8.0`
- `tmux >= 3.2.1`
- `nvm` is installed under `~/.nvm` and loads from the managed zsh config
- if `node` and `npm` are absent before install, `nvm` bootstraps the current `stable` release
- `ranger`, `bat`, `chafa`, `jq`, and `pdftotext` are available
- macOS zsh does not receive GNU-only `ls --color=auto` aliases
- `DOTFILES_SKIP_SHELL_CHANGE=1` suppresses login-shell mutation during validation
- a second `chezmoi apply` is idempotent

Set `KEEP_TART_VM=1` to retain failed Tart guests for debugging.
