#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$HOME/Projects/kevininscoe.com/vscode-settings/professional"

SRC_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
SRC_WORKSPACE="$HOME/Projects/kevins-acst.code-workspace"

echo "This will copy the following files into $REPO_DIR:"
echo "  $SRC_SETTINGS"
echo "  $SRC_WORKSPACE"
echo ""
read -rp "Are you sure? (y/N): " confirm
[[ "${confirm,,}" == "y" ]] || { echo "Aborted."; exit 0; }

mkdir -p "$REPO_DIR"

cp -v "$SRC_SETTINGS" "$REPO_DIR/settings.json"
cp -v "$SRC_WORKSPACE" "$REPO_DIR/kevins-acst.code-workspace"

echo ""
echo "Done. Review changes with: git -C \"$REPO_DIR\" diff"