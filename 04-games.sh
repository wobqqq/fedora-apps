#!/usr/bin/env bash
#
# 04-games.sh — gaming on Fedora.
#
# Installs Steam (from RPM Fusion nonfree) and GameMode, which applies on-demand
# performance tuning (CPU governor, etc.) while a game runs.
#
# Needs RPM Fusion — run ./00-base.sh first.
#
#   ./04-games.sh

set -euo pipefail
sudo -v

sudo dnf install -y steam gamemode

echo "Steam installed."
echo
echo "Tips for a game's Steam launch options:"
echo "  • Better performance while playing:   gamemoderun %command%"
echo "  • Run on the NVIDIA GPU (hybrid laptop):"
echo "      __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia %command%"
echo "  • Both at once:"
echo "      gamemoderun __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia %command%"
echo
echo "For non-Steam games, enable Steam Play (Proton) in Steam > Settings > Compatibility."
