#!/usr/bin/env bash
#
# install-nvidia.sh — install the proprietary NVIDIA driver on Fedora
# For an Acer Predator Triton 300 SE (PT316-51s): Intel Iris Xe + discrete NVIDIA
# GPU (hybrid / Optimus).
#
# What it does:
#   1. Enables the RPM Fusion repositories (free + nonfree)
#   2. Installs the NVIDIA driver (akmod) + CUDA support
#   3. Waits for the kernel module to build
#   4. Blacklists the open-source nouveau driver
#   5. Rebuilds the initramfs
#   6. Offers to reboot
#
# Usage:   sudo ./install-nvidia.sh
# Safe to re-run (it checks what has already been done).

set -euo pipefail

# ---- output colors ----
RED=$'\e[31m'; GRN=$'\e[32m'; YLW=$'\e[33m'; BLU=$'\e[34m'; RST=$'\e[0m'
info()  { echo "${BLU}==>${RST} $*"; }
ok()    { echo "${GRN}  ✓${RST} $*"; }
warn()  { echo "${YLW}  !${RST} $*"; }
err()   { echo "${RED}  ✗${RST} $*" >&2; }

# ---- require root ----
if [[ $EUID -ne 0 ]]; then
    err "Run with sudo:  sudo $0"
    exit 1
fi

# ---- make sure this is Fedora ----
if ! grep -qi fedora /etc/os-release; then
    err "This script targets Fedora. Aborting."
    exit 1
fi
FEDORA_VER=$(rpm -E %fedora)
info "Detected Fedora $FEDORA_VER"

# ---- make sure an NVIDIA card is present ----
if ! lspci | grep -i nvidia >/dev/null; then
    err "No NVIDIA GPU found (lspci). Aborting."
    exit 1
fi
ok "NVIDIA GPU found: $(lspci | grep -iE 'nvidia' | grep -iE 'vga|3d' | sed 's/.*: //' | head -1)"

# ---- check Secure Boot ----
if command -v mokutil &>/dev/null; then
    SB=$(mokutil --sb-state 2>/dev/null || true)
    if echo "$SB" | grep -qi "enabled"; then
        warn "Secure Boot is ENABLED — an unsigned NVIDIA module will NOT load!"
        warn "Either disable Secure Boot in the BIOS, or sign the module."
        read -rp "  Continue anyway? [y/N] " a
        [[ ${a,,} == y ]] || { err "Cancelled by user."; exit 1; }
    else
        ok "Secure Boot disabled — no module signing required"
    fi
fi

# ---- 1. RPM Fusion ----
info "Step 1/5: RPM Fusion repositories"
if rpm -q rpmfusion-free-release &>/dev/null && rpm -q rpmfusion-nonfree-release &>/dev/null; then
    ok "RPM Fusion already enabled"
else
    dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"
    ok "RPM Fusion enabled"
fi

# ---- 2. install the driver ----
info "Step 2/5: install NVIDIA driver + CUDA"
if rpm -q akmod-nvidia &>/dev/null; then
    ok "akmod-nvidia already installed"
else
    dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
    ok "Driver installed"
fi

# ---- 3. wait for the module to build ----
info "Step 3/5: building the kernel module (may take up to 5 minutes)"
akmods --force >/dev/null 2>&1 || true
printf "  Waiting"
for i in $(seq 1 60); do
    if modinfo -F version nvidia &>/dev/null; then
        echo
        ok "Module built: version $(modinfo -F version nvidia)"
        break
    fi
    printf "."
    sleep 5
    if [[ $i -eq 60 ]]; then
        echo
        err "Module did not build within 5 minutes. Check the log:"
        err "  /var/cache/akmods/nvidia/*.log"
        exit 1
    fi
done

# ---- 4. blacklist nouveau ----
info "Step 4/5: disable the open-source nouveau driver"
BL=/etc/modprobe.d/blacklist-nouveau.conf
if [[ -f $BL ]]; then
    ok "nouveau blacklist already configured"
else
    printf "blacklist nouveau\noptions nouveau modeset=0\n" > "$BL"
    ok "Created $BL"
fi
# kernel parameter — safety net for early boot
if [[ $(grubby --info=DEFAULT) == *"modprobe.blacklist=nouveau"* ]]; then
    ok "Kernel parameter already set"
else
    grubby --update-kernel=ALL --args="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau"
    ok "Added kernel parameter blacklist=nouveau"
fi

# ---- 5. rebuild initramfs ----
info "Step 5/5: rebuild the initramfs"
dracut --force
ok "initramfs rebuilt"

# ---- done ----
echo
echo "${GRN}════════════════════════════════════════════════${RST}"
echo "${GRN} Installation complete. A reboot is required.${RST}"
echo "${GRN}════════════════════════════════════════════════${RST}"
echo
echo "After rebooting, verify with:"
echo "  ${BLU}nvidia-smi${RST}                    # driver should list the GPU"
echo "  ${BLU}lsmod | grep nouveau${RST}          # should be EMPTY"
echo
read -rp "Reboot now? [y/N] " a
if [[ ${a,,} == y ]]; then
    info "Rebooting..."
    reboot
else
    warn "Remember to reboot manually: sudo reboot"
fi
