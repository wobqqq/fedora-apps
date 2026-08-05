# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Post-install setup for a fresh **Fedora Workstation (GNOME)** on a backend
developer's laptop. Not an application — a set of numbered bash scripts meant to
be **read and understood**, or copy-pasted piecemeal, as much as executed. There
is no build, no test suite, no dependency manifest.

## Commands

```bash
chmod +x *.sh
./00-base.sh            # always first — the rest assume RPM Fusion + Flathub
./03-development.sh     # then any group, in any order
bash -n 03-development.sh   # syntax check — the only safe "test"
```

Scripts run as the **normal user** and call `sudo` themselves. The one exception
is `predator-pt316-51s/install-nvidia.sh`, which requires root and exits if
`$EUID -ne 0`.

**Do not run these scripts to verify an edit.** They upgrade the whole system,
remove packages (`chromium`, `thunderbird`), swap `ffmpeg-free`, replace
`firewalld` with `ufw`, change the default login shell, and write to
`/etc/profile.d` and `/etc/fish/conf.d`. Verify with `bash -n` and by reading.

## Structure

`NN-name.sh` at the root, one per app group, executed in ascending order.
`00-base.sh` is the only hard prerequisite — it enables RPM Fusion and the
Flathub remote that every later script installs from. Beyond that, each script is
independent and safe to re-run.

Hardware-specific setup lives in its own subdirectory with its own README
(`predator-pt316-51s/` — NVIDIA driver + cheatsheet for one laptop model), so the
root scripts stay machine-agnostic.

## Script conventions

Every root script follows the same shape — match it when adding one:

1. `#!/usr/bin/env bash`, then a header comment: name + one-line purpose, what it
   installs, which script it depends on, and the invocation (`#   ./05-vpn.sh`).
2. `set -euo pipefail`, then `sudo -v` to collect the password once up front.
3. Body split by `# --- Section name ---` comments.
4. A closing `echo` block: what got installed, the commands the user now has, and
   anything needing a logout/reboot.

**Idempotency is a hard requirement** — everything is re-run regularly to update.
Guard with `command -v`, `rpm -q`, `[[ -f ]]`, `grep -qxF`, `--if-not-exists`,
and append `|| true` to best-effort desktop tweaks (`gsettings`, `usermod`) so a
failure on one machine doesn't abort the script.

**Where packages come from**, in order of preference:

- `dnf install -y` — system and CLI tools
- `flatpak install -y --user flathub` — GUI apps (no root, no password prompt)
- GitHub release binary into `/usr/local/bin` — only when Fedora has no package
  (lazygit, lazydocker, starship, yazi). Pattern: read the version from the
  GitHub API's `tag_name`, download into a `mktemp -d`, install, `rm -rf`.
- `npm install -g` with the prefix moved to `~/.local` (`06-gemini-cli.sh`), so
  global installs never need sudo and never leave root-owned files in `~/.npm`.

Pinned URLs that will go stale get a `NOTE:` comment saying where to refresh them
(see the PhpStorm block in `03-development.sh`).

## Two patterns duplicated across scripts

**GNOME custom keybindings** (`01-everyday.sh` Flameshot, `02-terminal.sh`
Ptyxis): appending to `custom-keybindings` requires a `case` that handles the
`@as []` / `[]` / non-empty forms separately, or you clobber the user's existing
shortcuts. Copy the existing block; don't re-derive it. GNOME's built-in bindings
must be cleared first (`show-screenshot-ui`, `screenshot`) because they win.

**Shell integration** (`02-terminal.sh`): bash and fish are always wired up as a
pair — `/etc/profile.d/<tool>.sh` guarded by `case $- in *i*)` and
`/etc/fish/conf.d/<tool>.fish` guarded by `status is-interactive; and command -q`.
Adding a shell tool means writing both files, system-wide, not touching dotfiles.

## Comments and docs

Comments explain **why**, not what: why `ffmpeg-free` gets swapped, why curl has
to run before dnf for the Windscribe RPM, why 125% scaling plus 1.2 font scaling
instead of 150%, why Cloudflare's `$releasever` baseurl can 404 after a Fedora
upgrade. Keep them in **English** regardless of the language of the conversation.

`README.md` is the single user-facing document and must stay in sync with the
scripts. Adding a script means three edits: a row in the table at the top, a line
in the Quick start block, and a `## Group (\`NN-name.sh\`)` section in script
order, before `## Requirements`. Sections document *usage* — the commands the
installed tool gives you — not a restatement of what the script installs.
