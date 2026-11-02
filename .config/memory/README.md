# memory

Keeps `ng serve` fast under macOS memory pressure without rebooting. Spec: MichalSzczepanskii/ksdo-claude-setup#79.

Everything lives in this folder (live at `~/.config/memory` through the `~/.config` symlink). Tests: `bats tests/memory`.

## Pieces

| Piece | File | Ticket |
|---|---|---|
| `ng serve` env exports | `ng-env.zsh` | #84 |
| `memtop` report (read-only) | `memtop` | #80 |

## Install

1. `~/.zshrc`: add `source ~/.config/memory/ng-env.zsh`
2. `ln -s ~/.config/memory/memtop ~/.local/bin/memtop`

## Undo

1. `~/.zshrc`: remove the `source ~/.config/memory/ng-env.zsh` line.
2. `rm ~/.local/bin/memtop`
