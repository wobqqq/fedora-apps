# NVIDIA / GPU — cheatsheet (Fedora, Acer Predator Triton 300 SE PT316-51s, Intel + NVIDIA hybrid)

## 📊 Monitoring

| Command | What it does |
|---------|-----------|
| `nvidia-smi` | Snapshot of NVIDIA state: temperature, memory, load, processes |
| `watch -n1 nvidia-smi` | Same, but refreshed once a second (live monitoring) |
| `nvidia-smi -l 1` | Live streaming output (alternative to watch) |
| `nvtop` | htop for the GPU — Intel and NVIDIA at once, load graphs *(dnf install nvtop)* |
| `nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,memory.used --format=csv -l 1` | Only temperature/load/memory, streamed |
| `nvidia-smi dmon` | Metrics streamed as a single line (load, memory, power, temperature) |
| `nvidia-smi pmon` | Per-process monitoring |

## 🔍 Checking which GPU is active

| Command | What it does |
|---------|-----------|
| `glxinfo \| grep "OpenGL renderer"` | Which card renders by default (usually Intel) |
| `__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia glxinfo \| grep renderer` | Verify that offload to NVIDIA works |
| `pid=$(pgrep -n NAME); cat /proc/$pid/environ \| tr '\0' '\n' \| grep NV_PRIME` | 100% check: is the app running on NVIDIA |
| `lspci -nnk \| grep -iA3 vga` | Which cards exist and which driver is bound to them |
| `nvidia-smi` (Processes table) | List of processes actually loading the NVIDIA GPU |

## 🚀 Running an app on NVIDIA (PRIME offload)

```bash
# Any program on the discrete GPU:
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <command>

# In GNOME: right-click the icon → "Launch using Discrete Graphics Card"

# For a Steam game (in the launch options):
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia %command%
```

## ⚙️ Driver and modules

| Command | What it does |
|---------|-----------|
| `modinfo -F version nvidia` | Version of the installed NVIDIA module |
| `lsmod \| grep nvidia` | Loaded nvidia modules |
| `lsmod \| grep nouveau` | Check the open driver isn't loading (should be empty) |
| `rpm -qa \| grep -i nvidia` | List of installed NVIDIA packages |
| `cat /proc/driver/nvidia/version` | Driver and kernel version |
| `sudo akmods --force` | Force-rebuild the kernel module |

## 🔄 Maintenance / after a kernel update

| Command | What it does |
|---------|-----------|
| `sudo dnf upgrade` | Update the system (akmod rebuilds the module automatically) |
| `sudo akmods --force && sudo dracut --force` | Manually rebuild the module + initramfs if nvidia won't load after a kernel update |
| `sudo dnf remove '*nvidia*'` | Fully remove the driver (fall back to nouveau) |
| `uname -r` | Current kernel version (for diagnosing the module build) |

## 🩺 Troubleshooting

| Command | What it does |
|---------|-----------|
| `journalctl -b -g nvidia` | nvidia messages from the current boot's journal |
| `dmesg \| grep -i nvidia` | Kernel messages about nvidia |
| `cat /var/cache/akmods/nvidia/*.log` | Module build log (if the build failed) |
| `mokutil --sb-state` | Secure Boot status (affects whether the module loads) |
| `echo $XDG_SESSION_TYPE` | Session type: wayland or x11 |

## 🔋 Power (energy saving)

| Command | What it does |
|---------|-----------|
| `systemctl status nvidia-powerd` | Dynamic GPU power management service |
| `nvidia-smi -q -d POWER` | Detailed power consumption |
| `cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status` | `suspended` = card is asleep (saving battery), `active` = running |

---

### Quick "NVIDIA is definitely working" test
```bash
# in one terminal:
watch -n1 nvidia-smi
# in another — run glxgears on the discrete GPU, it shows up in the Processes list:
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia glxgears
```
