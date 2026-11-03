#!/usr/bin/env bash
#
# 07-fresh-editor.sh — Fresh: a modern terminal text editor.
#
# Installs Fresh from its GitHub release RPM, makes its integrated terminal run
# fish, and sets it as $EDITOR / $VISUAL in bash and fish.
#
# Needs no other script; only curl and jq (./00-base.sh, ./02-terminal.sh).
# fish is optional — without it the integrated terminal falls back to $SHELL.
#
#   ./07-fresh-editor.sh

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
sudo -v

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# --- Fresh from the GitHub release RPM (not in the Fedora repos) ---
# No dnf repo, so `dnf upgrade` never updates it — re-running this script does.
# The RPM is downloaded only when GitHub has a version newer than the installed one.
tag=$(github_latest_tag sinelaw/fresh)
if [[ "$(rpm -q --qf '%{VERSION}' fresh-editor 2>/dev/null || true)" != "${tag#v}" ]]; then
  rpm="fresh-editor-${tag#v}-1.x86_64.rpm"
  url="https://github.com/sinelaw/fresh/releases/download/${tag}/${rpm}"
  download_verified "$url" "$work/$rpm" "$(curl -fsSL "$url.sha256" | checksum_for "$rpm")"
  sudo dnf install -y "$work/$rpm"
fi

# --- Integrated terminal runs fish ---
# Fresh launches $SHELL, which is whatever the parent process had: still bash
# when Fresh starts from a bash session or an IDE. Pin fish instead; `-i` makes
# it load /etc/fish/conf.d (prompt, zoxide, aliases). Merged with jq so the
# user's other settings survive.
if command -v fish >/dev/null 2>&1; then
  cfg="$HOME/.config/fresh/config.json"
  mkdir -p "$(dirname "$cfg")"
  [[ -s "$cfg" ]] || echo '{}' >"$cfg"
  if merged=$(jq --arg fish "$(command -v fish)" '.terminal.shell = {command: $fish, args: ["-i"]}' "$cfg"); then
    printf '%s\n' "$merged" >"$cfg"
  else
    echo "WARNING: $cfg is not plain JSON — set terminal.shell to fish by hand." >&2
  fi
fi

# --- Fresh as the default editor, in bash and fish ---
# Not guarded by "interactive" like the other shell integrations: git, sudoedit
# and crontab read $EDITOR from non-interactive shells too. Fedora's
# nano-default-editor files only fill in an empty EDITOR, so these win.
sudo mkdir -p /etc/fish/conf.d
sudo tee /etc/profile.d/fresh-editor.sh >/dev/null <<'EOF'
if command -v fresh >/dev/null 2>&1; then
  export EDITOR=fresh VISUAL=fresh
fi
EOF
sudo tee /etc/fish/conf.d/fresh-editor.fish >/dev/null <<'EOF'
if command -q fresh
    set -gx EDITOR fresh
    set -gx VISUAL fresh
end
EOF

echo
echo "Installed: Fresh $(rpm -q --qf '%{VERSION}' fresh-editor 2>/dev/null || echo '?')"
echo
echo "  fresh file.txt       # open a file"
echo "  fresh .              # open a directory (file explorer on the left)"
echo "  Ctrl+P               # command palette — everything is in there"
echo "  Alt+\`                # terminal in the bottom dock (runs fish)"
echo
echo "EDITOR=fresh applies to new terminals; log out and back in for GUI apps."
