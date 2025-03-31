#!/bin/bash
#
# remove-domeneshop-dns-pointer-to-dynamic-ip.sh
#
# Author: Erlend Ryan <erlendryan@pm.me>
# Description: Removes DNS auto-update script, cron job, and optionally saved credentials
# Version: 1.1
# Updated: 2025-03-27

ENV_FILE="$HOME/.domeneshop.env"
UPDATE_SCRIPT="/usr/local/bin/update-dns.sh"

echo "🧹 Domeneshop DNS updater removal script"

# Confirm removal
read -p "⚠️  Are you sure you want to remove the DNS updater and related config? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "❎ Removal cancelled."
  exit 0
fi

# Remove cron job
echo "🗑️  Removing cron job..."
crontab -l 2>/dev/null | grep -v "$UPDATE_SCRIPT" | crontab -

# Remove update script
if [ -f "$UPDATE_SCRIPT" ]; then
  echo "🗑️  Deleting update script at $UPDATE_SCRIPT..."
  sudo rm -f "$UPDATE_SCRIPT"
else
  echo "⚠️  Update script not found at $UPDATE_SCRIPT"
fi

# Ask to remove env file regardless
if [ -f "$ENV_FILE" ]; then
  read -p "🗂️  Do you want to remove the saved credentials at $ENV_FILE? (y/N): " REMOVE_ENV
  if [[ "$REMOVE_ENV" =~ ^[Yy]$ ]]; then
    rm -f "$ENV_FILE"
    echo "🧾 Removed saved configuration."
  else
    echo "💾 Config file kept at $ENV_FILE"
  fi
else
  echo "⚠️  No saved credentials found at $ENV_FILE"
fi

echo "✅ DNS updater successfully removed."

