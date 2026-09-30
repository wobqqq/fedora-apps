#!/usr/bin/env bash
#
# tools/check-packages.sh — fail when a dnf package the scripts install no longer exists.
# Runs in a fedora container (CI): enables RPM Fusion like 00-base.sh, then looks
# every package up. Packages from vendor repositories are skipped.
set -euo pipefail
cd "$(dirname "$0")/.."

SKIPPED=(cloudflare-warp)   # 05-vpn.sh adds Cloudflare's own repository first

ver=$(rpm -E %fedora)
dnf install -y -q \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${ver}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${ver}.noarch.rpm" >/dev/null

available=$(dnf repoquery -q --available --qf '%{name}\n' | sort -u)
missing=0
while read -r pkg; do
  [[ " ${SKIPPED[*]} " == *" $pkg "* ]] && { echo "skipped  $pkg (vendor repository)"; continue; }
  if grep -qxF "$pkg" <<<"$available"; then
    echo "ok       $pkg"
  elif provider=$(dnf repoquery -q --available --whatprovides "$pkg" --qf '%{name}\n' | head -1) && [[ -n "$provider" ]]; then
    echo "ok       $pkg (provided by $provider)"
  else
    echo "MISSING  $pkg"; missing=1
  fi
done < <(tools/packages.sh dnf)
exit "$missing"
