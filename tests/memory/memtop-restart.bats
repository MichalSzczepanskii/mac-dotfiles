#!/usr/bin/env bats
# memtop --restart: osascript/open/ps/top are stubs in $FAKE; no real app is ever touched.
# State file $QUIT: osascript creates it (app gone), open removes it (app back).

MEMTOP="$BATS_TEST_DIRNAME/../../.config/memory/memtop"

setup() {
  FAKE="$BATS_TEST_TMPDIR/bin"; mkdir -p "$FAKE"
  export PATH="$FAKE:$PATH" QUIT="$BATS_TEST_TMPDIR/quit" CALLS="$BATS_TEST_TMPDIR/calls"
  cat > "$FAKE/top" <<'T'
#!/bin/sh
if [ -e "$QUIT.reopened" ]; then printf 'PID MEM CMPRS\n150 80M 0B\n'
else printf 'PID MEM CMPRS\n100 300M 100M\n101 200M 50M\n200 400M 10M\n'; fi
T
  cat > "$FAKE/ps" <<'T'
#!/bin/sh
[ -e "$QUIT" ] || { if [ -e "$QUIT.reopened" ]; then pid=150; else pid=100; fi
  echo "  $pid     1 /Applications/Microsoft Teams.app/Contents/MacOS/MSTeams"
  echo "  101   $pid /Applications/Microsoft Teams.app/Contents/Helpers/Teams Helper.app/Contents/MacOS/Teams Helper"; }
echo "  200     1 /Applications/Slack.app/Contents/MacOS/Slack"
T
  cat > "$FAKE/osascript" <<'T'
#!/bin/sh
echo "osascript $*" >> "$CALLS"; [ -n "$STUCK" ] || touch "$QUIT"
T
  cat > "$FAKE/open" <<'T'
#!/bin/sh
echo "open $*" >> "$CALLS"; rm -f "$QUIT"; touch "$QUIT.reopened"
T
  printf '#!/bin/sh\necho "kill $*" >> "$CALLS"\n' > "$FAKE/kill"
  chmod +x "$FAKE"/*
}

@test "not-running app: clear message, non-zero, nothing quit" {
  run "$MEMTOP" --restart Telegram <<< y
  [ "$status" -ne 0 ]
  echo "$output" | grep -q 'Telegram is not running'
  [ ! -e "$CALLS" ]
}

@test "y: graceful quit, reopen, memory before and after" {
  run "$MEMTOP" --restart "Microsoft Teams" <<< y
  [ "$status" -eq 0 ]
  [ "$(cat "$CALLS")" = "osascript -e quit app \"Microsoft Teams\"
open -a Microsoft Teams" ]
  # before: main 300 + helper 200 = 500M mem, 150M compressed; after: 80M
  echo "$output" | grep -A1 '^Before' | grep -Eq '^Microsoft Teams +500M +150M'
  echo "$output" | grep -A1 '^After' | grep -Eq '^Microsoft Teams +80M +0M'
  ! echo "$output" | grep -q '^Slack'
}

@test "any answer other than y does nothing" {
  for ans in n Y yes ""; do
    run "$MEMTOP" --restart "Microsoft Teams" <<< "$ans"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q 'Nothing done'
    [ ! -e "$CALLS" ]
  done
}

@test "app that will not quit: not reopened, non-zero, never killed" {
  STUCK=1 MEMTOP_TIMEOUT=1 run "$MEMTOP" --restart "Microsoft Teams" <<< y
  [ "$status" -ne 0 ]
  echo "$output" | grep -q 'did not quit'
  [ "$(cat "$CALLS")" = 'osascript -e quit app "Microsoft Teams"' ]
}

@test "--restart without an app name fails with usage" {
  run "$MEMTOP" --restart
  [ "$status" -eq 2 ]
  echo "$output" | grep -q 'usage'
}
