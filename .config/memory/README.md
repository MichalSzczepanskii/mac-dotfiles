# memory

Keeps `ng serve` fast under macOS memory pressure without rebooting. Spec: MichalSzczepanskii/ksdo-claude-setup#79.

Everything lives in this folder (live at `~/.config/memory` through the `~/.config` symlink). Tests: `bats tests/memory`.

## Pieces

| Piece | File | Ticket |
|---|---|---|
| `ng serve` env exports | `ng-env.zsh` | #84 |
| Idle LSP stop: LSP in tmux sessions left 30+ min stops (not the `ng serve` session), comes back on return | `lsp-idle`, `lsp-idle.plist`, `tmux.conf` | #83 |

## Install

1. `~/.zshrc`: add `source ~/.config/memory/ng-env.zsh`

2. `~/.config/tmux/tmux.conf`: add `source-file ~/.config/memory/tmux.conf`, then `tmux source-file ~/.config/tmux/tmux.conf`
3. `cp ~/.config/memory/lsp-idle.plist ~/Library/LaunchAgents/ && launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/lsp-idle.plist` (a copy, not a symlink: launchd may skip a symlinked plist, and only plists in `~/Library/LaunchAgents` come back after a reboot)

## Undo

1. `~/.zshrc`: remove the `source ~/.config/memory/ng-env.zsh` line.
2. `~/.config/tmux/tmux.conf`: remove the `source-file ~/.config/memory/tmux.conf` line, then `tmux set-hook -gu 'client-session-changed[83]'`
3. `launchctl bootout gui/$(id -u)/lsp-idle && rm ~/Library/LaunchAgents/lsp-idle.plist`
