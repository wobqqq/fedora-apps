# Fedora Apps Post-Install Setup Instructions

> The canonical guide for AI agents is [AGENTS.md](AGENTS.md) (conventions, checks, supply-chain and Git rules); this file summarises it for Gemini CLI.

Welcome to the `fedora-apps` repository context. This file provides instructional guidelines, architectural understanding, and run instructions for the post-installation setup scripts designed for Fedora Workstation (GNOME), optimized for backend development on hybrid-GPU laptops (specifically the Acer Predator Triton 300 SE PT316-51s).

---

## 📂 Directory Overview

This is a **Script-Based Automation & System Configuration Project**. Rather than using a single monolithic install script, it is split into specialized, modular shell scripts. This design allows users to run or copy-paste specific components safely and iteratively.

### Core Philosophy:
1. **Idempotency**: Every script is designed to be safe to run multiple times.
2. **Normal User Execution**: Scripts should be executed as a normal user; they will prompt for `sudo` internally as required.
3. **Fail-Fast**: Scripts utilize `set -euo pipefail` to ensure any error stops execution immediately, avoiding broken half-states.

---

## 🛠️ Key Files & Architecture

The repository contains modular setup scripts and hardware-specific configurations:

| Script / Directory | Group | Description |
|---|---|---|
| [`00-base.sh`](00-base.sh) | **Base** | Enablers (RPM Fusion, Flathub), system upgrade, removes preinstalled bloat (`chromium`, `thunderbird`), full ffmpeg codec swap, ufw firewall setup, SSH key creation, HiDPI desktop tweaks, and core GNOME Shell extensions. |
| [`01-everyday.sh`](01-everyday.sh) | **Everyday** | Installs standard GUI apps (VLC, Chrome, Telegram, KeePassXC, GIMP, Xournal++, etc.), configures default MIME types, and binds **Flameshot** to the PrintScreen key. |
| [`02-terminal.sh`](02-terminal.sh) | **Terminal** | Customizes terminal with **fish** as default, **Ptyxis** terminal (Ctrl+Alt+T), **Starship** prompt, modern CLI utilities (`ripgrep`, `fd`, `bat`, `eza`, `zoxide`, `direnv`, `btop`, `ncdu`, `tmux`, `jq`, `yq`), and **yazi** file manager (with rich media and file previews). |
| [`03-development.sh`](03-development.sh) | **Development** | Installs backend dev tools: `httpie`, `mycli`, `pgcli`, `wireshark` (runs without root), `lazygit`, `lazydocker`, VS Code (Flatpak), DBeaver (Flatpak), Bruno (Flatpak), PhpStorm (installed to `/opt`), and opens firewall port `9003` for Docker-to-host Xdebug connection. |
| [`04-games.sh`](04-games.sh) | **Games** | Installs Steam and GameMode. Provides hybrid-GPU launch configurations. |
| [`05-vpn.sh`](05-vpn.sh) | **VPN** | Installs Windscribe (GUI + CLI) and Cloudflare WARP (CLI). They manage their own firewall rules and cannot be run concurrently. |
| [`06-gemini-cli.sh`](06-gemini-cli.sh) | **AI CLI** | Node.js + Gemini CLI, with npm's global prefix in `~/.local`. |
| [`predator-pt316-51s/`](predator-pt316-51s/) | **Hardware** | Custom configuration for the Acer Predator Triton 300 SE laptop, including `install-nvidia.sh` (proprietary driver + CUDA) and `nvidia-cheatsheet.md` for GPU monitoring and troubleshooting. |

---

## 🚀 Usage & Workflows

### Execution Order:
To set up a fresh system, clone this repository and run scripts sequentially:

```bash
chmod +x *.sh

./00-base.sh          # Always run first (RPM Fusion / Flathub prerequisite)
./01-everyday.sh      # Everyday desktop apps
./02-terminal.sh      # Shell, Ptyxis, custom prompt, and CLI tools
./03-development.sh   # Developer utilities
./04-games.sh         # Steam & GameMode
./05-vpn.sh           # Windscribe & Cloudflare WARP setup
./06-gemini-cli.sh    # Node.js + Gemini CLI
```

*Note: Log out and back in after running `00-base.sh` and `02-terminal.sh` for shells, default terminals, GNOME extensions, and Flatpak icons to load properly.*

### Hardware Setup (NVIDIA / Acer Predator):
To configure the dual-GPU hybrid architecture (Intel Iris Xe + discrete NVIDIA GPU):

```bash
cd predator-pt316-51s
sudo ./install-nvidia.sh
```
*Note: Secure Boot must be disabled or modules signed with `mokutil`.*

---

## 📝 Coding Standards & Guidelines for AI Assistants

When assisting in maintaining or updating this project, adhere strictly to these principles:

1. **Keep Scripts Idempotent**: Always check if a library, application, or repo is already present before installing or editing files.
2. **Error Handling**: Use `set -euo pipefail` on all new or updated shell scripts.
3. **No Redundant Prompts**: Avoid prompting the user inside scripts where possible. Use logical defaults or non-interactive flags (e.g., `dnf install -y`, `flatpak install -y`).
4. **Environment Integrity**: Maintain system configuration files cleanly. When adding configurations to shells, write to modular locations (e.g., `/etc/profile.d/` for bash, `/etc/fish/conf.d/` for fish) rather than appending to user-specific `.bashrc` or `config.fish` files unless absolutely necessary.
5. **No System Overreach**: Respect existing system services. Do not disable preinstalled firewall rules or systemd units without explicit logging or comments (e.g., disabling `firewalld` to favor `ufw`).
6. **Verified Downloads**: A release binary is installed only after its SHA-256 matches the checksum its release publishes (`lib/common.sh`: `download_verified`). Never pipe a download into a shell.
7. **Checks, Not Runs**: Never run the scripts to verify an edit; run `make ready` (ShellCheck, `bash -n`, Bats).
8. **Git**: Never push to `main`; open a pull request from a branch. Everything in English.
