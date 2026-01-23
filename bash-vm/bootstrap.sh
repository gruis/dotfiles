#!/usr/bin/env bash
set -euo pipefail

# One-liner usage:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/gruis/dotfiles/master/bash-vm/bootstrap.sh)" -- \
#     --github gruis
#
# Or:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/gruis/dotfiles/master/bash-vm/bootstrap.sh)" -- \
#     --pubkey "ssh-ed25519 AAAA... you@host"
#
# Optional:
#   --force           overwrite existing ~/.bashrc and ~/.inputrc (else backup)
#   --repo-base URL   override where to fetch files from

usage() {
  cat <<'EOF'
Options:
  --github USERNAME         Fetch https://github.com/USERNAME.keys and add to ~/.ssh/authorized_keys
  --pubkey "ssh-..."        Add a single public key line to ~/.ssh/authorized_keys
  --pubkey-file PATH        Add public key(s) from a local file to ~/.ssh/authorized_keys
  --force                   Overwrite ~/.bashrc and ~/.inputrc instead of backing up
  --repo-base URL           Base URL for fetching dotfiles (raw). Default points to gruis/dotfiles master.
  --stage NAME              Run a stage after base bash-vm setup (repeatable)
  --list-stages             List available stages and exit
Examples:
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/gruis/dotfiles/master/bash-vm/bootstrap.sh)" -- --github gruis
EOF
}

FORCE=0
GITHUB_USER="gruis"
PUBKEY=""
PUBKEY_FILE=""
LIST_STAGES=0
STAGES=()

REPO_BASE_DEFAULT="https://raw.githubusercontent.com/gruis/dotfiles/master/bash-vm"
REPO_BASE="$REPO_BASE_DEFAULT"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --github) GITHUB_USER="${2:-}"; shift 2;;
    --pubkey) PUBKEY="${2:-}"; shift 2;;
    --pubkey-file) PUBKEY_FILE="${2:-}"; shift 2;;
    --force) FORCE=1; shift;;
    --repo-base) REPO_BASE="${2:-}"; shift 2;;
    --stage) STAGES+=("${2:-}"); shift 2;;
    --list-stages) LIST_STAGES=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

list_stages() {
  cat <<'EOF'
Available stages:
  shell-extras  - tmux + mosh + oh-my-posh + fonts + ssh key
  docker        - Docker Engine from official repo + compose plugin
  codex         - Codex CLI (Node.js 20.x via NodeSource + npm)
EOF
}

if [[ "$LIST_STAGES" -eq 1 ]]; then
  list_stages
  exit 0
fi

if [[ -z "$GITHUB_USER" && -z "$PUBKEY" && -z "$PUBKEY_FILE" ]]; then
  echo "ERROR: Provide --github USERNAME or --pubkey or --pubkey-file PATH"
  usage
  exit 1
fi

need_cmd() { command -v "$1" >/dev/null 2>&1; }

fetch() {
  # fetch URL -> stdout
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

backup_or_overwrite() {
  local dst="$1"
  if [[ -e "$dst" && "$FORCE" -ne 1 ]]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    mv "$dst" "${dst}.bak.${ts}"
  fi
}

write_file_from_repo() {
  local name="$1" dst="$2"
  backup_or_overwrite "$dst"
  fetch "${REPO_BASE}/${name}" > "$dst"
}

run_stage() {
  local name="$1"
  case "$name" in
    shell-extras|docker|codex) ;;
    *) echo "Unknown stage: $name"; list_stages; exit 1;;
  esac
  local tmp
  tmp="$(mktemp)"
  fetch "${REPO_BASE}/stages/${name}.sh" > "$tmp"
  chmod +x "$tmp"
  REPO_BASE="$REPO_BASE" bash "$tmp"
  rm -f "$tmp"
}

# --- Dotfiles ---
mkdir -p "$HOME/.bash-vm"

# aliases are optional (if missing, ignore)
if fetch "${REPO_BASE}/aliases.sh" >/dev/null 2>&1; then
  fetch "${REPO_BASE}/aliases.sh" > "$HOME/.bash-vm/aliases.sh"
fi

# bashrc/inputrc must exist
write_file_from_repo "bashrc" "$HOME/.bashrc"
write_file_from_repo "inputrc" "$HOME/.inputrc"

# --- SSH authorized_keys ---
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

add_key_lines() {
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! grep -qxF "$line" "$HOME/.ssh/authorized_keys"; then
      echo "$line" >> "$HOME/.ssh/authorized_keys"
    fi
  done
}

if [[ -n "$PUBKEY_FILE" ]]; then
  cat "$PUBKEY_FILE" | add_key_lines
elif [[ -n "$PUBKEY" ]]; then
  printf '%s\n' "$PUBKEY" | add_key_lines
else
  fetch "https://github.com/${GITHUB_USER}.keys" | add_key_lines
fi

if [[ "${#STAGES[@]}" -gt 0 ]]; then
  for stage in "${STAGES[@]}"; do
    run_stage "$stage"
  done
fi

echo "Done."
echo "Open a new shell or run: source ~/.bashrc"
