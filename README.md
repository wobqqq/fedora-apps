# fedora-apps

[![CI](https://github.com/wobqqq/fedora-apps/actions/workflows/ci.yml/badge.svg)](https://github.com/wobqqq/fedora-apps/actions/workflows/ci.yml)
[![Download links](https://github.com/wobqqq/fedora-apps/actions/workflows/links.yml/badge.svg)](https://github.com/wobqqq/fedora-apps/actions/workflows/links.yml)
[![Fedora](https://img.shields.io/badge/Fedora-Workstation%20(GNOME)-51a2da?logo=fedora&logoColor=white)](https://fedoraproject.org/workstation/)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-clean-brightgreen)](Makefile)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

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
| [`05-vpn.sh`](05-vpn.sh) | **VPN** | Windscribe client (GUI + CLI), Cloudflare WARP (CLI) |
| [`06-gemini-cli.sh`](06-gemini-cli.sh) | **AI CLI** | Node.js + Gemini CLI (AI coding agent in the terminal) |

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
./05-vpn.sh           # Windscribe + Cloudflare WARP
./06-gemini-cli.sh    # Node.js + Gemini CLI
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

## VPN (`05-vpn.sh`)

Two clients for two different jobs:

| Client | What it's for | Pick a country? | Interface |
|---|---|---|---|
| **Windscribe** | Change your exit country, kill switch, ad/tracker blocking | **Yes** — 60+ countries | GUI + `windscribe-cli` |
| **Cloudflare WARP** | Encrypt traffic + DNS through the nearest Cloudflare edge | No | `warp-cli` only |

They **can't run at the same time** — both claim the default route. Disconnect
one before connecting the other.

### Windscribe

Official desktop client, GUI plus the `windscribe-cli` command; WireGuard and
OpenVPN are bundled, nothing else to install. Log in once (GUI: Applications →
Windscribe → *Login*), after that the CLI is usually faster:

```bash
windscribe-cli login
windscribe-cli locations           # all locations: city / ISO code / nickname
windscribe-cli connect de          # by country, city, region or nickname
windscribe-cli connect "Frankfurt"
windscribe-cli connect best        # fastest server
windscribe-cli status
windscribe-cli disconnect
```

No need to disconnect before switching countries — a new `connect` just moves the
tunnel. Extras: `windscribe-cli ip rotate` (new IP in the same country, Pro),
`windscribe-cli connect de wireguard` (location + protocol), `windscribe-cli
firewall on|off` (kill switch).

The client keeps its own firewall rules, so **ufw stays exactly as `00-base.sh`
configured it** — no ports to open.

> **Updates:** Windscribe publishes no dnf repo — the script downloads the RPM
> straight from windscribe.com, and `dnf upgrade` won't touch it. Just re-run
> `./05-vpn.sh` when a new version comes out; the download URL always points at
> the latest build.

Troubleshooting: if the app says it can't reach its background service, check
`systemctl status windscribe-helper`.

### Cloudflare WARP

Installed from Cloudflare's own dnf repo, so `dnf upgrade` keeps it current. No
GUI on Linux — the `warp-svc` daemon plus `warp-cli`:

```bash
warp-cli registration new          # once, registers this device
warp-cli connect
warp-cli status
warp-cli disconnect

warp-cli mode warp                 # full tunnel (default)
warp-cli mode doh                  # encrypt DNS only, traffic goes direct
warp-cli mode warp+doh
warp-cli tunnel protocol set MASQUE   # or WireGuard
warp-cli dns families malware      # block malware domains at DNS level
warp-cli registration license <KEY>   # activate WARP+
```

**You cannot choose a country.** WARP is anycast: you always dial the same
address and routing lands you in the nearest WARP-enabled Cloudflare data center
— sometimes not even the geographically closest one, since Cloudflare prioritizes
reliability. Exit-point selection exists only in Zero Trust egress policies
(paid, enterprise). Need a specific country → use Windscribe.

Troubleshooting: `systemctl status warp-svc`.

### Where am I coming out?

```bash
curl -s https://ipinfo.io/json | jq '.ip, .country, .city'
curl -s https://www.cloudflare.com/cdn-cgi/trace | grep -E '^(colo|loc|warp)='
# colo=WAW  loc=PL  warp=on   <- Cloudflare data center, exit country, WARP active
```

(`jq` comes from [`02-terminal.sh`](02-terminal.sh); drop it and read the raw JSON
if you skipped that group.)

### Prefer no proprietary client?

Generate a WireGuard config in your Windscribe account (Config Generator) and
hand it to NetworkManager, which speaks WireGuard natively — no extra package
needed:

```bash
nmcli connection import type wireguard file ~/Downloads/Windscribe-XXX.conf
nmcli connection up Windscribe-XXX
```

Lighter and wired into the GNOME VPN toggle (Settings → Network can't *edit* a
WireGuard profile, only switch it on/off), but you lose the client's features
(auto-connect per network, kill switch, R.O.B.E.R.T. blocking).

---

## AI CLI (`06-gemini-cli.sh`)

**Gemini CLI** is an AI coding agent that runs in the terminal: it reads and
edits files in the current directory, runs shell commands, and asks you to
confirm each step. Installs Node.js 20+ and the CLI from npm.

Global npm packages land in `~/.local` (the script sets `npm config set prefix`),
so `npm i -g` never needs sudo and updates are just a re-run of the script.

### Get an API key

Authentication is **not** scripted — you paste a key on first run.

1. Open **<https://aistudio.google.com/apikey>** (Google account, no card).
2. **Create API key** → copy it (`AIza…`).
3. Run `gemini` in a project directory → `/auth` → **Use Gemini API Key** → paste.

> **Do not enable billing** on that Google Cloud project. Attaching a card
> converts it to the paid tier and the free quota disappears for good.

Free-tier quota is per model, so pick the right one with `/model`:

| Model | Free requests/day | Good for |
|---|---|---|
| **Flash** | ~1500 | everything routine — reading code, boilerplate, logs, docs |
| **Pro** | ~50 | hard problems only; an agent burns 5–15 requests per task |

> **"Sign in with Google" is dead.** The free Gemini Code Assist tier for
> individuals was shut down on **2026-06-18** — picking that option fails with
> *"This client is no longer supported for Gemini Code Assist for individuals"*.
> The API key path above goes to a different backend and is still free.
> If AI Studio is blocked in your country, connect a VPN first
> ([`05-vpn.sh`](05-vpn.sh)).

### Using it

```bash
cd ~/Projects/fedora-apps
gemini                      # start a session in this directory
gemini -p "list every package these scripts install"   # one-shot, no UI
```

Then just describe the task in plain language — *"explain what 05-vpn.sh does"*,
*"add a Node.js install to 03-development.sh"*. Every file edit and command needs
your confirmation.

| Input | What it does |
|---|---|
| `@README.md` | pull a specific file into context (Tab completes paths) |
| `!dnf list installed` | run a shell command directly; bare `!` toggles shell mode |
| `/help` | list all commands |
| `/auth` | switch authentication method |
| `/model` | switch model (use this to stay on Flash) |
| `/clear` | wipe the context when the agent goes off the rails |
| `/compress` | summarize history when the context window fills up |
| `/stats` | tokens and requests used this session |
| <kbd>Esc</kbd> | interrupt the current answer |
| <kbd>Ctrl</kbd>+<kbd>C</kbd> ×2 | quit |

### Project context

Drop a `GEMINI.md` in the repo root and it's loaded automatically on every run in
that directory — the cheapest way to stop the agent guessing your conventions:

```markdown
# fedora-apps

Numbered bash scripts that set up a fresh Fedora Workstation, run in order.

Rules:
- bash with `set -euo pipefail`, comments in English
- everything idempotent: re-running must not break the system
- dnf for CLI tools, `flatpak --user` for GUI apps
```

The CLI also asks whether to **trust the folder** on first run in a new
directory. Trust the specific repo, not the parent `Projects` dir — trust lets it
load that folder's config, custom commands and MCP servers.

### Qwen Code

The script has a commented-out line for **Qwen Code** (a fork of Gemini CLI with
prompts tuned for Qwen3-Coder). It's left off on purpose: the free Qwen OAuth
login was shut down on **2026-04-15**, so it now needs a paid Alibaba *Coding
Plan* or a third-party provider key. The free fallback is OpenRouter with a
`:free` model — 50 requests/day, and not Qwen3-Coder. Uncomment the line only if
you actually have a key.

---

## What gets installed from where

Nothing is downloaded and run blindly. In order of preference:

| Source | Used for | Trust |
|---|---|---|
| **Fedora repositories** | most CLI tools and system packages | signed by Fedora, checked by dnf |
| **RPM Fusion** (free + nonfree) | VLC, Steam, unrar, full ffmpeg, the NVIDIA driver | signed by RPM Fusion; its release packages come from its own mirrors over HTTPS |
| **Flathub** (per-user) | GUI apps | signed Flatpak remote |
| **Vendor repositories** | Cloudflare WARP | signed by the vendor, checked by dnf |
| **Vendor packages** | Windscribe | the package signature is checked against Windscribe's key before dnf installs it |
| **Upstream releases** | starship, yazi, lazygit, lazydocker, PhpStorm | the archive is installed only if its SHA-256 matches the checksum the release publishes (`checksums.txt`, a `.sha256` file, or the digest GitHub records) |
| **extensions.gnome.org** | GNOME Shell extensions | downloaded over HTTPS from the official site; it publishes no checksums |
| **npm** | Gemini CLI | the npm registry, into `~/.local` (no sudo) |

The GitHub API allows 60 anonymous requests an hour; if a script hits the limit, export a `GITHUB_TOKEN` and run it again.

## Checks

The scripts are checked on every change, in Docker (the host needs only Docker with Compose and `make`; the images are listed in `docker-compose.yaml`):

```bash
make lint       # ShellCheck + bash -n on every script
make test       # Bats tests of the shared helpers and the package lists
make packages   # every dnf package still exists on the latest Fedora (with RPM Fusion)
make links      # every download, and the checksum it is verified against, still resolves
```

`make links` also runs every week on GitHub Actions, so a release that renames its assets is noticed before the next install.

## Requirements

- Fedora Workstation (GNOME) — a fresh install
- Internet access and sudo privileges

## License

[MIT](LICENSE)
