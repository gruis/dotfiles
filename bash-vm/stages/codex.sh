#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }

install_node_22() {
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

install_codex() {
  if ! need_cmd node; then
    install_node_22
  fi
  sudo npm install -g @openai/codex@latest
}

ensure_config_dir() {
  mkdir -p "$HOME/.config/codex"
}

prompt_auth() {
  if codex login status >/dev/null 2>&1; then
    echo "Codex already authenticated; skipping login."
    codex login status || true
    echo "Tip: run 'codex' and use /status to see account details."
    return 0
  fi
  echo "Run codex now to sign in and configure? (y/n) "
  read -r -n 1
  echo
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    codex || true
  fi
}

install_codex
ensure_config_dir
if need_cmd node; then
  echo "Node: $(node -v)"
fi
if need_cmd npm; then
  echo "npm: $(npm -v)"
fi
prompt_auth

echo "codex stage complete."
