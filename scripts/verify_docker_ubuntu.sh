#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ubuntu_versions=(20.04 22.04 24.04)

version_from_command() {
  local command_output="$1"
  printf '%s\n' "$command_output" | grep -oE '[0-9]+\.[0-9]+([.][0-9]+)?[a-z]?'
}

run_case() {
  local ubuntu_version="$1"

  echo "==> Verifying Ubuntu ${ubuntu_version}"
  docker run --rm -i -v "$repo_root":/work:ro "ubuntu:${ubuntu_version}" bash -s -- "$ubuntu_version" <<'EOF'
set -euo pipefail

ubuntu_version="$1"
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq >/dev/null
apt-get install -y -qq bash ca-certificates curl git sudo tar >/dev/null

useradd -m -s /bin/bash tester
echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester
chmod 440 /etc/sudoers.d/tester

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin >/dev/null

sudo -u tester -H bash -lc 'chezmoi apply --refresh-externals=always --source=/work'
sudo -u tester -H bash -lc 'chezmoi apply --refresh-externals=always --source=/work'

sudo -u tester -H bash -lc 'test -f "$HOME/.zshrc"'
sudo -u tester -H bash -lc 'test -f "$HOME/.tmux.conf"'
sudo -u tester -H bash -lc 'test -d "$HOME/.config/nvim"'
sudo -u tester -H bash -lc 'test -d "$HOME/.config/ranger"'
sudo -u tester -H bash -lc 'test -f "$HOME/.config/zsh/nvm.zsh"'
sudo -u tester -H bash -lc 'test -d "$HOME/.oh-my-zsh"'
sudo -u tester -H bash -lc 'test -d "$HOME/.config/ranger/plugins/ranger_devicons"'
sudo -u tester -H bash -lc 'test -s "$HOME/.nvm/nvm.sh"'

git_version="$(sudo -u tester -H bash -lc 'git --version')"
zsh_version="$(sudo -u tester -H bash -lc 'zsh --version')"
nvim_version="$(sudo -u tester -H bash -lc 'PATH="$HOME/.local/bin:$PATH" nvim --version | head -n 1')"
tmux_version="$(sudo -u tester -H bash -lc 'PATH="$HOME/.local/bin:$PATH" tmux -V')"
nvm_version="$(sudo -u tester -H zsh -ic 'command -v nvm >/dev/null && nvm --version')"

git_value="$(printf '%s\n' "$git_version" | grep -oE '[0-9]+\.[0-9]+([.][0-9]+)?')"
zsh_value="$(printf '%s\n' "$zsh_version" | grep -oE '[0-9]+\.[0-9]+([.][0-9]+)?')"
nvim_value="$(printf '%s\n' "$nvim_version" | grep -oE '[0-9]+\.[0-9]+([.][0-9]+)?')"
tmux_value="$(printf '%s\n' "$tmux_version" | grep -oE '[0-9]+\.[0-9]+[a-z]?')"

dpkg --compare-versions "$git_value" ge 2.19.0
dpkg --compare-versions "$zsh_value" ge 4.3.11
dpkg --compare-versions "$nvim_value" eq 0.10.4
dpkg --compare-versions "$tmux_value" eq 3.5a
test -n "$nvm_version"

diff_output="$(sudo -u tester -H bash -lc 'chezmoi diff --source=/work')"
if [[ -n "$diff_output" ]]; then
  printf '%s\n' "$diff_output"
  exit 1
fi

printf 'Ubuntu %s OK\n' "$ubuntu_version"
EOF
}

for ubuntu_version in "${ubuntu_versions[@]}"; do
  run_case "$ubuntu_version"
done
