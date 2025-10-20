#!/usr/bin/env bash
# Installs VS Code extensions listed in extensions.txt
#
# Usage:
#   wget -O - https://raw.githubusercontent.com/kevinpinscoe/vscode-settings/refs/heads/main/install-extensions.sh | bash
# Optional env:
#   EXTENSIONS_URL=...  (override the URL to extensions.txt)
#   CODE_CLI=...        (explicit path/command for VS Code CLI, e.g. /usr/bin/code)
#   FORCE_REINSTALL=1   (reinstall even if already present)
#   DRY_RUN=1           (print actions only)

set -euo pipefail

DEFAULT_EXT_URL="https://raw.githubusercontent.com/kevinpinscoe/vscode-settings/refs/heads/main/extensions.txt"
EXT_URL="${EXTENSIONS_URL:-$DEFAULT_EXT_URL}"

log() { printf "\033[1;34m[install-extensions]\033[0m %s\n" "$*" >&2; }
err() { printf "\033[1;31m[install-extensions]\033[0m %s\n" "$*" >&2; }

# --- Find a VS Code CLI ---
detect_code_cli() {
  if [[ -n "${CODE_CLI:-}" ]]; then
    command -v "$CODE_CLI" >/dev/null 2>&1 && { echo "$CODE_CLI"; return; }
    err "CODE_CLI='$CODE_CLI' not found on PATH."
    exit 2
  fi

  # Try common variants, in priority order
  local candidates=(code codium code-insiders code-oss)
  for c in "${candidates[@]}"; do
    if command -v "$c" >/dev/null 2>&1; then
      echo "$c"
      return
    fi
  done

  # macOS hint if missing
  if [[ "$OSTYPE" == darwin* ]]; then
    err "VS Code CLI not found. In VS Code, run: 'Shell Command: Install \"code\" command in PATH'."
  fi
  err "No VS Code CLI found (looked for: code, codium, code-insiders, code-oss)."
  exit 2
}

CODE_CMD="$(detect_code_cli)"
log "Using VS Code CLI: $CODE_CMD"

# --- Fetch extensions.txt ---
log "Fetching extension list from: $EXT_URL"
if ! MAP_RAW="$(curl -fsSL "$EXT_URL")"; then
  err "Failed to fetch extensions list from $EXT_URL"
  exit 3
fi

# Normalize: strip comments (# ...), trim space, drop blanks
readarray -t EXTENSIONS < <(
  printf "%s\n" "$MAP_RAW" \
    | sed 's/#.*$//' \
    | sed 's/^[[:space:]]\+//; s/[[:space:]]\+$//' \
    | sed '/^[[:space:]]*$/d'
)

if (( ${#EXTENSIONS[@]} == 0 )); then
  err "No extensions found in list (after removing comments/blank lines)."
  exit 0
fi

# --- Determine what's already installed ---
INSTALLED="$($CODE_CMD --list-extensions || true)"
FORCE="${FORCE_REINSTALL:-0}"
DRY="${DRY_RUN:-0}"

log "Found ${#EXTENSIONS[@]} extensions in list."
(( FORCE == 1 )) && log "FORCE_REINSTALL=1 (will reinstall even if already present)."
(( DRY == 1 )) && log "DRY_RUN=1 (no changes will be made)."

# --- Install loop ---
missing_count=0
installed_count=0
skipped_count=0
failed_count=0

for ext in "${EXTENSIONS[@]}"; do
  if (( FORCE != 1 )) && grep -q -i -x "$ext" <<<"$INSTALLED"; then
    log "Already installed: $ext (skipping)"
    ((skipped_count++))
    continue
  fi

  (( DRY == 1 )) && { log "[dry-run] Would install: $ext"; ((missing_count++)); continue; }

  log "Installing: $ext"
  if "$CODE_CMD" --install-extension "$ext" --force >/dev/null; then
    ((installed_count++))
  else
    err "Failed to install: $ext"
    ((failed_count++))
  fi
done

log "Done. Installed: $installed_count, Skipped: $skipped_count, To-install(dry): $missing_count, Failed: $failed_count"
(( failed_count > 0 )) && exit 4 || exit 0
