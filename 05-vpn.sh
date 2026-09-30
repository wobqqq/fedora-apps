#!/usr/bin/env bash
#
# 05-vpn.sh — VPN clients: Windscribe + Cloudflare WARP.
#
# Two tools for two jobs:
#   • Windscribe — pick an exit country (geo), GUI + `windscribe-cli`
#   • Cloudflare WARP — encrypt traffic/DNS via the nearest Cloudflare edge,
#     CLI only, no location choice
#
# They can't run at the same time — both claim the default route.
#
# Needs no other script; only curl (installed by ./00-base.sh).
#
#   ./05-vpn.sh

set -euo pipefail
sudo -v

# =============================================================================
# Windscribe (official RPM, no dnf repo)
# =============================================================================

# --- Signing key (without it dnf warns the package signature is unknown) ---
sudo rpm --import https://windscribe.com/windscribe_linux_signing_key.pub

# --- Download the current release ---
# This URL always redirects to the latest build. The redirect target is a plain
# file URL that dnf5 refuses to install from, hence curl first, dnf second.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fL --progress-bar -o "$tmp/windscribe.rpm" \
  https://windscribe.com/install/desktop/linux_rpm_x64

# --- Check the package signature against the key imported above ---
# dnf does not check the signature of a local file by default.
if ! rpm --checksig "$tmp/windscribe.rpm" | grep 'signatures OK' >/dev/null; then
  echo "The Windscribe package is not signed by the key imported above — refusing to install it." >&2
  exit 1
fi

# --- Install (dnf pulls in the Qt / network dependencies) ---
# Safe to re-run: if the same version is already installed dnf just says so.
sudo dnf install -y "$tmp/windscribe.rpm"

# =============================================================================
# Cloudflare WARP (real dnf repo — updates come with `dnf upgrade`)
# =============================================================================

# The .repo file Cloudflare ships uses baseurl=.../rpm/$releasever, i.e. the
# Fedora release number. If a Fedora upgrade lands before Cloudflare publishes
# packages for it, this repo 404s — replace $releasever in the file below with
# the last working number (or 9 / 10 for the RHEL builds).
curl -fsSL https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo \
  | sudo tee /etc/yum.repos.d/cloudflare-warp.repo >/dev/null

sudo dnf install -y cloudflare-warp

echo
echo "Installed:"
echo "  Windscribe $(rpm -q --qf '%{VERSION}' windscribe 2>/dev/null || echo '?')"
echo "  Cloudflare WARP $(rpm -q --qf '%{VERSION}' cloudflare-warp 2>/dev/null || echo '?')"
echo
echo "Windscribe — log in once (GUI: Applications > Windscribe, or terminal):"
echo "  windscribe-cli login"
echo "  windscribe-cli locations          # every location: city / ISO code / nickname"
echo "  windscribe-cli connect de         # by country, city, region or nickname"
echo "  windscribe-cli connect best       # fastest one"
echo "  windscribe-cli status"
echo "  windscribe-cli disconnect"
echo
echo "Cloudflare WARP — register once, then connect:"
echo "  warp-cli registration new"
echo "  warp-cli connect                  # no country choice: nearest Cloudflare edge"
echo "  warp-cli mode doh                 # or: encrypt DNS only, traffic stays direct"
echo "  warp-cli status"
echo "  warp-cli disconnect"
echo
echo "Only one of them at a time. Check where you are coming out:"
echo "  curl -s https://ipinfo.io/json | jq '.ip, .country, .city'"
echo "  curl -s https://www.cloudflare.com/cdn-cgi/trace | grep -E '^(colo|loc|warp)='"
echo
echo "The clients manage their own firewall rules — leave ufw as 00-base.sh set it up."
