#!/usr/bin/env bats
# stow must skip repo-only dirs, or it links them into ~.

@test "stow ignores scripts, .git and tests" {
  f="$BATS_TEST_DIRNAME/../../.stow-local-ignore"
  for d in scripts .git tests; do grep -qxF "$d" "$f"; done
}
