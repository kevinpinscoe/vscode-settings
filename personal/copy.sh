#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$HOME/Projects/kevininscoe.com/vscode-settings/personal"

echo "This will copy the following files into $REPO_DIR:"
echo "  ~/.config/Code/User/settings.json"
echo "  ~/Projects/home-projects.code-workspace"
echo ""
read -rp "Are you sure? (y/N): " confirm
[[ "${confirm,,}" == "y" ]] || { echo "Aborted."; exit 0; }

cp -v "$HOME/.config/Code/User/settings.json" "$REPO_DIR/settings.json"
cp -v "$HOME/Projects/home-projects.code-workspace" "$REPO_DIR/home-projects.code-workspace"

echo ""
echo "Done. Review changes with: git -C \"$REPO_DIR\" diff"