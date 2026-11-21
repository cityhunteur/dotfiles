# Signal terminal presentation

Ghostty, tmux, Starship, Helix and K9s follow macOS appearance. The dark
canvas is Nord blue-black and the light canvas is Nord blue-grey. Light-mode
prompt and status text use charcoal on the normal canvas.

## Appearance switching

| Tool | Source and behaviour |
| --- | --- |
| Ghostty | `.config/ghostty/config` selects `signal-light` and `signal-dark` using Ghostty’s native system theme pair. |
| tmux | `.tmux.conf` sources the matching profile on startup, attach and terminal theme reports. |
| Starship | The appearance listener selects the active palette in the installed `starship.toml`. The shell picks it up when it renders the next prompt. |
| Helix | The `signal` theme inherits `nord_light` or `nord`. The listener updates the theme file and requests Helix’s native config reload. |
| K9s | The `signal` skin uses Nord-derived status colours tuned for each appearance. K9s watches the active skin file with `ui.reactive` enabled. |

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
| Terminal/status canvas | `#ECEFF4` | `#2E3440` |
| Terminal cursor | `#171717` | `#F2F2F2` |
| Starship prompt character | `#646464` on the canvas | `#88D8DE` on the canvas |
| tmux prefix marker | `#646464` | `#88D8DE` |
| Starship and tmux primary text | `#646464` | `#F2F2F2` |
| Starship divider | `#A6AFBC` | `#8A8A8A` |
| Metadata | `#646464` | `#A0A0A0` |
| Active tmux tab fill | `#646464` | Same as canvas |
| Boundary over Nord | `#858585` | `#8A8A8A` |
| Native text-selection fill/ink | `#AEBED1` / `#2E3440` | `#43546A` / `#ECEFF4` |

Dark mode marks the active tmux window with an ice-cyan `▸`. In light mode
the active tmux tab (window number, focused pane index when split, and window
name) uses light text on charcoal. The Starship arrow, directory, branch, tool
versions and inactive window names use charcoal on the canvas, as do the Helix
status line and K9s command prompt. Split windows include their focused pane
index, for example `2.1` for window 2, pane 1. Native text selection retains a
readable paired treatment for copying text.

The light canvas is Nord Snow Storm. Helix inherits the Nord Light syntax
assignments with local colour overrides for the gutter, comments, strings,
constants and diagnostics. K9s uses forest for additions, ochre for pending
resources and muted red for errors. Ghostty uses more saturated shades for
standard ANSI colours 1–6 on the light canvas. In `ll`, directories appear
blue, symlinks violet, executables green, Markdown ochre and broken links red.

The appearance listener saves Codex CLI’s native `tui.theme` as `nord` in dark
mode and `github` in light mode, and saves Claude Code’s `theme` as `dark-ansi`
in dark mode and `light-ansi` in light mode so ANSI TUIs (`agy`, Codex and
Claude Code) share Ghostty’s Nord Light and Nord palettes. `signal-light` uses Nord Polar Night `nord1` (`#3B4252`, `Lc +83.7`) for body
text, deep Polar Night (`#232832`, `Lc +92.0`) for `bold-color`, `nord3`
(`#4C566A`, `Lc +76.0`) for muted slot `7`, and APCA-calibrated Nord hue angles
for slots `1` to `6` (`#9C2C37`, `#406024`, `#9A4B26`, `#275895`, `#8D317C`,
`#1B5E72`) on `#ECEFF4`; slot `11` (`SGR 1;33` bold tool verbs such as `Ran`
and `Edited` in `agy`) uses crisp Nord Polar Night `nord0` (`#2E3440`) so tool
summaries stay monochrome while status dots keep colour. `signal-dark` keeps `#2E3440` with `nord4`
body (`#D8DEE9`, `Lc -80.3`) and `nord6` `bold-color` (`#ECEFF4`, `Lc -91.2`),
while lifting Nord slot `8` (`#919CAF`) and Aurora/Frost hues (`#DF8C94`,
`#B5CE9F`, `#EBCB8B`, `#9CB8D6`, `#C9A6C3`, `#9AD0DE`/`#9FCAC9`) above `4.5:1`
for clear dark-mode legibility. Ghostty keeps `font-thicken = true` with
`font-synthetic-style` enabled for Regular-only `PragmataPro Mono Liga` so bold
headings and italic notes remain crisp, with `12` horizontal padding, `2,0`
vertical padding (`window-padding-balance = equal`, leaving
`window-step-resize` off so maximized windows fill the screen), and readable
dim opacity (`0.85` light / `0.72` dark). Any CLI launch reads the
synced theme, including `codex resume`; a running CLI can switch with `/theme`
when idle.

A running Codex session can keep its original command bar background after
macOS switches appearance. On Ghostty clients, tmux maps the two Signal input
fills used by Codex 0.170 (`#E2E5EA` and `#474C56`) to the terminal's default
background. The prompt then shares the surrounding canvas in either mode.
This mapping applies to any tmux cell with either exact background colour.
Ghostty also uses `minimum-contrast = 4.5` for low-contrast text.

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
marker colours, active tab fills, focused pane indices and real SGR mouse clicks
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
