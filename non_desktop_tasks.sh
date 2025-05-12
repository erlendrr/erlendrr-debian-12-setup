#!/usr/bin/bash

echo "========== Running tasks that don't require a desktop =========="

# ---------------------------
# Check for sudo privileges
# ---------------------------

echo "========== Checking for sudo privileges =========="
sudo -v || { echo "[ERROR] This script requires sudo privileges. Exiting."; exit 1; }

# ---------------------------
# NVIDIA Drivers Check / Install
# ---------------------------

echo "========== Checking NVIDIA Drivers =========="

if dpkg -l | grep -qw nvidia-driver; then
    echo "[INFO] NVIDIA driver is already installed. Skipping."
else
    read -p "Do you want to install NVIDIA drivers? [y/N]: " install_nvidia

    if [[ "$install_nvidia" =~ ^[Yy]$ ]]; then
        echo "[INFO] NVIDIA driver installation selected."

        REPO_LINE="deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware"
        if ! grep -Fxq "$REPO_LINE" /etc/apt/sources.list; then
            echo "[INFO] Adding required NVIDIA repository to /etc/apt/sources.list"
            echo "$REPO_LINE" | sudo tee -a /etc/apt/sources.list
        else
            echo "[INFO] Required NVIDIA repository is already configured."
        fi

        echo "[INFO] Installing NVIDIA driver..."
        sudo apt update
        sudo apt install -y nvidia-driver firmware-misc-nonfree
        echo "[INFO] NVIDIA driver installation complete. A reboot is recommended."

        read -p "Do you want to reboot now? [y/N]: " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            echo "[INFO] Rebooting system..."
            sudo reboot
        else
            echo "[INFO] You can reboot later when convenient."
        fi
    else
        echo "[INFO] Skipping NVIDIA driver setup."
    fi
fi

# ---------------------------
# Extra CLI Tools
# ---------------------------

echo "========== Installing Extra CLI Tools =========="

sudo apt update
sudo apt install -y \
    vim \
    curl \
    btop \
    tree \
    exiftool \
    tmux \
    nmap \
    ripgrep \
    git \
    yubikey-manager \
    stow \
    xclip

echo "[INFO] Base packages installed."

# ---------------------------
# Docker Installation
# ---------------------------

echo "========== Checking Docker Installation =========="

if command -v docker >/dev/null 2>&1; then
    echo "[INFO] Docker is already installed. Skipping."
else
    echo "[INFO] Docker not found. Installing..."
    
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    echo "[INFO] Docker installed successfully."
fi

# ---------------------------
# GitHub CLI Installation
# ---------------------------

echo "========== Checking GitHub CLI Installation =========="

if command -v gh >/dev/null 2>&1; then
    echo "[INFO] GitHub CLI is already installed. Skipping."
else
    echo "[INFO] GitHub CLI not found. Installing..."

    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O $out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
           sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y

    echo "[INFO] GitHub CLI installed successfully."
fi

# ---------------------------
# NVM + Node.js Installation
# ---------------------------

echo "========== Setting up NVM and Node.js =========="

NVM_DIR="$HOME/.nvm"

if [ -d "$NVM_DIR" ]; then
    echo "[INFO] NVM is already installed. Skipping NVM installation."
else
    echo "[INFO] Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
fi

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js 22 if not already installed
if nvm ls 22 &>/dev/null; then
    echo "[INFO] Node.js 22 is already installed via NVM."
else
    echo "[INFO] Installing Node.js 22 via NVM..."
    nvm install 22
fi

# Set default to 22
nvm alias default 22
nvm use default

echo "[INFO] NVM with Node.js 22 set up."

# ---------------------------
# Install bun 
# ---------------------------

# Install dependencies
sudo apt install unzip -y
curl -fsSL https://bun.sh/install | bash

# ---------------------------
# Rust Installation
# ---------------------------

echo "========== Checking Rust Installation =========="

if command -v rustup >/dev/null 2>&1; then
    echo "[INFO] Rust is already installed. Skipping."
else
    echo "[INFO] Installing Rust via rustup..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y

    # Source cargo immediately (for current script run)
    . "$HOME/.cargo/env"
fi

echo "[INFO] Rust and Cargo are ready to use."

# ---------------------------
# Install OpenSSL Libraries (used for some rust CLI tools)
# ---------------------------

sudo apt-get install pkg-config libssl-dev

# ---------------------------
# Install rust tools
# ---------------------------

# Custom script made by Erlend Ryan to set up DNS pointer to IP on machine
cargo install domeneshop-ip

# ---------------------------
# Install postgresql
# ---------------------------

sudo apt install curl ca-certificates
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
. /etc/os-release
sudo sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
sudo apt update
sudo apt -y install postgresql

# ---------------------------
# Set up dotfiles with GNU Stow 
# ---------------------------

echo "========== Creating symlinks for dotfiles with GNU Stow =========="
stow -t $HOME ./dotfiles && echo "ok"

echo "========== Basic Setup Complete =========="

