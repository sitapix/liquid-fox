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

# Set required about:config preferences via user.js
# This only adds/updates our two prefs — all other user.js content is preserved.
USER_JS="$TARGET/user.js"

add_pref() {
  local name="$1"
  local line="$2"
  if [ -f "$USER_JS" ] && grep -qF "\"$name\"" "$USER_JS"; then
    # Remove the existing line (exact string match, not regex)
    grep -vF "\"$name\"" "$USER_JS" > "$USER_JS.tmp" && mv "$USER_JS.tmp" "$USER_JS"
  fi
  echo "$line" >> "$USER_JS"
}

add_pref "toolkit.legacyUserProfileCustomizations.stylesheets" \
  'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

add_pref "widget.macos.titlebar-blend-mode.behind-window" \
  'user_pref("widget.macos.titlebar-blend-mode.behind-window", true);'

echo
echo "Done! Preferences have been set automatically."
echo "Restart Firefox to activate Liquid Fox."
