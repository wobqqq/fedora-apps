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
source "$(dirname "$0")/lib/common.sh"
sudo -v

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

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

# --- lazygit and lazydocker: terminal UIs for git and Docker (not in the Fedora repos) ---
# Each release publishes checksums.txt; the archive is installed only if it matches.
install_release_binary() {  # repo, binary, asset name with {version}
  local repo=$1 binary=$2 pattern=$3 tag asset base
  command -v "$binary" >/dev/null 2>&1 && return 0
  tag=$(github_latest_tag "$repo")
  asset=${pattern//\{version\}/${tag#v}}
  base="https://github.com/${repo}/releases/download/${tag}"
  download_verified "$base/$asset" "$work/$asset" "$(curl -fsSL "$base/checksums.txt" | checksum_for "$asset")"
  sudo tar -xzf "$work/$asset" -C /usr/local/bin "$binary"
}
install_release_binary jesseduffield/lazygit lazygit 'lazygit_{version}_linux_x86_64.tar.gz'
# NOTE the capital "Linux" in lazydocker's asset name (lazygit uses lowercase).
install_release_binary jesseduffield/lazydocker lazydocker 'lazydocker_{version}_Linux_x86_64.tar.gz'

# --- PhpStorm (extracted into /opt) ---
if ! compgen -G '/opt/PhpStorm-*' >/dev/null; then
  echo "Fetching the latest PhpStorm download link..."
  release=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=PS&latest=true&type=release")
  PHPSTORM_URL=$(jq -er '.PS[0].downloads.linux.link' <<<"$release")
  PHPSTORM_SHA256=$(curl -fsSL "$(jq -er '.PS[0].downloads.linux.checksumLink' <<<"$release")" | cut -d' ' -f1)
  curl -fL --progress-bar -o "$work/phpstorm.tar.gz" "$PHPSTORM_URL"
  verify_sha256 "$work/phpstorm.tar.gz" "$PHPSTORM_SHA256"
  sudo tar -xzf "$work/phpstorm.tar.gz" -C /opt
  echo "PhpStorm extracted — launch with: /opt/PhpStorm-*/bin/phpstorm.sh"
fi

# --- Xdebug 3 firewall rule ---
# PhpStorm listens on port 9003; Xdebug (running inside Docker) connects back to
# it. Allow 9003 only from Docker networks, not the whole internet. Delete this
# line if you don't run PHP in Docker.
sudo ufw allow from 172.16.0.0/12 to any port 9003 proto tcp || true

echo "Development tools installed. Log out and back in for Wireshark capture permissions."
