#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
homebrew_prefix="/opt/homebrew"
shared_repo_mount="/Volumes/My Shared Files/repo"
ssh_options=(
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o LogLevel=ERROR
  -o ConnectTimeout=5
)
macos_images=(
  "sequoia|ghcr.io/cirruslabs/macos-sequoia-base:latest"
  "tahoe|ghcr.io/cirruslabs/macos-tahoe-base:latest"
)

setup_brew_env() {
  if [[ -x "${homebrew_prefix}/bin/brew" ]]; then
    eval "$("${homebrew_prefix}/bin/brew" shellenv)"
  fi
}

ensure_homebrew() {
  setup_brew_env
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [[ ! -x /usr/bin/xcode-select ]]; then
    echo "xcode-select is required on the Tart host" >&2
    exit 1
  fi

  if ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
    echo "Xcode Command Line Tools are required; run 'xcode-select --install' first" >&2
    exit 1
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  setup_brew_env
}

ensure_brew_command() {
  local command_name="$1"
  local formula_name="$2"

  if command -v "$command_name" >/dev/null 2>&1; then
    return 0
  fi

  ensure_homebrew
  setup_brew_env
  brew install "$formula_name"
}

compare_versions() {
  local version1="$1"
  local version2="$2"
  local i=0
  local part1 part2

  IFS='.' read -r -a parts1 <<< "$version1"
  IFS='.' read -r -a parts2 <<< "$version2"

  while (( i < ${#parts1[@]} || i < ${#parts2[@]} )); do
    part1="${parts1[$i]:-0}"
    part2="${parts2[$i]:-0}"
    if (( part1 < part2 )); then
      return 1
    fi
    if (( part1 > part2 )); then
      return 0
    fi
    ((i += 1))
  done

  return 0
}

host_major_version() {
  sw_vers -productVersion | awk -F. '{print $1}'
}

ensure_host_prereqs() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Tart validation requires a macOS host" >&2
    exit 1
  fi

  if [[ "$(uname -m)" != "arm64" ]]; then
    echo "Tart validation requires an Apple Silicon host" >&2
    exit 1
  fi

  if ! compare_versions "$(host_major_version)" "13"; then
    echo "Tart validation requires macOS 13 or newer on the host" >&2
    exit 1
  fi

  if [[ ! -x /usr/bin/xcode-select ]] || ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
    echo "Xcode Command Line Tools are required; run 'xcode-select --install' first" >&2
    exit 1
  fi

  ensure_brew_command tart cirruslabs/cli/tart
  ensure_brew_command sshpass cirruslabs/cli/sshpass
}

cleanup_vm() {
  local vm_name="$1"

  if [[ "${KEEP_TART_VM:-0}" == "1" ]]; then
    printf 'Keeping VM %s for debugging (KEEP_TART_VM=1)\n' "$vm_name"
    return 0
  fi

  tart stop "$vm_name" >/dev/null 2>&1 || true
  tart delete "$vm_name" >/dev/null 2>&1 || true
}

wait_for_ssh() {
  local vm_name="$1"
  local deadline=$((SECONDS + 600))
  local ip=""

  while (( SECONDS < deadline )); do
    ip="$(tart ip "$vm_name" 2>/dev/null || true)"
    if [[ -n "$ip" ]] && sshpass -p admin ssh "${ssh_options[@]}" "admin@${ip}" true >/dev/null 2>&1; then
      printf '%s\n' "$ip"
      return 0
    fi
    sleep 5
  done

  echo "Timed out waiting for SSH on VM ${vm_name}" >&2
  return 1
}

run_remote_validation() {
  local ip="$1"

  sshpass -p admin ssh "${ssh_options[@]}" "admin@${ip}" /bin/bash -s <<EOF
set -euo pipefail

compare_versions() {
  local version1="\$1"
  local version2="\$2"
  local i=0
  local part1 part2

  IFS='.' read -r -a parts1 <<< "\$version1"
  IFS='.' read -r -a parts2 <<< "\$version2"

  while (( i < \${#parts1[@]} || i < \${#parts2[@]} )); do
    part1="\${parts1[\$i]:-0}"
    part2="\${parts2[\$i]:-0}"
    if (( part1 < part2 )); then
      return 1
    fi
    if (( part1 > part2 )); then
      return 0
    fi
    ((i += 1))
  done

  return 0
}

normalize_tmux_version() {
  local raw_version="\$1"
  local numeric_part letter suffix=0

  numeric_part="\$(printf '%s\n' "\$raw_version" | grep -oE '[0-9]+\.[0-9]+')"
  letter="\$(printf '%s\n' "\$raw_version" | grep -oE '[a-z]$' || true)"
  if [[ -n "\$letter" ]]; then
    suffix=\$(( \$(printf '%d' "'\$letter") - 96 ))
  fi
  printf '%s.%s\n' "\$numeric_part" "\$suffix"
}

assert_min_version() {
  local tool="\$1"
  local current="\$2"
  local required="\$3"

  if [[ "\$tool" == "tmux" ]]; then
    current="\$(normalize_tmux_version "\$current")"
  fi

  if ! compare_versions "\$current" "\$required"; then
    echo "\$tool version \$current is below required \$required" >&2
    exit 1
  fi
}

repo_root="${shared_repo_mount}"
export DOTFILES_SKIP_SHELL_CHANGE=1

mkdir -p "\$HOME/.local/bin"
if command -v sudo >/dev/null 2>&1; then
  printf 'admin\n' | sudo -S -v >/dev/null 2>&1 || true
fi
if ! command -v chezmoi >/dev/null 2>&1; then
  sh -c "\$(curl -fsLS get.chezmoi.io)" -- -b "\$HOME/.local/bin" >/dev/null
fi
export PATH="\$HOME/.local/bin:\$PATH"

first_apply_output="\$(chezmoi apply --refresh-externals=always --source="\$repo_root" 2>&1)"
printf '%s\n' "\$first_apply_output"
printf '%s\n' "\$first_apply_output" | grep -F "Skipping login shell change: DOTFILES_SKIP_SHELL_CHANGE=1" >/dev/null

second_apply_output="\$(chezmoi apply --refresh-externals=always --source="\$repo_root" 2>&1)"
printf '%s\n' "\$second_apply_output"

test -f "\$HOME/.zshrc"
test -f "\$HOME/.zprofile"
test -f "\$HOME/.tmux.conf"
test -d "\$HOME/.config/nvim"
test -d "\$HOME/.config/ranger"
test -f "\$HOME/.config/zsh/nvm.zsh"
test -d "\$HOME/.oh-my-zsh"
test -d "\$HOME/.config/ranger/plugins/ranger_devicons"
test -s "\$HOME/.nvm/nvm.sh"

command -v bat >/dev/null
command -v chafa >/dev/null
command -v jq >/dev/null
command -v pdftotext >/dev/null

git_version="\$(git --version | grep -oE '[0-9]+\.[0-9]+([.][0-9]+)?')"
zsh_version="\$(zsh --version | grep -oE '[0-9]+\.[0-9]+([.][0-9]+)?')"
nvim_version="\$(nvim --version | awk 'NR==1 {print \$2}' | sed 's/^v//')"
tmux_version="\$(tmux -V | grep -oE '[0-9]+\.[0-9]+[a-z]?')"
nvm_version="\$(zsh -ic 'command -v nvm >/dev/null && nvm --version')"
node_version="\$(zsh -ic 'command -v node >/dev/null && node -v')"
npm_version="\$(zsh -ic 'command -v npm >/dev/null && npm -v')"

assert_min_version "git" "\$git_version" "2.19.0"
assert_min_version "zsh" "\$zsh_version" "4.3.11"
assert_min_version "nvim" "\$nvim_version" "0.8.0"
assert_min_version "tmux" "\$tmux_version" "3.2.1"
test -n "\$nvm_version"
test -n "\$node_version"
test -n "\$npm_version"

ls_alias_output="\$(zsh -ic 'alias ls')"
if printf '%s\n' "\$ls_alias_output" | grep -F -- '--color=auto' >/dev/null; then
  echo "macOS zsh alias unexpectedly uses GNU ls color flags" >&2
  exit 1
fi

diff_output="\$(chezmoi diff --source="\$repo_root")"
if [[ -n "\$diff_output" ]]; then
  printf '%s\n' "\$diff_output"
  exit 1
fi
EOF
}

run_case() {
  local case_name="$1"
  local image_ref="$2"

  (
    set -euo pipefail
    local vm_name="dotfiles-${case_name}-$$"
    local ip=""

    trap 'cleanup_vm "$vm_name"' EXIT

    printf '==> Verifying macOS %s\n' "$case_name"
    tart clone "$image_ref" "$vm_name" >/dev/null
    tart run --dir="repo:${repo_root}:ro" "$vm_name" >/tmp/"${vm_name}".log 2>&1 &

    ip="$(wait_for_ssh "$vm_name")"
    run_remote_validation "$ip"
    printf 'macOS %s OK\n' "$case_name"
  )
}

ensure_host_prereqs

for entry in "${macos_images[@]}"; do
  IFS='|' read -r case_name image_ref <<< "$entry"
  run_case "$case_name" "$image_ref"
done
