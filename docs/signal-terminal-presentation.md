# Signal terminal presentation

Meister / Continuum — Signal 3.0.0 terminal configuration, adopted on
18 November 2026. The requested appearance is a dark blue/black canvas,
neutral text, unfilled status tabs and three coloured markers. Nord syntax colours remain separate.

The baseline is `cityhunteur/skills/system/signal/tokens/meister.tokens.json`,
SHA-256 `5770814bc531bdbb2950549aba1ac3b5ecdb54cbe65824c0be8ebe8b2d08885c`.
The host canvas, marker colours and unfilled selection are explicit user
choices. The supplied Signal bundle is retained without modifications.

## Active configuration

| Surface | Canonical source |
| --- | --- |
| Ghostty | `.config/ghostty/config`, `.config/ghostty/themes/signal-dark`, `signal-light` |
| tmux status and pane styles | `.tmux.conf`, `.config/tmux/signal-dark.conf`, `signal-light.conf` |
| Starship | `.config/starship.toml`, palettes `signal_dark` and `signal_light` |
| Shell startup | `.zshrc`, `.config/zsh/signal.zsh` |
| Session/window symbols | `.config/zsh/tmux-symbols.zsh` |

Ghostty selects `signal-dark`; tmux also stays dark regardless of desktop/client
appearance. The light variants remain available and tested. The Signal startup
hook selects the main Starship configuration and retires the previous edition's
selector when sourced in an existing shell. Already-running shells may retain a
previous generated-cache path; its contents are refreshed to the Signal config
until those shells load the renamed startup hook. This is a transition artifact,
not another active theme.

| Role | Light | Dark |
| --- | --- | --- |
| Terminal/status canvas | `#E5E9F0` | `#2E3440` |
| Primary text and cursor | `#171717` | `#F2F2F2` |
| Prompt, active-window and prefix markers | `#17646F` | `#88D8DE` |
| Metadata | `#646464` | `#A0A0A0` |
| Selected status fill | Same as canvas | Same as canvas |
| Boundary over Nord | `#858585` | `#8A8A8A` |
| Native text-selection fill/ink | `#AEBED1` / `#2E3440` | `#43546A` / `#ECEFF4` |

Ice cyan in dark mode and deep teal in light mode mark the Starship prompt,
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
version, then corrected. `tests/test_tmux_status.py` checks expanded styles,
marker colours, absence of selected-tab fills and real SGR mouse clicks
through an isolated client in both profiles. It passes with tmux 3.8 and 3.6a:

```sh
python3 -m unittest discover -s tests -v
```

## Installation and checks

Existing source symlinks and shared directories are preserved. Ghostty's live
main config is under `~/Library/Application Support/com.mitchellh.ghostty/`;
its custom themes are under `~/.config/ghostty/themes/`. Main configuration and
both Signal themes pass Ghostty 1.4.0 validation. Reload occurs after validation.
Starship 1.24.2 renders both palettes; the edited shell files pass syntax checks.
The running tmux status uses the installed Signal profile.

Backups and operation manifests are under `~/.local/share/terminal-backups/`:

- `signal-3.0.0-20261118T142504Z/`: original source/config pairs.
- `tmux-status-click-20261118T143943Z/`: click investigation.
- `blue-black-20261118T145623Z/`: fixed-dark appearance change.
- `signal-names-monochrome-*`: Signal naming and monochrome action change.

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
