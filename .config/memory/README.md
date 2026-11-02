# memory

Keeps `ng serve` fast under macOS memory pressure without rebooting. Spec: MichalSzczepanskii/ksdo-claude-setup#79.

Everything lives in this folder (live at `~/.config/memory` through the `~/.config` symlink). Tests: `bats tests/memory`.

## Pieces

| Piece | File | Ticket |
|---|---|---|
| `ng serve` env exports | `ng-env.zsh` | #84 |
| tmux status segment: swap, coloured by memory pressure | `tmux-memory`, `tmux.conf` | #81 |

## Install

1. `~/.zshrc`: add `source ~/.config/memory/ng-env.zsh`
2. `~/.config/tmux/tmux.conf`: add `source-file ~/.config/memory/tmux.conf` after the `source-file ~/.config/tmux/tokyonight_night.tmux` line (it appends to the theme's `status-right`, so it must come after it), then `tmux source-file ~/.config/tmux/tmux.conf`

## Undo

1. `~/.zshrc`: remove the `source ~/.config/memory/ng-env.zsh` line.
2. `~/.config/tmux/tmux.conf`: remove the `source-file ~/.config/memory/tmux.conf` line, then `tmux source-file ~/.config/tmux/tmux.conf` (the theme resets `status-right`).
