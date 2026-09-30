---
name: adding-an-app
description: "How to add an app, a CLI tool or a GNOME tweak to one of the NN-*.sh scripts. Use when asked to install something new, replace an app, or change where one comes from."
license: MIT
---

# Adding an app

## 1. Pick the group and the source

The script is the group the README table gives it. The source, in this order:

1. **Fedora / RPM Fusion** — `sudo dnf install -y name` in the script's existing
   `dnf install` block. Check the exact name exists: `make packages` (a package
   another one *provides*, such as `wget`, is fine).
2. **Flathub** — GUI apps, `flatpak install -y --user flathub app.id` in the
   script's Flathub block. `make links` checks the ID resolves.
3. **An upstream release binary** — only when neither has it. It must publish a
   checksum (`checksums.txt`, a `.sha256` next to the asset, or at least the digest
   GitHub records). No checksum, no install: say so instead of adding it.
4. **Never** `curl … | sh`, never an unchecked download, never a new third-party
   dnf repository without its signing key.

## 2. Write it the way the script already does

- Release binary: guard with `command -v`, then
  `download_verified URL "$work/asset" "$(… checksum …)"` and `sudo install -m755`
  into `/usr/local/bin` (see `install_release_binary` in `03-development.sh`).
- Everything guarded so a second run changes nothing: `command -v`, `rpm -q`,
  `[[ -f ]]`, `grep -qxF`, `--if-not-exists`; `|| true` only on best-effort desktop
  tweaks (`gsettings`), never on an install.
- A shell integration is two files, `/etc/profile.d/<tool>.sh` and
  `/etc/fish/conf.d/<tool>.fish` (see `02-terminal.sh`).
- A keyboard shortcut is `add_custom_keybinding` from `lib/common.sh`.
- A new helper in `lib/common.sh` gets a test in `tests/common.bats`.

## 3. Document it

- A row in the group's table in `README.md` (what it is, how to use it), and the
  table in `GEMINI.md` if the group's summary changes.
- A new download URL pattern goes into `tools/check-links.sh`.

## 4. Check

`make ready`, then `make packages` or `make links` for what you touched. Never run
the script itself to test it.
