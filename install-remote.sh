#!/bin/bash
#
# Liquid Fox — remote installer
# Usage: curl -sL https://raw.githubusercontent.com/sitapix/liquid-fox/main/install-remote.sh | bash
#
# Downloads the latest release, runs the installer, then cleans up.

set -uo pipefail

REPO="sitapix/liquid-fox"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading Liquid Fox..."
if command -v git &>/dev/null; then
  git clone --depth 1 "https://github.com/$REPO.git" "$TMPDIR/liquid-fox" 2>/dev/null
else
  # Fallback: download tarball without git
  curl -sL "https://github.com/$REPO/archive/refs/heads/main.tar.gz" | tar xz -C "$TMPDIR"
  mv "$TMPDIR"/liquid-fox-* "$TMPDIR/liquid-fox"
fi

if [ ! -f "$TMPDIR/liquid-fox/install.sh" ]; then
  echo "Error: Download failed."
  exit 1
fi

echo
cd "$TMPDIR/liquid-fox" && bash install.sh
