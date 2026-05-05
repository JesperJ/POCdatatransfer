#!/usr/bin/env bash
# infra/registry/setup-htpasswd.sh
# Creates the htpasswd file for registry basic auth.
# Run on the server before starting the registry.
# Usage: sudo bash setup-htpasswd.sh <username>

set -euo pipefail

USERNAME="${1:-}"
if [[ -z "$USERNAME" ]]; then
  echo "Usage: $0 <username>"
  exit 1
fi

HTPASSWD_DIR="/etc/datatransfer/registry"
HTPASSWD_FILE="$HTPASSWD_DIR/htpasswd"

if ! command -v htpasswd &>/dev/null; then
  echo "htpasswd not found. Install apache2-utils: sudo apt install apache2-utils"
  exit 1
fi

mkdir -p "$HTPASSWD_DIR"
chmod 750 "$HTPASSWD_DIR"

if [[ -f "$HTPASSWD_FILE" ]]; then
  # Add or update user in existing file
  htpasswd "$HTPASSWD_FILE" "$USERNAME"
else
  # Create new file with bcrypt (-B)
  htpasswd -cB "$HTPASSWD_FILE" "$USERNAME"
fi

chmod 640 "$HTPASSWD_FILE"
echo "htpasswd updated at $HTPASSWD_FILE"
