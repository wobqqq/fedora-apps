#!/usr/bin/env bats

setup() {
  source "$BATS_TEST_DIRNAME/../lib/common.sh"
}

@test "an item is appended to a list that has others" {
  run gvariant_list_append "['/a/', '/b/']" "/c/"
  [ "$output" = "['/a/', '/b/', '/c/']" ]
}

@test "an empty list starts with the item, in both forms GNOME prints" {
  run gvariant_list_append "@as []" "/c/"
  [ "$output" = "['/c/']" ]
  run gvariant_list_append "[]" "/c/"
  [ "$output" = "['/c/']" ]
}

@test "an item already in the list is not added twice" {
  run gvariant_list_append "['/a/', '/c/']" "/c/"
  [ "$output" = "['/a/', '/c/']" ]
}

@test "an item that is only a prefix of an existing one is still added" {
  run gvariant_list_append "['/custom/flameshot-old/']" "/custom/flameshot/"
  [ "$output" = "['/custom/flameshot-old/', '/custom/flameshot/']" ]
}

@test "the checksum of an asset is read from a checksums.txt list" {
  run checksum_for lazygit_0.65.1_linux_x86_64.tar.gz <<'LIST'
aaaa  lazygit_0.65.1_darwin_arm64.tar.gz
02beac  lazygit_0.65.1_linux_x86_64.tar.gz
LIST
  [ "$status" -eq 0 ]
  [ "$output" = "02beac" ]
}

@test "the binary-mode marker of sha256sum lists is understood" {
  run checksum_for PhpStorm-2026.2.3.tar.gz <<<"d9fa *PhpStorm-2026.2.3.tar.gz"
  [ "$output" = "d9fa" ]
}

@test "an asset missing from the list is an error" {
  run checksum_for lazygit_linux_arm64.tar.gz <<<"aaaa  lazygit_linux_x86_64.tar.gz"
  [ "$status" -ne 0 ]
  [ -z "$output" ]
}

@test "a file matching its checksum passes" {
  printf 'payload' > "$BATS_TEST_TMPDIR/file"
  run verify_sha256 "$BATS_TEST_TMPDIR/file" "$(printf 'payload' | sha256sum | cut -d' ' -f1)"
  [ "$status" -eq 0 ]
}

@test "a file that does not match is refused" {
  printf 'tampered' > "$BATS_TEST_TMPDIR/file"
  run verify_sha256 "$BATS_TEST_TMPDIR/file" "$(printf 'payload' | sha256sum | cut -d' ' -f1)"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Checksum mismatch"* ]]
}

@test "a missing or malformed checksum is refused, never skipped" {
  printf 'payload' > "$BATS_TEST_TMPDIR/file"
  run verify_sha256 "$BATS_TEST_TMPDIR/file" ""
  [ "$status" -ne 0 ]
  run verify_sha256 "$BATS_TEST_TMPDIR/file" "not-a-hash"
  [ "$status" -ne 0 ]
}
