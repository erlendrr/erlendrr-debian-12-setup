#!/usr/bin/bash

echo "========== Running tasks that require a desktop =========="
# ---------------------------
# Visual Studio Code Installation
# ---------------------------

echo "========== Checking VS Code Installation =========="

if command -v code >/dev/null 2>&1; then
    echo "[INFO] VS Code is already installed. Skipping."
else
    echo "[INFO] VS Code not found. Installing latest version..."

    # Pre-configure auto-add repo
    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections

    # Add Microsoft GPG key and repo
    sudo apt-get install -y wget gpg apt-transport-https
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
        sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg

    # Install VS Code
    sudo apt update
    sudo apt install -y code

    echo "[INFO] VS Code installed successfully."
fi

# ---------------------------
# Other apt-based desktop tools
# ---------------------------

echo "========== Installing Other APT-based Desktop Tools =========="

sudo apt update
sudo apt install -y \
    yubioath-desktop

echo "[INFO] Desktop tools installed."

# ---------------------------
# GNOME Settings Configuration
# ---------------------------

echo "========== Applying GNOME Settings =========="

echo "[INFO] Setting GNOME to prefer dark theme..."
gsettings set org.gnome.desktop.interface color-scheme prefer-dark && echo "ok"

echo "[INFO] Configuring power button to power off..."
gsettings set org.gnome.settings-daemon.plugins.power power-button-action interactive && echo "ok"

echo "[INFO] Disabling automatic suspend when on AC power..."
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' && echo "ok"

echo "[INFO] Setting keyboard layout to Norwegian (no+nodeadkeys)..."
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'no+nodeadkeys')]" && echo "ok"

echo "[INFO] Making Gnome terminal dark..."
gsettings set org.gnome.Terminal.Legacy.Settings theme-variant dark && echo "ok"

echo "[INFO] Changing Caps lock to ESC..."
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']" && echo "ok"

echo "[INFO] Showing weekdays in calendar..."
gsettings set org.gnome.desktop.calendar show-weekdate true && echo "ok"

echo "[INFO] Setting desktop and screensaver background..."
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/gnome/blobs-l.svg' && echo "ok"
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/gnome/blobs-d.svg' && echo "ok"
gsettings set org.gnome.desktop.background primary-color '#241f31' && echo "ok"

gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/gnome/blobs-l.svg' && echo "ok"
gsettings set org.gnome.desktop.screensaver primary-color '#241f31' && echo "ok"

# ---------------------------
# Setting LeftCtrl + LeftAlt as AltGr (Level 3 Shift)
# ---------------------------

echo "========== Configuring LeftCtrl + LeftAlt to work as AltGr =========="

# Update /etc/default/keyboard for Xorg settings
sudo sed -i 's/^XKBOPTIONS=".*"/XKBOPTIONS="lv3:ctrl_alt_switch"/' /etc/default/keyboard

# Apply the changes
echo "[INFO] Reconfiguring keyboard and applying changes..."

# Reconfigure keyboard settings and restart the service
sudo dpkg-reconfigure keyboard-configuration
sudo systemctl restart keyboard-setup

echo "[INFO] LeftCtrl + LeftAlt now set as AltGr. Keyboard configuration complete."

echo "========== Desktop Setup Complete =========="

