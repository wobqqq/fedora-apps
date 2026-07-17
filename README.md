# fedora-apps

Post-install app setup for a fresh **Fedora Workstation (GNOME)**, tuned for a
backend developer's machine.

Instead of one giant script, the setup is split into small, **readable scripts you
can run — or just copy-paste from — one group at a time**:

| Script | Group | What it installs |
|---|---|---|
| [`00-base.sh`](00-base.sh) | **Base** (run first) | RPM Fusion, Flathub, system upgrade, core utils, firewall, SSH key, desktop tweaks |
| [`01-everyday.sh`](01-everyday.sh) | **Everyday** | Browser, chat, media players, image tools, files, password manager, screenshots |
| [`02-terminal.sh`](02-terminal.sh) | **Terminal** | fish, Ptyxis, Starship, modern CLI tools, yazi file manager |
| [`03-development.sh`](03-development.sh) | **Development** | HTTP/DB clients, lazygit/lazydocker, VS Code, DBeaver, Bruno, PhpStorm |
| [`04-games.sh`](04-games.sh) | **Games** | Steam + GameMode |

## Quick start

Clone the repo on a fresh system and run the groups you want. **Run `00-base.sh`
first** — the rest assume RPM Fusion and Flathub are enabled.

```bash
chmod +x *.sh

./00-base.sh          # always first
./01-everyday.sh      # desktop apps
./02-terminal.sh      # terminal power-up
./03-development.sh   # dev tools
./04-games.sh         # Steam
```

Run them as your **normal user** (not with sudo) — each script calls `sudo`
itself when it needs to. Every script is independent and safe to re-run.

> **Note:** `02-terminal.sh` makes **fish** your default login shell and sets
> **Ptyxis** as the default terminal (Ctrl+Alt+T). Log out and back in for those
> — and for Flatpak apps to appear in the menu — to take effect.

---

## Base (`00-base.sh`)

Foundation for everything else. Not apps, but the setup they depend on:

- **RPM Fusion** (free + nonfree) — needed for VLC, Steam, unrar, full ffmpeg
- **Full system upgrade** and removal of preinstalled bloat (`chromium`, `thunderbird`)
- **Full ffmpeg** — swaps Fedora's stripped `ffmpeg-free` for full codecs
- **Core utilities** — `wget curl git make`, `zip unzip unrar`, `openssh-clients`
- **Flathub** remote for Flatpak apps
- **Firewall** — switches from `firewalld` to the simpler **ufw** and enables it
- **SSH key** — generates an ed25519 key (never overwrites an existing one)
- **HiDPI scaling** — fractional scaling + 1.2 font scaling for the laptop panel
- **GNOME Shell extensions** — installed from extensions.gnome.org (active after the next login):
  - **Clipboard Indicator** — clipboard history in the top bar (Wayland-friendly)
  - **AppIndicator Support** — legacy system-tray / status icons
  - **Wallpaper Slideshow** — rotate the desktop wallpaper on a timer
  - **Lock Screen Extension** — customize the lock screen
  - **Unblank** — keep the screen on / readable while locked

---

## Everyday (`01-everyday.sh`)

| App | What it is |
|---|---|
| **Google Chrome** *(Flatpak)* | Web browser — set as the default |
| **Telegram** *(Flatpak)* | Messenger |
| **Teams for Linux** *(Flatpak)* | Unofficial MS Teams client |
| **VLC** | Universal video player — set as the default for video |
| **Audacious** | Lightweight audio player — set as the default for audio |
| **GThumb** | Image viewer with light editing |
| **GIMP** | Full image editor (Photoshop alternative) |
| **Xournal++** | Handwritten notes and PDF annotation |
| **KeePassXC** | Password manager (local vault) |
| **FileZilla** | FTP / SFTP client |
| **Transmission** | Torrent client |
| **Flameshot** | Screenshot tool — **bound to the PrintScreen key** |
| **Apostrophe** *(Flatpak)* | Markdown editor with live preview |

**Flameshot:** press <kbd>PrintScreen</kbd> to start a region capture (annotate,
arrow, blur, then copy or save).

---

## Terminal (`02-terminal.sh`)

The biggest group — turns the terminal into a comfortable place to work.

### Shell & prompt
| Tool | What it is |
|---|---|
| **fish** | Friendly shell with smart autocompletion (set as default login shell) |
| **Ptyxis** | Modern GNOME terminal (default terminal, <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>T</kbd>) |
| **Starship** | Fast, informative prompt (git branch, language versions, exit status) |

### Modern CLI tools
| Tool | Replaces | Example |
|---|---|---|
| **ripgrep** (`rg`) | grep | `rg "TODO" --type php` |
| **fd** (`fd-find`) | find | `fd -e log` — find all `.log` files |
| **bat** | cat | `bat app.py` — syntax highlighting + line numbers |
| **eza** | ls | aliased to `ls` / `ll` / `la` / `lt` (tree) |
| **zoxide** | cd | `z proj` jumps to your most-used "proj" dir; `zi` picks interactively |
| **fzf** | — | fuzzy finder: `vim $(fzf)`, or <kbd>Ctrl</kbd>+<kbd>R</kbd> for history |
| **glow** | — | `glow README.md` — render Markdown in the terminal |
| **btop** | top/htop | `btop` — interactive CPU/RAM/net/disk monitor |
| **ncdu** | du | `ncdu /` — find what's eating disk space |
| **tmux** | — | terminal multiplexer; sessions survive SSH drops |
| **jq** | — | `curl … | jq .` — pretty-print & query JSON |
| **yq** | — | `yq . docker-compose.yml` — same, for YAML |
| **direnv** | — | auto-loads a project's `.envrc` on `cd` in (run `direnv allow` once) |

### yazi — terminal file manager
`yazi` is a fast three-pane file manager with live previews and vim keys.

```bash
yazi          # open the file manager
y             # open it, then cd the shell into the last dir you browsed
```

Previews are wired up out of the box: **images & PDFs** via chafa, **Markdown →
glow**, **JSON → jq**, **YAML → yq**.

**Example — jump around and inspect:**
```bash
z myproject          # zoxide jumps to the project
ll                    # eza long listing with git status
rg "createUser" -A3   # ripgrep the call sites
bat src/User.php      # read a file with highlighting
y                     # browse files, cd on exit
```

---

## Development (`03-development.sh`)

| Tool | What it is |
|---|---|
| **httpie** | Human-friendly HTTP client — `http GET :8000/api name==bob` |
| **mycli** | MySQL/MariaDB CLI with autocompletion + highlighting |
| **pgcli** | PostgreSQL CLI with autocompletion + highlighting |
| **net-tools** | Classic network utilities (`ifconfig`, `netstat`, …) |
| **Wireshark** | Capture and analyze network traffic (your user can capture without root) |
| **lazygit** | Terminal UI for git — stage/commit/branch/rebase/stash by keyboard. Run `lazygit` |
| **lazydocker** | Terminal UI for Docker/compose — browse containers, tail logs, exec. Run `lazydocker` |
| **VS Code** *(Flatpak)* | Code editor |
| **DBeaver** *(Flatpak)* | Universal database GUI client |
| **Bruno** *(Flatpak)* | Offline, git-friendly API client (REST/GraphQL) |
| **PhpStorm** | PHP IDE, extracted to `/opt` — launch `/opt/PhpStorm-*/bin/phpstorm.sh` |

**Examples:**
```bash
http POST :8000/login email==me@x.com password==secret   # HTTPie request
lazygit                                                    # git UI in the current repo
lazydocker                                                 # inspect running containers
```

> The script also opens firewall port **9003** for Xdebug from Docker containers.
> Delete that line in the script if you don't run PHP in Docker.

---

## Games (`04-games.sh`)

Installs **Steam** and **GameMode**. Useful Steam launch options (per game →
Properties → Launch Options):

```bash
gamemoderun %command%                                              # perf tuning while playing
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia %command%   # run on the NVIDIA GPU
```

Enable **Steam Play (Proton)** in Steam → Settings → Compatibility to run Windows
games.

---

## Requirements

- Fedora Workstation (GNOME) — a fresh install
- Internet access and sudo privileges
