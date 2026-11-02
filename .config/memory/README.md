# memory

Keeps `ng serve` fast under macOS memory pressure without rebooting. Spec: MichalSzczepanskii/ksdo-claude-setup#79.

Everything lives in this folder (live at `~/.config/memory` through the `~/.config` symlink). Tests: `bats tests/memory`.

## Pieces

| Piece | File | Ticket |
|---|---|---|
| `ng serve` env exports | `ng-env.zsh` | #84 |
| tmux status segment: swap, coloured by memory pressure | `tmux-memory`, `tmux.conf` | #81 |
| `memtop` report (read-only) | `memtop` | #80 |
| `memtop --restart <app>`: asks, quits the app gracefully (AppleScript `quit app`, never `kill`), reopens it, prints its memory before and after. App name = its `.app` name, e.g. `"Microsoft Teams"` | `memtop` | #82 |
| Idle LSP stop: LSP stops in idle tmux sessions, except the one running `ng serve`. Idle = left (switched away or detached) 30+ min ago, or attached with no input on its client for 30+ min, so after a night's sleep the first run stops all but the `ng serve` session. LSP comes back on switching to the session or on first use of that nvim | `lsp-idle`, `lsp-idle.plist`, `tmux.conf` | #83 |

## Install

1. `~/.zshrc`: add `source ~/.config/memory/ng-env.zsh`
2. `~/.config/tmux/tmux.conf`: add `source-file ~/.config/memory/tmux.conf` after the `source-file ~/.config/tmux/tokyonight_night.tmux` line (it appends to the theme's `status-right`, so it must come after it), then `tmux source-file ~/.config/tmux/tmux.conf`
3. `ln -s ~/.config/memory/memtop ~/.local/bin/memtop`
4. `cp ~/.config/memory/lsp-idle.plist ~/Library/LaunchAgents/ && launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/lsp-idle.plist` (a copy, not a symlink: launchd may skip a symlinked plist, and only plists in `~/Library/LaunchAgents` come back after a reboot)

## Undo

1. `~/.zshrc`: remove the `source ~/.config/memory/ng-env.zsh` line.
2. `~/.config/tmux/tmux.conf`: remove the `source-file ~/.config/memory/tmux.conf` line, then `tmux source-file ~/.config/tmux/tmux.conf` (the theme resets `status-right`), and `tmux set-hook -gu 'client-session-changed[83]' \; set-hook -gu 'client-detached[83]'`.
3. `rm ~/.local/bin/memtop`
4. `launchctl bootout gui/$(id -u)/lsp-idle && rm ~/Library/LaunchAgents/lsp-idle.plist`
