#!/usr/bin/env bash
#
# 00-base.sh — base setup for a fresh Fedora (GNOME) install.
#
# Enables RPM Fusion + Flathub, updates the system, removes preinstalled bloat,
# installs core utilities, turns on a simple firewall, creates an SSH key, and
# applies a couple of desktop tweaks (HiDPI scaling, clipboard history).
#
# RUN THIS FIRST — the other scripts assume RPM Fusion and Flathub are enabled.
# Run as your normal user (it calls sudo itself):
#
#   ./00-base.sh

set -euo pipefail
sudo -v   # ask for the sudo password once, up front

FEDORA_VER=$(rpm -E %fedora)

# --- RPM Fusion (needed later for VLC, Steam, unrar, full ffmpeg, NVIDIA) ---
sudo dnf install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"

# --- Full system upgrade ---
sudo dnf upgrade --refresh -y

# --- Remove preinstalled apps you don't use ---
sudo dnf remove -y chromium thunderbird || true
sudo dnf autoremove -y || true

# --- Full ffmpeg (codecs) ---
# Fedora ships the stripped-down ffmpeg-free. Swap it for the full ffmpeg from
# RPM Fusion so every media codec works (VLC playback, yazi video previews, ...).
if rpm -q ffmpeg-free >/dev/null 2>&1; then
  sudo dnf swap -y --allowerasing ffmpeg-free ffmpeg
else
  sudo dnf install -y --allowerasing ffmpeg
fi

# --- Core utilities ---
sudo dnf install -y \
  wget curl git make \
  zip unzip unrar \
  openssh-clients \
  ufw flatpak gnome-extensions-app xdg-utils

# --- Flathub (the source for every Flatpak app in the other scripts) ---
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo

# --- Firewall: Fedora ships firewalld; switch to the simpler ufw ---
sudo systemctl disable --now firewalld 2>/dev/null || true
sudo systemctl enable --now ufw
sudo ufw --force enable
sudo ufw status verbose

# --- SSH key (ed25519; never overwrites an existing key) ---
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  echo "SSH key already exists at ~/.ssh/id_ed25519 — keeping it."
else
  ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "${USER}@$(hostname)"
fi

# --- HiDPI scaling (for the built-in 2560x1600 laptop panel) ---
# GNOME won't offer a true 150% scale (2560 isn't divisible by 1.5), so the trick
# is: display scale 125% + font scaling 1.2 == effective ~150%, native resolution
# stays crisp. Fractional scaling must be on for the 125% option to appear.
# NOTE: the 125% display scale itself is set by hand in Settings -> Displays.
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']" 2>/dev/null || true
gsettings set org.gnome.desktop.interface text-scaling-factor 1.2 2>/dev/null || true

# --- GNOME Shell extensions ---
# Installed from extensions.gnome.org by their numeric ID (the number in the URL,
# e.g. .../extension/779/clipboard-indicator/ -> 779). For each one we ask the
# site for the build matching the running shell version, install it per-user, and
# enable it (a freshly installed extension activates on the next login on Wayland).
GNOME_EXTENSIONS=(
  779    # Clipboard Indicator      — clipboard history in the top bar (Wayland-friendly)
  615    # AppIndicator Support     — legacy system-tray / status icons
  6281   # Wallpaper Slideshow      — rotate the desktop wallpaper on a timer
  7472   # Lock Screen Extension    — customize the lock screen
  1414   # Unblank                  — keep the screen on / readable while locked
)
if command -v gnome-extensions >/dev/null 2>&1; then
  SHELL_VER=$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -1)
  for id in "${GNOME_EXTENSIONS[@]}"; do
    info=$(curl -fsSL "https://extensions.gnome.org/extension-info/?pk=${id}&shell_version=${SHELL_VER}" 2>/dev/null || true)
    uuid=$(echo "$info" | grep -oP '"uuid":\s*"\K[^"]+' || true)
    url=$(echo "$info"  | grep -oP '"download_url":\s*"\K[^"]+' || true)
    if [[ -z "$uuid" || -z "$url" ]]; then
      echo "GNOME extension $id not available for shell $SHELL_VER — skipping."
      continue
    fi
    tmp=$(mktemp -d)
    curl -fsSL "https://extensions.gnome.org${url}" -o "$tmp/ext.zip"
    gnome-extensions install --force "$tmp/ext.zip" || true
    # Try to enable live; on Wayland a just-installed extension can't be, so queue
    # it in gsettings and GNOME enables it on the next login.
    if ! gnome-extensions enable "$uuid" 2>/dev/null; then
      cur=$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo "[]")
      case "$cur" in
        *"$uuid"*)       : ;;
        "@as []"|"[]")   gsettings set org.gnome.shell enabled-extensions "['$uuid']" ;;
        *)               gsettings set org.gnome.shell enabled-extensions "${cur%]}, '$uuid']" ;;
      esac
    fi
    rm -rf "$tmp"
    echo "GNOME extension installed: $uuid"
  done
  echo "GNOME extensions ready (active after the next login)."
fi

echo
echo "Your public SSH key (add it to GitHub / GitLab / your servers):"
cat "$HOME/.ssh/id_ed25519.pub"
echo
echo "Base setup done. Next run any of: 01-everyday.sh  02-terminal.sh  03-development.sh  04-games.sh"
echo "Log out and back in so all changes take effect."
