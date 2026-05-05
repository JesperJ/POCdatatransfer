#!/usr/bin/env bash
# deploy/setup-env.sh
# Run once on a new server to create /etc/datatransfer/ and populate the env file.
# Usage: sudo bash deploy/setup-env.sh <environment>
# Example: sudo bash deploy/setup-env.sh prod

set -euo pipefail

ENV="${1:-}"
if [[ -z "$ENV" ]]; then
  echo "Usage: $0 <dev|staging|prod>"
  exit 1
fi

CONFIG_DIR="/home/jesper/POCdatatransfers"
ENV_FILE="$CONFIG_DIR/.env.$ENV"
TEMPLATE=".env.$ENV.example"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Template $TEMPLATE not found. Run from the repo root."
  exit 1
fi

# Create config dir with restrictive permissions (root-owned, no world read)
mkdir -p "$CONFIG_DIR"
chmod 750 "$CONFIG_DIR"

if [[ -f "$ENV_FILE" ]]; then
  echo "$ENV_FILE already exists — not overwriting."
  echo "Edit it manually: sudo nano $ENV_FILE"
else
  cp "$TEMPLATE" "$ENV_FILE"
  chmod 640 "$ENV_FILE"
  echo "Created $ENV_FILE from template."
  echo "Fill in the values: sudo nano $ENV_FILE"
fi
