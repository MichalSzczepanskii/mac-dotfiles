#!/usr/bin/env bats
# memtop: real top/ps/tmux/sysctl are replaced by stubs in $FAKE.

MEMTOP="$BATS_TEST_DIRNAME/../../.config/memory/memtop"

setup() {
  FAKE="$BATS_TEST_TMPDIR/bin"; mkdir -p "$FAKE"
  export PATH="$FAKE:$PATH"
  # top: pid mem cmprs; ps gives full paths
  cat > "$FAKE/top" <<'T'
#!/bin/sh
cat <<'O'
Processes: 9 total
PhysMem: 23G used

PID    MEM   CMPRS
100  300M  100M
101  200M+  50M
102  1G  0B
200  400M  10M
300  50M  0B
400  30M  0B
500  20M  0B
600  10M  0B
700  5M  0B
701  40M  0B
702  900M  100M
800  5M  0B
801  20M  0B
O
T
  cat > "$FAKE/ps" <<'T'
#!/bin/sh
cat <<'O'
  100     1 /Applications/Brave Browser.app/Contents/MacOS/Brave Browser
  101   100 /Applications/Brave Browser.app/Contents/Frameworks/X.framework/Helpers/Brave Browser Helper (Renderer).app/Contents/MacOS/Brave Browser Helper (Renderer)
  102   100 /Applications/Brave Browser.app/Contents/Frameworks/X.framework/Helpers/Brave Browser Helper.app/Contents/MacOS/Brave Browser Helper
  200     1 /Applications/Slack.app/Contents/MacOS/Slack
  300     1 /System/Library/CoreServices/Finder.app/Contents/MacOS/Finder
  400     1 /System/Applications/Mail.app/Contents/MacOS/Mail
  500     1 /System/Applications/Notes.app/Contents/MacOS/Notes
  600     1 /System/Applications/Preview.app/Contents/MacOS/Preview
  700     1 -zsh
  701   700 nvim
  702   701 /opt/homebrew/bin/node
  800     1 -zsh
  801   800 nvim
O
T
  cat > "$FAKE/tmux" <<'T'
#!/bin/sh
printf '700 work\n800 idle\n'
T
  cat > "$FAKE/sysctl" <<'T'
#!/bin/sh
case "$2" in
  vm.swapusage) echo 'total = 3072.00M  used = 1536.25M  free = 1535.75M  (encrypted)' ;;
  kern.memorystatus_vm_pressure_level) echo "${FAKE_PRESSURE:-2}" ;;
esac
T
  chmod +x "$FAKE"/*
}

@test "top 5 apps, helpers grouped under their app, biggest first" {
  run "$MEMTOP"
  [ "$status" -eq 0 ]
  # Brave = 300+200+1024 MB mem, 150 MB compressed
  echo "$output" | grep -Eq '^Brave Browser +1524M +150M'
  echo "$output" | grep -Eq '^Slack +400M +10M'
  [ "$(echo "$output" | grep -n '^Brave Browser' | cut -d: -f1)" -lt "$(echo "$output" | grep -n '^Slack' | cut -d: -f1)" ]
  ! echo "$output" | grep -q 'Helper'
  echo "$output" | grep -q '^Finder'
  ! echo "$output" | grep -q '^Mail'
}

@test "each tmux session sums its whole process tree" {
  run "$MEMTOP"
  [ "$status" -eq 0 ]
  # work: zsh 5 + nvim 40 + node 900 = 945 mem, 100 compressed
  echo "$output" | grep -Eq '^work +945M +100M'
  echo "$output" | grep -Eq '^idle +25M +0M'
}

@test "swap used and pressure level" {
  run "$MEMTOP"
  echo "$output" | grep -q 'Swap used: 1536M'
  echo "$output" | grep -q 'Pressure: warn'
  FAKE_PRESSURE=1 run "$MEMTOP"; echo "$output" | grep -q 'Pressure: normal'
  FAKE_PRESSURE=4 run "$MEMTOP"; echo "$output" | grep -q 'Pressure: critical'
}

@test "no tmux server: still reports apps" {
  printf '#!/bin/sh\nexit 1\n' > "$FAKE/tmux"
  run "$MEMTOP"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '^Brave Browser'
}

@test "unknown argument fails with usage" {
  run "$MEMTOP" --bogus
  [ "$status" -eq 2 ]
  echo "$output" | grep -q 'usage'
}

@test "process that rewrote its title is named by its first word" {
  printf '#!/bin/sh\nprintf "PID MEM CMPRS\\n900 2G 0B\\n"\n' > "$FAKE/top"
  printf '#!/bin/sh\necho "  900     1 ng serve -c=dev --port 4299 (front)"\n' > "$FAKE/ps"
  run "$MEMTOP"
  echo "$output" | grep -Eq '^ng +2048M +0M'
}

@test "tmux sessions listed biggest first" {
  run "$MEMTOP"
  [ "$(echo "$output" | grep -n '^work ' | cut -d: -f1)" -lt "$(echo "$output" | grep -n '^idle ' | cut -d: -f1)" ]
}
