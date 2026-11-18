# Signal terminal presentation

Meister / Continuum — Signal 3.0.0, adopted on 18 November 2026 for Ghostty,
tmux, Starship and their existing zsh appearance hook. Signal provides neutral
chrome and blue focus. Installed Nord Light/Nord language colours remain separate.

The source is `cityhunteur/skills/system/signal/tokens/meister.tokens.json`,
version 3.0.0, SHA-256
`5770814bc531bdbb2950549aba1ac3b5ecdb54cbe65824c0be8ebe8b2d08885c`.
Native selection references come from that repository's
`system/nord-reference.json`. The supplier ZIP is preserved without changes in
`cityhunteur/skills/system/signal/`.

## Configuration ownership

| Surface | Canonical files | Treatment |
| --- | --- | --- |
| Ghostty | `.config/ghostty/config`, `.config/ghostty/themes/nord{,-light}-glacier` | Existing Nord palettes/canvas; Signal cursor; stronger neutral native selection |
| tmux | `.tmux.conf`, `.config/tmux/glacier-{light,dark}.conf` | Signal status canvas, selected ink/tint, blue current-window marker and focused-pane border |
| Starship | `.config/starship.toml` | Neutral directory/git/tool metadata, blue prompt character, existing explicit state markers |
| Appearance | `.config/zsh/glacier.zsh` | Existing cached macOS appearance detection and generated light prompt config |
| Symbols | `.config/zsh/tmux-symbols.zsh` | Existing meanings and matching rules; operations uses `≡`; old `☰-` prefixes remain recognised |

The `glacier_*` palette IDs, filenames, cached path and hook function names are
compatibility identifiers. Their active colours now derive from Signal. Keeping
them preserves existing shell hooks and clients. The old handoff document is a
historical record, not the current palette.

| Role | Light | Dark |
| --- | --- | --- |
| Status canvas | `#FAFAFA` | `#111111` |
| Primary ink | `#171717` | `#F2F2F2` |
| Metadata | `#646464` | `#A0A0A0` |
| Focus/action | `#2457E6` | `#7AA2FF` |
| Selected status fill/ink | `#EAF0FF` / `#171717` | `#182B52` / `#F2F2F2` |
| Boundary over Nord | `#858585` | `#8A8A8A` |
| Native text selection fill/ink | `#AEBED1` / `#2E3440` | `#43546A` / `#ECEFF4` |

The tmux status bar owns its Signal canvas. The shell prompt sits on the host's
Nord canvas, so its rails use `nordControlBoundary`. Copy-mode and Ghostty native
selection use the independent neutral pair, which stays distinct on Nord.
No ANSI slot, source foreground/background, font size, font feature, cell geometry,
keybinding, plugin, prompt module, command timeout or language detector changed.
The installed font remains PragmataPro Mono Liga at the configured size.
Glyph comments identify candidates without claiming native font verification.

## Installation and verification

The existing home-directory symlinks and hardlinks are preserved. Ghostty's live
main file is `~/Library/Application Support/com.mitchellh.ghostty/config`; its
custom themes are under `~/.config/ghostty/themes/`. Starship's physical home copy
is kept in sync. Backups of all ten source/config pairs and the original generated
prompt cache are under
`~/.local/share/terminal-backups/signal-3.0.0-20261118T142504Z/`.

Verified with Ghostty 1.4.0, tmux 3.6a and Starship 1.24.2:

- Ghostty's actual validator accepts the live configuration and both theme files.
  Comparisons against the backup confirm all 16 ANSI slots, source foreground/
  background and non-colour main settings are unchanged.
- Both tmux profiles load into an isolated server, with the expected status,
  selected-window and accent values. The main file passes `source-file -n`.
  Applied only the profiles and changed status formats to the live server,
  preserving its sessions, panes, plugins and keys. The attached light client
  resolved the light Signal roles.
- Eight real Starship prompts render without warnings across both palettes,
  40/160 columns, success/failure and insert/vi-command modes. TOML comparisons
  confirm all non-palette module settings are unchanged. The appearance hook
  regenerated the active light cache.
- The edited zsh files pass syntax checks. A stubbed tmux/Codex test confirms
  that `☰-infra` normalises to `≡-infra` while retaining its readable name;
  the test does not rename real sessions or launch Codex.
- Ghostty's native `reload_config` action returned success.

Physical display quality, actual glyph fallback/shaping and mixed light/dark
clients sharing a tmux server remain unverified. Existing client-theme hooks
still select global server styles; this change does not introduce per-client
palettes. No application restart or session termination was needed.

The configuration follows the official [Ghostty theme model](https://ghostty.org/docs/features/theme),
[Starship palette configuration](https://starship.rs/config/#prompt) and
[tmux style and hook interfaces](https://man.openbsd.org/tmux.1). Installed CLI
validators and the actual running tmux version provide the adoption evidence.
