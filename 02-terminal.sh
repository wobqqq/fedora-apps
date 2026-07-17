#!/usr/bin/env bash
#
# 02-terminal.sh — a nicer, more powerful terminal.
#
# Installs fish, the Ptyxis terminal, the Starship prompt, a set of modern CLI
# tools (ripgrep, fzf, bat, fd, eza, zoxide, direnv, btop, tmux, ...) and the yazi
# file manager. Wires everything into bash and fish so it works in every shell.
#
# Needs the Fedora repos — run ./00-base.sh first.
#
#   ./02-terminal.sh

set -euo pipefail
sudo -v

# --- Shell, terminal and modern CLI tools from the Fedora repos ---
sudo dnf install -y \
  fish ptyxis \
  btop tmux ncdu \
  ripgrep fzf bat fd-find glow \
  eza zoxide direnv \
  jq yq \
  poppler-utils ImageMagick 7zip chafa
# jq/yq + the poppler/ImageMagick/7zip/chafa group are also yazi's preview and
# extract dependencies (JSON/YAML, PDF, images, archives).

# --- Make fish your default login shell ---
FISH_BIN=$(command -v fish)
grep -qxF "$FISH_BIN" /etc/shells || echo "$FISH_BIN" | sudo tee -a /etc/shells >/dev/null
sudo chsh -s "$FISH_BIN" "$USER"

# --- Make Ptyxis the default terminal, bound to Ctrl+Alt+T ---
gsettings set org.gnome.desktop.default-applications.terminal exec 'ptyxis'  2>/dev/null || true
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-x'  2>/dev/null || true
sudo alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ptyxis 50 2>/dev/null || true
sudo alternatives --set x-terminal-emulator /usr/bin/ptyxis 2>/dev/null || true
# GNOME's built-in Ctrl+Alt+T is hard-wired to gnome-terminal, so add a custom
# shortcut (appending to the list without clobbering existing ones).
MEDIA=org.gnome.settings-daemon.plugins.media-keys
KEY=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ptyxis/
existing=$(gsettings get $MEDIA custom-keybindings)
case "$existing" in
  *"$KEY"*)        : ;;
  "@as []"|"[]")   gsettings set $MEDIA custom-keybindings "['$KEY']" ;;
  *)               gsettings set $MEDIA custom-keybindings "${existing%]}, '$KEY']" ;;
esac
gsettings set "$MEDIA.custom-keybinding:$KEY" name    'Ptyxis'
gsettings set "$MEDIA.custom-keybinding:$KEY" command 'ptyxis --new-window'
gsettings set "$MEDIA.custom-keybinding:$KEY" binding '<Control><Alt>t'

# --- Starship prompt (not in the Fedora repos: install the official binary) ---
if ! command -v starship >/dev/null 2>&1; then
  curl -fsSL https://starship.rs/install.sh | sudo sh -s -- --yes --bin-dir /usr/local/bin
fi

# --- yazi file manager (not in the Fedora repos: install the release binary) ---
if ! command -v yazi >/dev/null 2>&1; then
  YAZI_VER=$(curl -fsSL https://api.github.com/repos/sxyazi/yazi/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+')
  asset="yazi-x86_64-unknown-linux-gnu"
  tmp=$(mktemp -d)
  curl -fsSL "https://github.com/sxyazi/yazi/releases/download/${YAZI_VER}/${asset}.zip" -o "$tmp/yazi.zip"
  unzip -q "$tmp/yazi.zip" -d "$tmp"
  sudo install -m755 "$tmp/${asset}/yazi" "$tmp/${asset}/ya" /usr/local/bin/
  rm -rf "$tmp"
fi

# --- yazi rich text previews: Markdown -> glow, JSON -> jq, YAML -> yq ---
# (images and PDF pages already preview via chafa). Uses the `piper` plugin.
if command -v ya >/dev/null 2>&1; then
  ya pkg add yazi-rs/plugins:piper 2>/dev/null || true
  mkdir -p "$HOME/.config/yazi"
  [[ -f "$HOME/.config/yazi/yazi.toml" ]] && cp -f "$HOME/.config/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml.bak"
  cat > "$HOME/.config/yazi/yazi.toml" <<'EOF'
# Rich text previews. $w = pane width, $1 = the file being previewed.
[plugin]
prepend_previewers = [
  { url = "*.md",       run = 'piper -- CLICOLOR_FORCE=1 glow -w=$w -s dark "$1"' },
  { url = "*.markdown", run = 'piper -- CLICOLOR_FORCE=1 glow -w=$w -s dark "$1"' },
  { url = "*.json",     run = 'piper -- jq -C . "$1"' },
  { url = "*.yaml",     run = 'piper -- yq -C -P eval . "$1"' },
  { url = "*.yml",      run = 'piper -- yq -C -P eval . "$1"' },
]
EOF
fi

# --- Wire everything into bash and fish, system-wide ---
# bash reads /etc/profile.d/*.sh; fish auto-sources /etc/fish/conf.d/*.fish.
sudo mkdir -p /etc/fish/conf.d

# Starship prompt
sudo tee /etc/profile.d/starship-prompt.sh >/dev/null <<'EOF'
case $- in *i*) command -v starship >/dev/null 2>&1 && eval "$(starship init bash)" ;; esac
EOF
sudo tee /etc/fish/conf.d/starship.fish >/dev/null <<'EOF'
status is-interactive; and command -q starship; and starship init fish | source
EOF

# zoxide — a smarter `cd` (adds `z <dir>` and `zi`; plain cd still works)
sudo tee /etc/profile.d/zoxide.sh >/dev/null <<'EOF'
case $- in *i*) command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)" ;; esac
EOF
sudo tee /etc/fish/conf.d/zoxide.fish >/dev/null <<'EOF'
status is-interactive; and command -q zoxide; and zoxide init fish | source
EOF

# eza — a modern `ls` (aliased to ls/ll/la/lt)
sudo tee /etc/profile.d/eza-aliases.sh >/dev/null <<'EOF'
case $- in *i*)
  if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first'
    alias ll='eza -l  --group-directories-first --git'
    alias la='eza -la --group-directories-first --git'
    alias lt='eza --tree --level=2'
  fi ;;
esac
EOF
sudo tee /etc/fish/conf.d/eza-aliases.fish >/dev/null <<'EOF'
if status is-interactive; and command -q eza
    alias ls 'eza --group-directories-first'
    alias ll 'eza -l  --group-directories-first --git'
    alias la 'eza -la --group-directories-first --git'
    alias lt 'eza --tree --level=2'
end
EOF

# direnv — auto-loads a project's .envrc on cd in (run `direnv allow` once per project)
sudo tee /etc/profile.d/direnv.sh >/dev/null <<'EOF'
case $- in *i*) command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)" ;; esac
EOF
sudo tee /etc/fish/conf.d/direnv.fish >/dev/null <<'EOF'
status is-interactive; and command -q direnv; and direnv hook fish | source
EOF

# yazi `y` wrapper — cd into the last dir you browsed on exit (plain `yazi` still works)
sudo tee /etc/profile.d/yazi-wrapper.sh >/dev/null <<'EOF'
case $- in *i*)
  if command -v yazi >/dev/null 2>&1; then
    y() {
      local tmp cwd; tmp=$(mktemp -t "yazi-cwd.XXXXXX")
      yazi "$@" --cwd-file="$tmp"
      cwd=$(command cat -- "$tmp") && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
      rm -f -- "$tmp"
    }
  fi ;;
esac
EOF
sudo tee /etc/fish/conf.d/yazi-wrapper.fish >/dev/null <<'EOF'
if status is-interactive; and command -q yazi
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
EOF

echo "Terminal setup done. Open a new terminal (Ctrl+Alt+T) to see it. Default shell is now fish (next login)."
