#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ensure_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    echo "chezmoi bootstrap requires curl or wget" >&2
    exit 1
  fi

  mkdir -p "$HOME/.local/bin"
  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  else
    sh -c "$(wget -qO- get.chezmoi.io)" -- -b "$HOME/.local/bin"
  fi
  export PATH="$HOME/.local/bin:$PATH"
}

main() {
  ensure_chezmoi
  chezmoi apply --refresh-externals=always --source="$repo_root"
}

main "$@"
