# Signal terminal presentation

Meister / Continuum — Signal 3.0.0, adopted on 18 November 2026 for Ghostty,
tmux, Starship and their existing zsh hook. The requested appearance is fixed
dark blue/black: a Nord dark canvas, neutral text/chrome, and blue reserved for
highlights, focus and actions. Installed Nord language colours remain separate.

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
| Appearance | `.config/ghostty/config`, `.tmux.conf`, `.config/zsh/glacier.zsh` | Fixed dark Ghostty/tmux; both legacy prompt IDs resolve to dark roles for already-running shells |
| Symbols | `.config/zsh/tmux-symbols.zsh` | Existing meanings and matching rules; operations uses `≡`; old `☰-` prefixes remain recognised |

The `glacier_*` palette IDs, filenames, cached path and hook function names are
compatibility identifiers. Their active colours derive from Signal. Both
Starship IDs now map to the dark palette so already-running OS appearance hooks
and cached config paths remain readable. tmux no longer changes palette with
client/desktop appearance. The light tmux profile is retained and tested.
The old handoff document is historical, not the active colour policy.

| Role | Light | Dark |
| --- | --- | --- |
| Status canvas | `#FAFAFA` | `#2E3440` (matches Nord terminal) |
| Primary ink | `#171717` | `#F2F2F2` |
| Metadata | `#646464` | `#A0A0A0` |
| Focus/action | `#2457E6` | `#7AA2FF` |
| Selected status fill/ink | `#EAF0FF` / `#171717` | `#1B2230` / `#F2F2F2` |
| Boundary over Nord | `#858585` | `#8A8A8A` |
| Native text selection fill/ink | `#AEBED1` / `#2E3440` | `#43546A` / `#ECEFF4` |

The active tmux status bar matches the Nord blue/black canvas. Its subtle
`#1B2230` selected-tab fill is an explicit user override. Neutral labels and a
small blue current-window marker retain readable selection. The shell prompt
also sits on Nord, so its rails use `nordControlBoundary`. Copy-mode and Ghostty native
selection use the independent neutral pair, which stays distinct on Nord.
The stored Nord ANSI slots and source foreground/background mappings are
unchanged. Font size, features, cell geometry, keys, plugins, prompt modules,
timeouts and language detectors are preserved. The selected appearance is dark.
The configured Nord dark theme is selected without changing its ANSI slots.
The installed font remains PragmataPro Mono Liga at the configured size.
Glyph comments identify candidates without claiming native font verification.

## Installation and verification

The existing home-directory symlinks and hardlinks are preserved. Ghostty's live
main file is `~/Library/Application Support/com.mitchellh.ghostty/config`; its
custom themes are under `~/.config/ghostty/themes/`. Starship's physical home copy
is kept in sync. Backups of all ten source/config pairs and the original generated
prompt cache are under
`~/.local/share/terminal-backups/signal-3.0.0-20261118T142504Z/`.

Initially validated with the tmux 3.6a CLI; the live server is 3.8.
Ghostty is 1.4.0 and Starship is 1.24.2. Native checks:

- Ghostty's actual validator accepts the live configuration and both theme files.
  Comparisons against the backup confirm all 16 ANSI slots, source foreground/
  background and non-colour main settings are unchanged.
- Both tmux profiles load into an isolated server, with the expected status,
  selected-window and accent values. The main file passes `source-file -n`.
  Applied only the profiles and changed status formats to the live server,
  preserving its sessions, panes, plugins and keys. The requested fixed dark
  profile is now applied regardless of client appearance.
- Eight real Starship prompts render without warnings across both palettes,
  40/160 columns, success/failure and insert/vi-command modes. TOML comparisons
  confirm all non-palette module settings are unchanged. The appearance hook
  regenerated its compatibility cache using dark palette values.
- The edited zsh files pass syntax checks. A stubbed tmux/Codex test confirms
  that `☰-infra` normalises to `≡-infra` while retaining its readable name;
  the test does not rename real sessions or launch Codex.
- Ghostty's native `reload_config` action returned success.

Physical display quality, actual glyph fallback/shaping and mixed light/dark
clients sharing a tmux server remain unverified. The fixed dark profile is global; per-client palettes are
not introduced.
No application restart or session termination was needed.

## Mouse-click regression and correction

Uppercase tmux hex literals introduced a real formatting regression. In
`#{E:window-status-style}`, tmux expands `#F` inside `#FAFAFA` as window flags,
turning the background into `AFAFA` or `*AFAFA`. Invalid styles then lose the
inactive window's mouse range. The same applies to `#D` pane aliases.

The tmux profiles use lowercase hex literals; RGB values are identical. Native
click bindings remain unchanged. A full-status-line PTY reproduction on tmux 3.8
fails before this correction and switches among inactive tabs afterwards.
`tests/test_tmux_status.py` checks literal format expansion for active/inactive
windows and sends real SGR mouse presses/releases through an isolated tmux client
in both palette profiles. Run it with:

```sh
python3 -m unittest discover -s tests -v
```

The computer-use safety policy blocked native Ghostty click inspection. These
checks exercise the actual tmux mouse protocol without controlling the live GUI.
Separate backups for the click investigation and fixed-dark preference are under
`~/.local/share/terminal-backups/tmux-status-click-20261118T143943Z/` and
`~/.local/share/terminal-backups/blue-black-20261118T145623Z/`.

The configuration follows the official [Ghostty theme model](https://ghostty.org/docs/features/theme),
[Starship palette configuration](https://starship.rs/config/#prompt) and
[tmux style and hook interfaces](https://man.openbsd.org/tmux.1). Installed CLI
validators and the actual running tmux version provide the adoption evidence.
