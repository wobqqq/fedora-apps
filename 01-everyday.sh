#!/usr/bin/env bash
#
# 01-everyday.sh — everyday desktop apps.
# Browser, chat, media players, image tools, files, password manager, screenshots.
# Also sets sensible default apps and puts Flameshot on the PrintScreen key.
#
# Needs RPM Fusion + Flathub — run ./00-base.sh first.
#
#   ./01-everyday.sh

set -euo pipefail
sudo -v

# --- Apps from the Fedora / RPM Fusion repos ---
sudo dnf install -y \
  vlc audacious \
  gthumb gimp xournalpp \
  keepassxc filezilla transmission \
  flameshot

# --- Apps from Flathub (per-user, no password prompts) ---
flatpak install -y --user flathub \
  com.google.Chrome \
  org.telegram.desktop \
  com.github.IsmaelMartinez.teams_for_linux \
  org.gnome.gitlab.somas.Apostrophe

# --- Default applications (browser + media players) ---
xdg-settings set default-web-browser com.google.Chrome.desktop 2>/dev/null || true
xdg-mime default com.google.Chrome.desktop x-scheme-handler/http x-scheme-handler/https 2>/dev/null || true
xdg-mime default vlc.desktop \
  video/mp4 video/x-matroska video/webm video/quicktime \
  video/x-msvideo video/mpeg video/x-flv video/3gpp video/x-ms-wmv 2>/dev/null || true
xdg-mime default audacious.desktop \
  audio/mpeg audio/flac audio/x-flac audio/x-wav audio/wav \
  audio/ogg audio/x-vorbis+ogg audio/mp4 audio/aac audio/x-aac audio/opus 2>/dev/null || true

# --- Put Flameshot on the PrintScreen key ---
# First free the key from GNOME's built-in screenshot tool (it otherwise wins).
gsettings set org.gnome.shell.keybindings show-screenshot-ui "[]"          2>/dev/null || true
gsettings set org.gnome.shell.keybindings screenshot "[]"                   2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot "[]"  2>/dev/null || true

# Then add a custom shortcut Print -> `flameshot gui`, appending to the list of
# custom shortcuts without deleting any you already have.
MEDIA=org.gnome.settings-daemon.plugins.media-keys
KEY=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/
existing=$(gsettings get $MEDIA custom-keybindings)
case "$existing" in
  *"$KEY"*)        : ;;                                                  # already registered
  "@as []"|"[]")   gsettings set $MEDIA custom-keybindings "['$KEY']" ;; # list was empty
  *)               gsettings set $MEDIA custom-keybindings "${existing%]}, '$KEY']" ;;
esac
gsettings set "$MEDIA.custom-keybinding:$KEY" name    'Flameshot'
gsettings set "$MEDIA.custom-keybinding:$KEY" command 'flameshot gui'
gsettings set "$MEDIA.custom-keybinding:$KEY" binding 'Print'

echo "Everyday apps installed. Press PrintScreen to test Flameshot."
