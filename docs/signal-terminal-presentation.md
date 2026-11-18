# Signal terminal presentation

Ghostty, tmux, Starship, Helix and K9s follow macOS appearance. The dark
canvas is Nord blue-black and the light canvas is Nord blue-grey. Focus and
action markers use ice cyan in dark mode and muted teal in light mode.

## Appearance switching

| Tool | Source and behaviour |
| --- | --- |
| Ghostty | `.config/ghostty/config` selects `signal-light` and `signal-dark` using Ghostty’s native system theme pair. |
| tmux | `.tmux.conf` sources the matching profile on startup, attach and terminal theme reports. |
| Starship | The appearance listener selects the active palette in the installed `starship.toml`. The shell picks it up when it renders the next prompt. |
| Helix | The `signal` theme inherits `nord_light` or `nord`. The listener updates the theme file and requests Helix’s native config reload. |
| K9s | The `signal` skin uses the installed Nord status and YAML colours. K9s watches the active skin file with `ui.reactive` enabled. |

The per-user LaunchAgent listens for macOS appearance notifications. It applies
the current appearance at login and writes changed files atomically. Its
configuration sources are in this dotfiles checkout. Starship’s installed
config is a regular file so changing its palette leaves the repository template
clean and preserves local prompt settings.

`init.sh` installs the five tool configurations. To rebuild just the appearance
listener and enable the K9s skin, run `scripts/install-terminal-appearance`.
The listener runs as `com.cityhunteur.terminal-appearance`. K9s loads the
global skin unless an explicit context skin or `K9S_SKIN` overrides it.

| Role | Light | Dark |
| --- | --- | --- |
| Terminal/status canvas | `#E5E9F0` | `#2E3440` |
| Terminal UI text and cursor | `#171717` | `#F2F2F2` |
| Prompt, active-window and prefix markers | `#336F78` | `#88D8DE` |
| Starship primary text | `#4C566A` | `#F2F2F2` |
| Starship divider | `#A6AFBC` | `#8A8A8A` |
| Metadata | `#646464` | `#A0A0A0` |
| Selected status fill | Same as canvas | Same as canvas |
| Boundary over Nord | `#858585` | `#8A8A8A` |
| Native text-selection fill/ink | `#AEBED1` / `#2E3440` | `#43546A` / `#ECEFF4` |

Ice cyan in dark mode and muted teal in light mode mark the Starship prompt,
the active window’s `▸` and the tmux prefix `^A`. Window names, the cursor,
the focused-pane border and pane labels use neutral ink.
Native text selection retains a readable paired treatment for copying text.

The stored Nord ANSI slots and source foreground/background mappings are intact.
Font size, features, cell geometry, keys, plugins, prompt modules, timeouts and
language detectors are preserved. PragmataPro Mono Liga remains configured at
the user's existing size. Glyph candidates do not claim native font validation.

## Mouse-click regression

Uppercase tmux hex literals caused a formatting regression. During
`#{E:window-status-style}` expansion, `#F` inside `#FAFAFA` becomes window flags,
turning the background into `AFAFA` or `*AFAFA`. Invalid styles lose the inactive
window's mouse range. `#D` is another alias to avoid in colour literals.

Tmux colours are therefore lowercase. The original click bindings are retained.
The failure was reproduced with a full status line on the live server's tmux 3.8
version, then corrected. `tests/test_tmux_status.py` checks attached-client
theme reports, expanded styles,
marker colours, absence of selected-tab fills and real SGR mouse clicks
through an isolated client in both profiles. It passes with tmux 3.8 and 3.6a:

```sh
python3 -m unittest discover -s tests -v
```

## Installation and checks

Ghostty’s active configuration lives under
`~/Library/Application Support/com.mitchellh.ghostty/`. The custom themes
live under `~/.config/ghostty/themes/`. Check the resolved canvas with
`ghostty +show-config` and compare it with
`tmux display-message -p '#{client_theme} #{@canvas} #{@accent}'`.

Backups and operation manifests are under `~/.local/share/terminal-backups/`:

- `signal-3.0.0-20261118T142504Z/`: original source/config pairs.
- `tmux-status-click-20261118T143943Z/`: click investigation.
- `blue-black-20261118T145623Z/`: fixed-dark appearance change.
- `signal-names-monochrome-*`: Signal naming and monochrome action change.
- `system-appearance-*`: the five-tool system appearance rollout.

A rename initially left Ghostty's physical live config pointing at its former
filename. The live reference was corrected to `signal-dark`; the main config
and both themes subsequently validated and reloaded successfully.

The computer-use safety policy blocked native Ghostty click inspection. The
mouse checks exercise actual tmux clients through PTYs without controlling the
live GUI. Physical font fallback/shaping and display quality remain unverified.
No user sessions or processes were restarted.

References: [Ghostty theme configuration](https://ghostty.org/docs/features/theme),
[Starship palettes](https://starship.rs/config/#prompt), and
[tmux styles and mouse ranges](https://man.openbsd.org/tmux.1).
