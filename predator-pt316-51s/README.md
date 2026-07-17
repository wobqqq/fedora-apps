# Drivers

Hardware drivers for the **Acer Predator Triton 300 SE (PT316-51s)** — a laptop
with **hybrid Intel + NVIDIA graphics** — plus the Acer Predator vendor control
features (fans, thermal profiles, RGB keyboard).

| File | Purpose |
|---|---|
| [`install-nvidia.sh`](install-nvidia.sh) | Installs the proprietary NVIDIA driver + CUDA (akmod) |
| [`nvidia-cheatsheet.md`](nvidia-cheatsheet.md) | Monitoring, PRIME offload and troubleshooting commands |

## 1. NVIDIA driver

Installs the proprietary driver from RPM Fusion, blacklists the open-source
`nouveau` driver, and rebuilds the initramfs. Run with **sudo**; safe to re-run:

```bash
sudo ./install-nvidia.sh
```

A **reboot is required** afterwards. Then verify:

```bash
nvidia-smi              # should list the GPU
lsmod | grep nouveau    # should be empty
```

On a hybrid laptop the Intel GPU drives the display and the NVIDIA GPU stays
asleep until you ask for it (PRIME offload):

```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <command>
```

See [`nvidia-cheatsheet.md`](nvidia-cheatsheet.md) for the full set of monitoring
and diagnostic commands.

> **Secure Boot:** an unsigned NVIDIA module won't load. Either disable Secure
> Boot in the BIOS, or sign the module (`mokutil`). The install script warns you
> if Secure Boot is enabled.

## 2. Acer Predator control suite (optional)

For the Acer Predator Triton 300 SE (PT316-51s), [**predator-sense**](https://github.com/wobqqq/predator-sense)
adds a PredatorSense-style control stack for Linux: thermal profiles, a real
Turbo-button toggle, fan control, RGB keyboard, and battery/temperature
monitoring — all as simple console commands.

```bash
git clone https://github.com/wobqqq/predator-sense.git
cd predator-sense
sudo ./install.sh
```

Requires a systemd-based distro, kernel headers + gcc/make, and Secure Boot
disabled. See the [predator-sense README](https://github.com/wobqqq/predator-sense)
for full details.
