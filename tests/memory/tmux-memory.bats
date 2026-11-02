#!/usr/bin/env bats
# tmux status segment (#81): swap used, coloured by memory pressure. sysctl is stubbed.

SCRIPT="$BATS_TEST_DIRNAME/../../.config/memory/tmux-memory"

setup() {
  export STUB_BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$STUB_BIN"
  export PATH="$STUB_BIN:$PATH"
}

# stub_sysctl <vm.swapusage output> <pressure level>
stub_sysctl() {
  cat >"$STUB_BIN/sysctl" <<STUB
#!/bin/sh
case "\$2" in
  vm.swapusage) echo "$1" ;;
  kern.memorystatus_vm_pressure_level) echo "$2" ;;
  *) exit 1 ;;
esac
STUB
  chmod +x "$STUB_BIN/sysctl"
}

@test "normal pressure: swap in GB, green" {
  stub_sysctl "total = 5120.00M  used = 2252.80M  free = 2867.20M  (encrypted)" 1
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "#[fg=#9ece6a,bg=#16161e] swap 2.2G " ]
}

@test "warn pressure: yellow" {
  stub_sysctl "total = 5120.00M  used = 4452.12M  free = 667.88M  (encrypted)" 2
  run "$SCRIPT"
  [ "$output" = "#[fg=#e0af68,bg=#16161e] swap 4.3G " ]
}

@test "critical pressure: red" {
  stub_sysctl "total = 0.00M  used = 0.00M  free = 0.00M  (encrypted)" 4
  run "$SCRIPT"
  [ "$output" = "#[fg=#f7768e,bg=#16161e] swap 0.0G " ]
}

@test "sysctl fails: empty segment, no error in the status bar" {
  printf '#!/bin/sh\nexit 1\n' >"$STUB_BIN/sysctl"; chmod +x "$STUB_BIN/sysctl"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "tmux.conf appends the segment to status-right" {
  grep -qx 'set -ga status-right "#(~/.config/memory/tmux-memory)"' "$BATS_TEST_DIRNAME/../../.config/memory/tmux.conf"
}
