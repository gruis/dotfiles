#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }

fetch() {
  local url="$1"
  if need_cmd curl; then
    curl -fsSL "$url"
  elif need_cmd wget; then
    wget -qO- "$url"
  else
    echo "ERROR: need curl or wget"
    exit 1
  fi
}

ensure_apt_packages() {
  sudo apt-get update
  sudo apt-get install -y "$@"
}

install_tmux_and_mosh() {
  ensure_apt_packages tmux mosh ncurses-term
  mkdir -p "$HOME/.bash-vm"
  if [[ -n "${REPO_BASE:-}" ]]; then
    fetch "${REPO_BASE}/.tmux.conf" > "$HOME/.bash-vm/.tmux.conf"
  fi
  if [[ -f "$HOME/.tmux.conf" ]]; then
    cp -f "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$(date +%Y%m%d-%H%M%S)"
  fi
  cp -f "$HOME/.bash-vm/.tmux.conf" "$HOME/.tmux.conf" 2>/dev/null || true
}

install_oh_my_posh() {
  ensure_apt_packages curl unzip fontconfig

  mkdir -p "$HOME/.local/bin"
  if ! need_cmd oh-my-posh; then
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
  fi

  local font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  curl -fsSL -o "$tmp_dir/Hack_NF.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
  unzip -o -q "$tmp_dir/Hack_NF.zip" -d "$font_dir"
  rm -rf "$tmp_dir"
  fc-cache -f

  mkdir -p "$HOME/.config/oh-my-posh"
  if [[ ! -f "$HOME/.config/oh-my-posh/theme.omp.json" ]]; then
    curl -fsSL -o "$HOME/.config/oh-my-posh/theme.omp.json" \
      https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json
  fi
}

ensure_ssh_key() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    local comment
    comment="${USER}@$(hostname -f 2>/dev/null || hostname)"
    ssh-keygen -t ed25519 -a 64 -N "" -f "$HOME/.ssh/id_ed25519" -C "$comment"
  fi
}

install_tmux_and_mosh
install_oh_my_posh
ensure_ssh_key

cat <<'EOF'
Note: If you see boxes or question marks in the prompt, your terminal is not using a Nerd Font.
For SSH sessions, the font must be installed and selected on your *local* machine's terminal.
Set your terminal font to "Hack Nerd Font" (or any Nerd Font) and reconnect.
EOF

echo "shell-extras stage complete."
