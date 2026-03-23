#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

download_to_file() {
  local url="$1"
  local destination="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsLS -o "$destination" "$url"
  else
    wget -qO "$destination" "$url"
  fi
}

run_downloaded_sh_script() {
  local url="$1"
  shift

  local tmpfile=""

  tmpfile="$(mktemp)"
  trap 'rm -f "${tmpfile:-}"' RETURN
  download_to_file "$url" "$tmpfile"
  sh "$tmpfile" "$@"
}

ensure_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    echo "chezmoi bootstrap requires curl or wget" >&2
    exit 1
  fi

  mkdir -p "$HOME/.local/bin"
  run_downloaded_sh_script "https://get.chezmoi.io" -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
}

main() {
  ensure_chezmoi
  chezmoi apply --refresh-externals=always --source="$repo_root"
}

main "$@"
