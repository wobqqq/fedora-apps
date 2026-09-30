# shellcheck shell=bash
#
# lib/common.sh — helpers shared by the NN-*.sh scripts. Source it, don't run it:
#
#   source "$(dirname "$0")/lib/common.sh"

# Print a GVariant string list with ITEM appended, unless it is already there.
# Handles the empty forms GNOME uses ("@as []" and "[]").
#   gvariant_list_append "['a', 'b']" "c"   ->  ['a', 'b', 'c']
gvariant_list_append() {
  local list=$1 item=$2
  case "$list" in
    *"'$item'"*)      printf '%s\n' "$list" ;;
    "@as []" | "[]" | "") printf "['%s']\n" "$item" ;;
    *)                printf "%s, '%s']\n" "${list%]}" "$item" ;;
  esac
}

# Register a GNOME custom keyboard shortcut without clobbering the existing ones.
#   add_custom_keybinding flameshot 'Flameshot' 'flameshot gui' 'Print'
add_custom_keybinding() {
  local id=$1 name=$2 command=$3 binding=$4
  local media=org.gnome.settings-daemon.plugins.media-keys
  local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${id}/"
  local current
  current=$(gsettings get "$media" custom-keybindings)
  gsettings set "$media" custom-keybindings "$(gvariant_list_append "$current" "$path")"
  gsettings set "$media.custom-keybinding:$path" name "$name"
  gsettings set "$media.custom-keybinding:$path" command "$command"
  gsettings set "$media.custom-keybinding:$path" binding "$binding"
}

# GitHub's API allows 60 anonymous requests an hour; a GITHUB_TOKEN in the environment lifts that.
github_api() {
  local auth=()
  [[ -n "${GITHUB_TOKEN:-}" ]] && auth=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
  curl -fsSL "${auth[@]}" "https://api.github.com/$1"
}

# Print the tag of a GitHub repository's latest release.
#   github_latest_tag jesseduffield/lazygit   ->  v0.65.1
github_latest_tag() {
  github_api "repos/$1/releases/latest" | jq -er '.tag_name'
}

# Print the SHA-256 GitHub recorded for a release asset (from its "digest" field).
#   github_asset_sha256 sxyazi/yazi v26.9.1 yazi-x86_64-unknown-linux-gnu.zip
github_asset_sha256() {
  github_api "repos/$1/releases/tags/$2" \
    | jq -er --arg name "$3" '.assets[] | select(.name == $name) | .digest | select(startswith("sha256:")) | ltrimstr("sha256:")'
}

# Print the checksum a "checksums.txt"-style list (HASH  NAME, or HASH *NAME) gives NAME.
#   checksum_for lazygit_0.65.1_linux_x86_64.tar.gz < checksums.txt
checksum_for() {
  awk -v name="$1" '{ file = $2; sub(/^\*/, "", file) } file == name { print $1; found = 1; exit } END { exit !found }'
}

# Fail unless FILE's SHA-256 is EXPECTED. Never install what does not match.
#   verify_sha256 /tmp/lazygit.tar.gz 02beac…
verify_sha256() {
  local file=$1 expected=$2 actual
  if [[ ! "$expected" =~ ^[0-9a-f]{64}$ ]]; then
    echo "No valid SHA-256 published for $(basename "$file") — refusing to install it." >&2
    return 1
  fi
  actual=$(sha256sum "$file" | cut -d' ' -f1)
  if [[ "$actual" != "$expected" ]]; then
    echo "Checksum mismatch for $(basename "$file"): expected $expected, got $actual — refusing to install it." >&2
    return 1
  fi
}

# Download URL to FILE and check it against EXPECTED (see verify_sha256).
#   download_verified URL FILE EXPECTED
download_verified() {
  curl -fsSL "$1" -o "$2"
  verify_sha256 "$2" "$3"
}
