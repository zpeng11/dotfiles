# dotfiles

`chezmoi`-managed TUI dotfiles with deterministic tool bootstrapping.

## Layout

- `home/`: `chezmoi` source state
- `home/.chezmoidata/`: package and tool metadata rendered into scripts
- `home/.chezmoiscripts/`: package/tool install hooks
- `home/.chezmoiexternal.toml`: third-party dependencies managed by `chezmoi`
- `scripts/verify_docker_ubuntu.sh`: Docker validation for Ubuntu 20.04 / 22.04 / 24.04

## Apply Locally

```bash
./install.sh
```

`install.sh` bootstraps `chezmoi` if needed and applies this repo as the source directory.

## Validate In Docker

```bash
./scripts/verify_docker_ubuntu.sh
```

The validation script provisions fresh Ubuntu containers, applies the repo with `chezmoi`, and checks:

- `git >= 2.19.0`
- `zsh >= 4.3.11`
- `nvim == 0.10.4`
- `tmux == 3.5a`
- required dotfiles and externals land in the expected paths
- a second `chezmoi apply` is idempotent
