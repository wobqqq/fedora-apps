#!/usr/bin/env bash
#
# tools/packages.sh — list what the scripts install, for the CI checks.
#
#   tools/packages.sh dnf        dnf package names
#   tools/packages.sh flatpak    Flathub application IDs
#
# Reads the `dnf install` / `flatpak install` commands of the scripts, line
# continuations included. Options, URLs, local files and variables are left out.
set -euo pipefail
cd "$(dirname "$0")/.."

commands() {  # print each install command of the scripts on one line
  local kind=$1
  cat ./*.sh predator-pt316-51s/*.sh \
    | sed -e ':a' -e '/\\$/N; s/\\\n//; ta' \
    | grep -E "^\s*(sudo )?${kind} install " || true
}

words() {  # keep the package-looking words of the install commands of kind $1
  tr -s ' \t' '\n' | grep -vE "^(sudo|$1|install|flathub|-.*|.*[/\$\"].*|.*\.rpm)\$" | grep -E '^[A-Za-z0-9]' || true
}

case "${1:-}" in
  dnf)     commands dnf | sed 's/||.*//' | words dnf | sort -u ;;
  flatpak) commands flatpak | words flatpak | sort -u ;;
  *)       echo "usage: $0 dnf|flatpak" >&2; exit 1 ;;
esac
