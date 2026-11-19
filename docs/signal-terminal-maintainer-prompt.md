# Incorporate the Ghostty and tmux findings into Signal

You maintain the Meister / Continuum — Signal design system. Update the terminal adoption guide, examples and regression checks using the findings below. Give adopters a reproducible answer to two questions. How should a prompt or status line identify the active item? How can a user scan a directory listing when the emulator enforces minimum contrast?

Work in the Signal source repository. Start with `terminal/README.md`, `guides/adoption.md` and `tokens/meister.tokens.json`. Signal 3.0.0 gives application renderers control of their own cells and gives the terminal owner control of ANSI colours. Keep that ownership explicit. Document the palette below as an opt-in Ghostty light profile. Keep the existing browser focus colours, syntax themes, dark palette and public role names compatible. This extends the [existing Signal maintainer handoff](https://github.com/cityhunteur/skills/blob/2d8b9c4c5986889371385fc6901e1c6b5aeb1964/docs/visual-system/SIGNAL-MAINTAINER-HANDOFF.md).

## What the user settled on

- **tmux.** On the light canvas (`#ECEFF4`), put a compact charcoal fill (`#646464`) behind the active window number only. Use canvas-coloured digits with one space of padding on each side. Reset the style before the window name. All names use charcoal on the normal canvas. A split window shows its focused pane as `2.1`. Give inactive numbers the same spacing so switching windows keeps the names aligned. The full-tab tint, underline and filled window name were tried and superseded.
- **Starship.** Render `❯` and the vi normal-mode `❮` in charcoal directly on the light canvas. The user explicitly removed the fill behind the arrow. Keep the `✘` failure cue. Directory, branch and tool text also sit on the canvas. Apply this treatment to comparable labels such as the Helix status line and K9s command prompt. Preserve the distinction between command text, code syntax, warnings and errors.
- **Dark mode and typography.** The reference keeps its ice-cyan `#88D8DE` prompt and active-window marker on `#2E3440`. Preserve PragmataPro Mono Liga, ligatures and cell geometry. The reusable guidance is to give a small marker enough emphasis to locate focus and reserve stronger hues for information people scan.

## Why the first listing fix failed

GNU `ls` emitted distinct SGR colour codes. The live tmux capture showed `34` on a directory, `35` on a symlink and `33` on Markdown. A fresh-shell test therefore passed. In Ghostty 1.4.0 on macOS, the same names appeared black on screen. The original blue, violet and ochre had contrast ratios of approximately 2.34:1, 2.46:1 and 2.04:1 on the actual light canvas. Ghostty was configured with `minimum-contrast = 4.5`. Reloading a deeper palette made the hues visible. The user then asked for stronger saturation so file types were easier to pick out.

Use these final values for the reference specimen. Ratios are calculated against `#ECEFF4`.

| ANSI slot | SGR | Listing use | Light foreground | Contrast |
| ---: | ---: | --- | --- | ---: |
| 1 | 31 | Broken link and missing target | `#AE2547` | 5.77:1 |
| 2 | 32 | Executable | `#19613B` | 6.47:1 |
| 3 | 33 | Markdown and named pipe | `#854900` | 6.18:1 |
| 4 | 34 | Directory | `#1653A6` | 6.46:1 |
| 5 | 35 | Symlink | `#77349B` | 6.63:1 |
| 6 | 36 | Socket | `#00626B` | 6.16:1 |

Use the same file-type mapping for `ls`, `ll` and zsh completion. Honour a user-supplied `~/.dir_colors`. Keep ordinary files, permissions, sizes and dates on the terminal defaults. Document that overriding these six emulator slots also changes other commands that use them. The application-level Signal adapter should continue to respect the host palette and its existing plain-text and colour-capability fallbacks.

## How to prove the change

1. **Exercise a real listing.** Run the fixture below in interactive zsh on macOS. The subshell supplies the reference mapping for this sample. Compare `ll` with the GNU command that it invokes. Check that the symlink name is violet while its directory target is blue, and that both ends of the broken link are red. Then run `ll "$listing_dir"` outside the subshell to check the installed shell configuration.

   ```zsh
   listing_dir=$(mktemp -d)
   (
     cd "$listing_dir" || exit 1
     export LS_COLORS='di=34:ln=35:ex=32:or=31:mi=31:pi=33:so=36:bd=33:cd=33:su=31:sg=33:tw=34:ow=33:st=34:*.md=33'
     mkdir cmd docs
     ln -s cmd artifact
     ln -s missing broken
     touch AGENTS.md notes run
     chmod +x run
     ll
     gls --color=always -gGh --group-directories-first
   )
   ```

2. **Check the whole rendering path.** Record the effective `LS_COLORS`, the colour codes at representative filenames in `tmux capture-pane -ep`, and the background, ANSI slots and contrast setting from `ghostty +show-config`. Run `ghostty +validate-config`. Inspect the same fixture in a visible, focused Ghostty window through tmux. Keep a cropped screenshot and the measured contrast ratios. Require at least 4.5:1 for each of the six foregrounds on the actual light canvas. The 5.77:1 minimum above describes this particular palette.
3. **Exercise focus and appearance changes.** Check a single-pane window, a split window, pane selection and mouse clicks on active and inactive tabs. Use lowercase hex in tmux profiles because tmux can expand uppercase `#F` and `#D` as format aliases and break clickable ranges. Render the Starship success, failure and vi prompts. Switch light → dark → light and inspect a fresh shell and an existing session. Check the palette Starship actually loaded. During adoption, its installed copy still selected dark while macOS and tmux reported light. Preserve local prompt settings when refreshing that copy.
4. **Report what was observed.** Seven downstream tests passed, and the final listing was inspected in Ghostty through tmux. Helix and K9s were checked through their installed theme files. Identify the host, versions, appearance, checks run and any interaction still awaiting visual inspection.

## Deliverable

Return a reviewable change to the source guide, an opt-in terminal profile or copyable configuration, a representative listing and prompt example, and a regression check covering the six resolved colours. Use the existing generation and verification commands in `guides/adoption.md` for any affected generated files. Include the visual evidence and the impact on other ANSI consumers in the review summary.

The downstream reference is the **19 November 2026 working tree** of `cityhunteur/dotfiles`, based on `7407eef`. The final palette and prompt refinements were local edits. The relevant paths are `.config/ghostty/themes/signal-light`, `.config/tmux/signal-light.conf`, `.config/starship.toml`, `.zshrc`, `tests/test_terminal_appearance.py` and `tests/test_tmux_status.py`. The values and fixture above are sufficient to reproduce the findings in a separate checkout.
