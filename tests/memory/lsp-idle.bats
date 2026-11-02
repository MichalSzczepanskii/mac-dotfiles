#!/usr/bin/env bats
# Idle LSP stop (#83). tmux, ps, nvim, date and getconf are stubbed; calls land in $CALLS.

SCRIPT="$BATS_TEST_DIRNAME/../../.config/memory/lsp-idle"
NOW=1000000

setup() {
  export STUB_BIN="$BATS_TEST_TMPDIR/bin" CALLS="$BATS_TEST_TMPDIR/calls"
  export PANES="$BATS_TEST_TMPDIR/panes" PS_OUT="$BATS_TEST_TMPDIR/ps" USER=tester
  export FAKE_TMP="$BATS_TEST_TMPDIR/T"
  mkdir -p "$STUB_BIN" "$FAKE_TMP/nvim.tester"
  : >"$PANES"; : >"$PS_OUT"; : >"$CALLS"
  stub tmux 'echo "tmux $*" >>"$CALLS"; [ "$1" = list-panes ] && cat "$PANES"; exit 0'
  stub ps 'cat "$PS_OUT"'
  stub nvim 'echo "nvim $*" >>"$CALLS"; echo stopped'
  stub date "echo $NOW"
  stub getconf 'echo "$FAKE_TMP/"'
  export PATH="$STUB_BIN:$PATH"
}

stub() { printf '#!/bin/sh\n%s\n' "$2" >"$STUB_BIN/$1"; chmod +x "$STUB_BIN/$1"; }

# session <name> <attached> <left (@lsp_left, else session_activity)> <pane_pid>
session() { printf '%s\t%s\t%s\t%s\n' "$2" "$3" "$4" "$1" >>"$PANES"; }
# proc <pid> <ppid> <command...>
proc() { local pid=$1 ppid=$2; shift 2; printf '%s %s %s\n' "$pid" "$ppid" "$*" >>"$PS_OUT"; }
# an nvim (TUI pid + embedded server pid with an RPC socket) under a pane shell
nvim_in() {
  proc "$2" "$1" nvim .
  proc "$3" "$2" nvim --embed
  mkdir -p "$FAKE_TMP/nvim.tester/x$3" && : >"$FAKE_TMP/nvim.tester/x$3/nvim.$3.0"
}
not_called() { ! grep -q -- "$1" "$CALLS"; } # plain `! grep` mid-test never fails in bats
sock() { echo "$FAKE_TMP/nvim.tester/x$1/nvim.$1.0"; }

@test "stop: session left over 30 min ago gets its nvim LSP stopped" {
  session proj 0 $((NOW - 1801)) 100
  nvim_in 100 101 102
  run "$SCRIPT" stop
  [ "$status" -eq 0 ]
  grep -q "^nvim --server $(sock 102) --remote-expr " "$CALLS"
}

@test "stop: session left under 30 min ago keeps LSP" {
  session proj 0 $((NOW - 1800)) 100
  nvim_in 100 101 102
  run "$SCRIPT" stop
  [ "$status" -eq 0 ]
  not_called '^nvim'
}

@test "stop: the attached session keeps LSP however long ago it was left" {
  session proj 1 $((NOW - 9999)) 100
  nvim_in 100 101 102
  run "$SCRIPT" stop
  [ "$status" -eq 0 ]
  not_called '^nvim'
}

@test "stop: the session running ng serve in any pane keeps LSP; others still stop" {
  session main 0 $((NOW - 9999)) 100
  session main 0 $((NOW - 9999)) 200
  nvim_in 100 101 102
  proc 201 200 npm start
  proc 202 201 node /Users/x/proj/node_modules/.bin/ng serve --port 4200
  session other 0 $((NOW - 9999)) 300
  nvim_in 300 301 302
  run "$SCRIPT" stop
  [ "$status" -eq 0 ]
  not_called "$(sock 102)"
  grep -q "$(sock 302)" "$CALLS"
}

@test "switched: records the leave time of the old session and brings LSP back in the new one" {
  session 'old one' 0 1 100
  nvim_in 100 101 102
  session new 1 1 300
  nvim_in 300 301 302
  run "$SCRIPT" switched 'old one' new
  [ "$status" -eq 0 ]
  grep -qx "tmux set-option -t =old one @lsp_left $NOW" "$CALLS"
  grep -q "^nvim --server $(sock 302) --remote-expr " "$CALLS"
  not_called "$(sock 102)"
}

@test "switched: first attach (no old session) sets nothing" {
  run "$SCRIPT" switched '' new
  [ "$status" -eq 0 ]
  not_called set-option
}

@test "tmux.conf hooks session switches to lsp-idle switched, shell-quoted" {
  grep -qxF "set-hook -g client-session-changed[83] 'run-shell -b \"~/.config/memory/lsp-idle switched #{q:client_last_session} #{q:session_name}\"'" \
    "$BATS_TEST_DIRNAME/../../.config/memory/tmux.conf"
}

@test "launchd agent runs lsp-idle stop every 5 minutes" {
  plist="$BATS_TEST_DIRNAME/../../.config/memory/lsp-idle.plist"
  plutil -lint "$plist"
  [ "$(plutil -extract StartInterval raw "$plist")" = 300 ]
  [ "$(plutil -extract ProgramArguments.2 raw "$plist")" = '"$HOME/.config/memory/lsp-idle" stop' ]
}
