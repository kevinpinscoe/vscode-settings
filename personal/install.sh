#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$HOME/Projects/kevininscoe.com/vscode-settings/personal"

echo "This will overwrite the following files from $REPO_DIR:"
echo "  ~/.config/Code/User/settings.json"
echo "  ~/Projects/home-projects.code-workspace"
echo ""
read -rp "Are you sure? (y/N): " confirm
[[ "${confirm,,}" == "y" ]] || { echo "Aborted."; exit 0; }

cp -v "$REPO_DIR/settings.json" "$HOME/.config/Code/User/settings.json"
cp -v "$REPO_DIR/home-projects.code-workspace" "$HOME/Projects/home-projects.code-workspace"

echo ""
echo "Done."