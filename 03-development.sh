#!/usr/bin/env bash
#
# 03-development.sh — backend / web development tools.
#
# CLI tools (httpie, database clients, packet capture), the git/docker terminal
# UIs (lazygit, lazydocker), GUI editors and clients (VS Code, DBeaver, Bruno),
# and PhpStorm.
#
# Needs RPM Fusion + Flathub — run ./00-base.sh first.
#
#   ./03-development.sh

set -euo pipefail
sudo -v

# --- CLI development tools from the Fedora repos ---
sudo dnf install -y \
  jq yq httpie \
  mycli pgcli \
  net-tools \
  wireshark

# Let your user capture packets in Wireshark without root (takes effect next login).
sudo usermod -aG wireshark "$USER" || true

# --- GUI development apps from Flathub ---
flatpak install -y --user flathub \
  com.visualstudio.code \
  io.dbeaver.DBeaverCommunity \
  com.usebruno.Bruno

# --- lazygit: terminal UI for git (not in the Fedora repos) ---
if ! command -v lazygit >/dev/null 2>&1; then
  LZG_VER=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+')
  tmp=$(mktemp -d)
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/${LZG_VER}/lazygit_${LZG_VER#v}_linux_x86_64.tar.gz" -o "$tmp/lazygit.tar.gz"
  sudo tar -xzf "$tmp/lazygit.tar.gz" -C /usr/local/bin lazygit
  rm -rf "$tmp"
fi

# --- lazydocker: terminal UI for Docker (not in the Fedora repos) ---
# NOTE the capital "Linux" in lazydocker's asset name (lazygit uses lowercase).
if ! command -v lazydocker >/dev/null 2>&1; then
  LZD_VER=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+')
  tmp=$(mktemp -d)
  curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/${LZD_VER}/lazydocker_${LZD_VER#v}_Linux_x86_64.tar.gz" -o "$tmp/lazydocker.tar.gz"
  sudo tar -xzf "$tmp/lazydocker.tar.gz" -C /usr/local/bin lazydocker
  rm -rf "$tmp"
fi

# --- PhpStorm (extracted into /opt) ---
if [[ ! -d /opt/PhpStorm-* ]]; then
  echo "Fetching the latest PhpStorm download link..."
  PHPSTORM_URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=PS&latest=true&type=release" | jq -r '.PS[0].downloads.linux.link')
  tmp=$(mktemp -d)
  wget -O "$tmp/phpstorm.tar.gz" "$PHPSTORM_URL"
  sudo tar -xzf "$tmp/phpstorm.tar.gz" -C /opt
  rm -rf "$tmp"
  echo "PhpStorm extracted — launch with: /opt/PhpStorm-*/bin/phpstorm.sh"
fi

# --- Xdebug 3 firewall rule ---
# PhpStorm listens on port 9003; Xdebug (running inside Docker) connects back to
# it. Allow 9003 only from Docker networks, not the whole internet. Delete this
# line if you don't run PHP in Docker.
sudo ufw allow from 172.16.0.0/12 to any port 9003 proto tcp || true

echo "Development tools installed. Log out and back in for Wireshark capture permissions."
