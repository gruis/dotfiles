#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }

install_node_20() {
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

install_codex() {
  if ! need_cmd node; then
    install_node_20
  fi
  sudo npm install -g @openai/codex@latest
}

ensure_config_dir() {
  mkdir -p "$HOME/.config/codex"
}

prompt_auth() {
  echo "Run codex now to sign in and configure? (y/n) "
  read -r -n 1
  echo
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    codex || true
  fi
}

install_codex
ensure_config_dir
prompt_auth

echo "codex stage complete."
