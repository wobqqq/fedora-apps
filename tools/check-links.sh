#!/usr/bin/env bash
#
# tools/check-links.sh — fail when a download the scripts rely on has moved.
# Resolves "latest" the way the scripts do, then checks every URL answers and every
# release still publishes the checksum the scripts verify against.
set -euo pipefail
cd "$(dirname "$0")/.."
source lib/common.sh

failed=0
check() {  # label, url
  local code
  code=$(curl -sSIL -o /dev/null -w '%{http_code}' --retry 2 "$2" || true)
  if [[ "$code" == 200 ]]; then echo "ok    $1"; else echo "FAIL  $1 ($code) $2"; failed=1; fi
}
need() {  # label, value
  if [[ -n "$2" ]]; then echo "ok    $1"; else echo "FAIL  $1"; failed=1; fi
}

fedora=$(curl -fsSL https://fedoraproject.org/releases.json \
  | jq -r '[.[] | select(.variant == "Workstation" and (.version | test("^[0-9]+$"))) | .version | tonumber] | max')
check "RPM Fusion free (Fedora $fedora)" "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora}.noarch.rpm"
check "RPM Fusion nonfree (Fedora $fedora)" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora}.noarch.rpm"
check "Flathub remote" https://flathub.org/repo/flathub.flatpakrepo
while read -r app; do
  check "Flathub $app" "https://flathub.org/api/v2/appstream/$app"
done < <(tools/packages.sh flatpak)

for id in $(sed -n '/^GNOME_EXTENSIONS=(/,/^)/p' 00-base.sh | grep -oE '^\s+[0-9]+' | tr -d ' '); do
  check "GNOME extension $id" "https://extensions.gnome.org/extension-info/?pk=$id"
done

base=https://github.com/starship/starship/releases/latest/download
check "starship" "$base/starship-x86_64-unknown-linux-musl.tar.gz"
check "starship checksum" "$base/starship-x86_64-unknown-linux-musl.tar.gz.sha256"

tag=$(github_latest_tag sxyazi/yazi || true)
need "yazi latest release" "$tag"
check "yazi $tag" "https://github.com/sxyazi/yazi/releases/download/$tag/yazi-x86_64-unknown-linux-gnu.zip"
need "yazi $tag checksum" "$(github_asset_sha256 sxyazi/yazi "$tag" yazi-x86_64-unknown-linux-gnu.zip || true)"

for spec in 'jesseduffield/lazygit lazygit_{version}_linux_x86_64.tar.gz' 'jesseduffield/lazydocker lazydocker_{version}_Linux_x86_64.tar.gz'; do
  read -r repo pattern <<<"$spec"
  tag=$(github_latest_tag "$repo" || true)
  need "$repo latest release" "$tag"
  asset=${pattern//\{version\}/${tag#v}}
  check "$asset" "https://github.com/$repo/releases/download/$tag/$asset"
  need "$asset checksum" "$(curl -fsSL "https://github.com/$repo/releases/download/$tag/checksums.txt" | checksum_for "$asset" || true)"
done

release=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=PS&latest=true&type=release")
check "PhpStorm" "$(jq -r '.PS[0].downloads.linux.link' <<<"$release")"
check "PhpStorm checksum" "$(jq -r '.PS[0].downloads.linux.checksumLink' <<<"$release")"

check "Windscribe signing key" https://windscribe.com/windscribe_linux_signing_key.pub
check "Windscribe RPM" https://windscribe.com/install/desktop/linux_rpm_x64
check "Cloudflare WARP repository" https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo

exit "$failed"
