#!/bin/bash
#
# Liquid Fox installer
# Copies chrome/ into the active Firefox profile and reminds you
# which about:config flags to flip.

set -euo pipefail

PROFILE_DIR="$HOME/Library/Application Support/Firefox/Profiles"

# Find the default profile directory
if [ ! -d "$PROFILE_DIR" ]; then
  echo "Error: Firefox profiles directory not found at $PROFILE_DIR"
  exit 1
fi

# List available profiles
PROFILES=()
while IFS= read -r dir; do
  PROFILES+=("$dir")
done < <(find "$PROFILE_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

if [ ${#PROFILES[@]} -eq 0 ]; then
  echo "Error: No Firefox profiles found."
  exit 1
fi

echo "Available Firefox profiles:"
for i in "${!PROFILES[@]}"; do
  echo "  [$i] $(basename "${PROFILES[$i]}")"
done
echo

read -rp "Select a profile number [0]: " SELECTION
SELECTION=${SELECTION:-0}

TARGET="${PROFILES[$SELECTION]}"
echo
echo "Installing to: $TARGET"

# Copy chrome directory
mkdir -p "$TARGET/chrome"
cp -v chrome/userChrome.css "$TARGET/chrome/userChrome.css"

echo
echo "Done! Now open about:config in Firefox and set these to true:"
echo
echo "  toolkit.legacyUserProfileCustomizations.stylesheets"
echo "  widget.macos.titlebar-blend-mode.behind-window"
echo
echo "Then restart Firefox."
