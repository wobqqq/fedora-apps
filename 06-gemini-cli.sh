#!/usr/bin/env bash
#
# 06-gemini-cli.sh — Gemini CLI: an AI coding agent that lives in the terminal.
#
# Installs Node.js (the CLI needs 20+) and the CLI itself from npm, with the npm
# global prefix pointed at ~/.local so `npm i -g` never needs sudo.
#
# Authentication is deliberately NOT scripted — you paste an API key on first
# run. Where to get one and how to drive the CLI: see the README.
#
# Needs no other script; only dnf and a PATH that includes ~/.local/bin.
#
#   ./06-gemini-cli.sh

set -euo pipefail
sudo -v

# --- Node.js + npm from the Fedora repos ---
# Fedora ships Node 22, comfortably above the 20 minimum. npm installs on Node
# 18 too, but the resulting binary crashes on first launch.
sudo dnf install -y nodejs npm

node_major=$(node -p 'process.versions.node.split(".")[0]')
if (( node_major < 20 )); then
  echo "Node $node_major is too old — Gemini CLI needs 20+." >&2
  exit 1
fi

# --- Global npm packages go to ~/.local, not /usr/lib ---
# Without this, `npm i -g` writes system-wide and wants sudo, which then leaves
# root-owned files in ~/.npm and breaks later user installs.
npm config set prefix "$HOME/.local"

# --- Gemini CLI ---
# Re-running this script upgrades it in place — that's also how you update.
npm install -g @google/gemini-cli

# --- Qwen Code (optional — uncomment if you have a paid key) ---
# Fork of Gemini CLI with prompts tuned for Qwen3-Coder. Its free OAuth tier was
# shut down on 2026-04-15, so it now needs an Alibaba Coding Plan or a
# third-party provider key (OpenRouter, DeepSeek, …). Useless without one.
# npm install -g @qwen-code/qwen-code

# --- fish: make sure ~/.local/bin is on the PATH ---
# Idempotent — fish_add_path skips a path that's already there.
if command -v fish >/dev/null 2>&1; then
  fish -c 'contains "$HOME/.local/bin" $PATH; or fish_add_path "$HOME/.local/bin"' || true
fi

echo
echo "Installed: Gemini CLI $("$HOME/.local/bin/gemini" --version 2>/dev/null || echo '?')"
echo
echo "Get a free API key — email login, no card:"
echo "  https://aistudio.google.com/apikey"
echo "Do NOT enable billing on that Google Cloud project: it deletes the free tier."
echo
echo "Then, from inside a project directory:"
echo "  gemini"
echo "  /auth              # choose 'Use Gemini API Key', paste the key"
echo "  /model             # switch to a Flash model (~1500 req/day free)"
echo
echo "'Sign in with Google' no longer works — the free Gemini Code Assist tier"
echo "for individuals was shut down on 2026-06-18. Only the API key path is free."
