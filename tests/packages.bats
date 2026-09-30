#!/usr/bin/env bats

@test "every dnf package of the scripts is listed, continuation lines included" {
  run "$BATS_TEST_DIRNAME/../tools/packages.sh" dnf
  [ "$status" -eq 0 ]
  for pkg in wget unrar flatpak vlc steam ripgrep akmod-nvidia wireshark nodejs; do
    grep -qxF "$pkg" <<<"$output"
  done
}

@test "options, URLs, local files and variables are not taken for packages" {
  run "$BATS_TEST_DIRNAME/../tools/packages.sh" dnf
  ! grep -E '^-|/|\$|\.rpm$|^(sudo|dnf|install)$' <<<"$output"
}

@test "every Flathub application is listed" {
  run "$BATS_TEST_DIRNAME/../tools/packages.sh" flatpak
  [ "$status" -eq 0 ]
  grep -qxF com.google.Chrome <<<"$output"
  grep -qxF com.visualstudio.code <<<"$output"
  ! grep -qxF flathub <<<"$output"
}
