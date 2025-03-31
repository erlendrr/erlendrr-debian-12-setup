#!/bin/bash
# 
# update-domeneshop-dns-pointer-to-dynamic-ip.sh
# 
# Author: Erlend Ryan <erlendryan@pm.me>
# Description: Auto-updates DNS A record for a dynamic IP using Domeneshop's API
# Version: 1.1
# Updated: 2025-03-27

ENV_FILE="$HOME/.domeneshop.env"

# Check for existing config
if [ -f "$ENV_FILE" ]; then
  echo "🔍 Found existing configuration at $ENV_FILE"
  source "$ENV_FILE"
  echo "📡 Hostname: $DOMENESHOP_HOSTNAME"
  read -p "➡️  Do you want to use the saved configuration? (y/N): " USE_SAVED

  if [[ "$USE_SAVED" =~ ^[Yy]$ ]]; then
    HOSTNAME="$DOMENESHOP_HOSTNAME"
    TOKEN="$DOMENESHOP_TOKEN"
    SECRET="$DOMENESHOP_SECRET"
  else
    echo "📝 Please enter new configuration:"
    read -p "Enter the full hostname (e.g. test.site.com): " HOSTNAME
    read -p "Enter your Domeneshop API token (username): " TOKEN
    read -p "Enter your Domeneshop API secret (password): " SECRET
    echo ""

    # Save new credentials
    cat > "$ENV_FILE" <<EOF
DOMENESHOP_HOSTNAME="$HOSTNAME"
DOMENESHOP_TOKEN="$TOKEN"
DOMENESHOP_SECRET="$SECRET"
EOF
    chmod 600 "$ENV_FILE"
  fi
else
  # No saved config found
  read -p "Enter the full hostname (e.g. test.site.com): " HOSTNAME
  read -p "Enter your Domeneshop API token (username): " TOKEN
  read -p "Enter your Domeneshop API secret (password): " SECRET
  echo ""

  # Save credentials
  cat > "$ENV_FILE" <<EOF
DOMENESHOP_HOSTNAME="$HOSTNAME"
DOMENESHOP_TOKEN="$TOKEN"
DOMENESHOP_SECRET="$SECRET"
EOF
  chmod 600 "$ENV_FILE"
fi

# Check credentials
AUTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -u "$TOKEN:$SECRET" https://api.domeneshop.no/v0/invoices)

if [ "$AUTH_CHECK" != "200" ]; then
  echo "❌ Authentication failed. Please check your API token and secret."
  exit 1
fi

echo "✅ Authentication successful."

# Create the update script
UPDATE_SCRIPT="/usr/local/bin/update-dns.sh"
sudo tee "$UPDATE_SCRIPT" > /dev/null <<'EOF'
#!/bin/bash
source $HOME/.domeneshop.env
curl -s -u "$DOMENESHOP_TOKEN:$DOMENESHOP_SECRET" \
  "https://api.domeneshop.no/v0/dyndns/update?hostname=$DOMENESHOP_HOSTNAME"
EOF

sudo chmod +x "$UPDATE_SCRIPT"

# Add cron job if not already present
CRON_ENTRY="*/5 * * * * $UPDATE_SCRIPT > /dev/null 2>&1"

(crontab -l 2>/dev/null | grep -F "$UPDATE_SCRIPT") > /dev/null || (
  (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
  echo "🕒 Cron job added: DNS will update every 5 minutes."
)

# Run the update immediately
echo "🌐 Running initial DNS update..."
bash "$UPDATE_SCRIPT"

echo -e "\n✅ Setup complete.\n🔐 Credentials stored in: $ENV_FILE\n📡 Hostname: $HOSTNAME"
