# Handoff: terminal chrome rules for Meister / Continuum Glacier

**For:** the agent maintaining the Meister / Continuum Glacier bundle (v2.0.0).
**From:** an adoption of Glacier in a real terminal setup (Ghostty 1.4.0, tmux 3.8, Starship, zsh, PragmataPro Mono Liga 0.829), on branch `refactor/terminal-visuals` of `cityhunteur/dotfiles`. The commits are `79fa14a`, `fd84bb5` and `1077908`.
**Date:** 15 November 2026.

## Purpose

The bundle's terminal contract (`terminal/README.md`, `terminal/role-map.json`) covers terminal *content*: an `explain` viewer, syntax and source evidence. It says nothing about terminal *chrome*: the multiplexer status line, the shell prompt, the cursor and the symbols used as labels. This adoption had to decide those things. Each decision below is something the bundle should take on, with the reason and the evidence. Where the bundle's own values failed on a real terminal canvas, that is listed as a defect to fix, not a local preference.

Treat this file as input, not as an instruction to copy hex values. The canonical tokens stay the source of truth. Add roles to `terminal/role-map.json` and to the tokens, regenerate with `python3 terminal/generate.py`, and check with `--check` and `terminal/smoke.py`.

## Summary of proposed bundle changes

| # | Change | Kind |
|---|---|---|
| 1 | Add a "neutral chrome, one accent" rule for status lines and prompts | New rule |
| 2 | Add chrome roles to the role map | New roles |
| 3 | Do not use `borderHairline` or `signalTint` on the terminal canvas without a contrast check | Defect |
| 4 | Show state with markers, not colour, in chrome | Extend the existing rule |
| 5 | Add a glyph vocabulary with a font-coverage gate | New registry |
| 6 | Document how chrome follows the light/dark appearance | New guidance |
| 7 | Clarify the cursor policy | Clarification |
| 8 | Record Nord Light port differences | Verification note |

---

## 1. Rule: chrome is neutral, the accent is the only colour

**Change.** Add to `DESIGN.md` (Surfaces and colour) and to `guides/other-artefacts.md` (Terminal):

> Terminal chrome (status lines, prompts, tab bars) uses neutral ink only: `fgPrimary` for values, `fgMuted` for metadata and grey for rules. The frost accent appears once, on the element that marks *where you are*: the current window in a status line and the prompt character in a shell prompt. Status (success, warning, failure) uses markers in neutral ink, not hue.

**Rationale.**
- **The user's direction.** After seeing the first pass, the user asked for the status line to be "grey black (or glacier equivalent) except for accent", and then the same for the prompt. The first pass had followed the bundle literally, using `fgLink` for paths and `fgSuccess` / `fgWarn` / `fgFault` for git state. The result looked too colourful for always-visible chrome.
- **It follows from the bundle's principles.** DESIGN.md already says "Use colour when it explains an action, a relationship or an exception" and calls the accent "a focal component or priority". Chrome is on screen all the time, so if it carries colour, every screen has several focal points. One accent on the current location keeps the focus where the work is.
- **It keeps lexical colour meaningful.** Terminal content (`ls`, `git diff`, compiler output) already uses ANSI hues for its own meanings. Neutral chrome stops those hues from competing with the chrome's.

**Evidence.**

| Surface | Neutral parts | Accent |
|---|---|---|
| tmux status line | `└ ───` rules; `⟪⟫ ⟨⟩ ⌥`, host and time; session and branch | Current window: `▸ #I name` in bold `fgLink` |
| Starship prompt | `┌ └ ─` rails; brackets and markers; directory and branch | `❯` / `❮` in bold `signalAccent` |

## 2. New roles: chrome

**Change.** Add these roles to `terminal/role-map.json` and to the generated profiles:

| Role | Token | Use |
|---|---|---|
| `chrome_rule` | `borderControl` | Rules and rails: `─`, `┌`, `└` in status lines and prompts |
| `chrome_meta` | `fgMuted` | Brackets, markers, host, time, tool versions, inactive tabs |
| `chrome_value` | `fgPrimary` | Session name, directory, branch |
| `chrome_value_strong` | `fgPrimary` + bold | Directory, session name, blocking states (git conflict, failure marker `✘`) |
| `chrome_current` | `fgLink` + bold | Current window / tab label, with a `▸` marker |
| `chrome_prompt` | `signalAccent` + bold | Prompt character |
| `chrome_indicator` | `fgLink` on `signalTint` | Transient mode indicators (tmux prefix `^A`, copy mode, messages) |
| `pane_border` | `borderHairline` | Inactive pane separation (decorative, may be quiet) |
| `pane_border_active` | `signalAccent` | Focused pane outline (same as `focus_border`) |

**Rationale.**
- **One shared mapping.** Without named roles, every adopter maps chrome to tokens on their own, and the results drift. In this adoption, the tmux and Starship mappings had to be kept in step by hand.
- **The rule grey is new.** `chrome_rule` uses `borderControl` (light `#748298`, dark `#8999AD`), not `borderHairline`. Section 3 explains why. In the bundle, `borderControl` already means "meaningful boundary", and the prompt rails do carry structure: they join the two prompt lines and separate the commands in the scrollback.

## 3. Defect: `borderHairline` and `signalTint` disappear on the terminal canvas

**Change.** In `terminal/README.md` and in the generated profiles' `border` role, record that these tokens were tuned for the browser stage (`bgStage` `#F4F6FA` / `#242A35`), not for the terminal canvas (`#E5E9F0` / `#2E3440`). Either:
- (a) add terminal-specific values that reach at least 1.5:1 on the canvas for decorative rules, or
- (b) state plainly that `border` may be invisible on the terminal and must not carry structure.

Also add a contrast check against `code.terminalBackground` to `smoke.py` or `contrast-report.json`. Today the report only checks against browser surfaces.

**Rationale and evidence.** Measured WCAG contrast on the installed Ghostty Nord themes:

| Token | Light on `#E5E9F0` | Dark on `#2E3440` | Effect |
|---|---|---|---|
| `borderHairline` (`#DDE4EE` / `#374152`) | **1.05** | **1.21** | Prompt rails and fill vanish |
| `signalTint` as selection background (`#E2EFF5` / `#304958`) | **1.04** | 1.32 | In light mode, only the selection's text colour shows the selection |
| `borderControl` (`#748298` / `#8999AD`) | 3.2 | 4.3 | Visible, and still below `fgMuted` |
| `fgMuted` | 4.71 | 6.14 | — |
| `fgPrimary` | 10.26 | 10.84 | — |
| `fgLink` | 4.91 | 6.24 | — |
| `signalAccent` | 4.63 | 6.24 | — |
| `fgLink` on `signalTint` | 5.09 | 4.73 | Prefix indicator stays readable |

The Ghostty fragment `terminal/ghostty/meister-continuum-light` pairs `background = #E5E9F0` with `selection-background = #E2EFF5`. On that same canvas the selection fill is invisible. The bundle ships this pair, so the bundle should fix it, perhaps with a terminal-specific tint.

## 4. Markers carry state; colour never does alone

**Change.** Extend the existing rule ("Colour alone must not indicate selection, source status or failure") to chrome, with these concrete markers:

| State | Marker | Ink |
|---|---|---|
| Current window | `▸` before the label. The inactive format has two spaces in its place, so the labels don't shift. | `chrome_current` |
| Last command failed | `✘` before the prompt character | `chrome_value_strong` |
| Vi normal mode | `❮` instead of `❯` | `chrome_prompt` |
| Git: modified, staged, untracked, deleted, renamed, stashed | `! + ? × » *` | `chrome_meta` |
| Git: conflict | `~` | `chrome_value_strong` |
| Git: ahead, behind, diverged | `⇡n ⇣n` | `chrome_meta` |
| Slow command (2 s or more) | `⧖ 3s` | `chrome_meta` |
| Background jobs | `⚙ n` | `chrome_meta` |

**Rationale.** Once chrome is neutral (rule 1), the marker is the only signal, so each state needs a distinct glyph. The first pass showed success and failure as the same `❯` in two colours, which breaks the bundle's own accessibility guide (`guides/accessibility-and-review.md`: "Never encode success, failure … solely by hue"). Keeping the label width the same in both formats follows the bundle's "stable geometry" requirement.

## 5. Glyph vocabulary with a coverage gate

**Change.** Add a glyph registry (for example `terminal/glyphs.json`) with two sets, and a check that every glyph exists in the terminal font.

**Rules.**
1. Every glyph must be in the user's `fontTerminal` (PragmataPro Mono Liga). Check the font's character map; don't trust how a glyph looks on screen.
2. Single-width only: no East Asian Wide or Fullwidth characters (`⌚` and `⌛` are excluded) and no emoji.
3. No glyph means two things across the sets. The one exception is when the meaning is the same: `⎈` means Kubernetes in both.
4. Prefer geometric and typographic symbols to pictograms.

**Rationale.**
- **Fallback fonts break the look.** A missing glyph is drawn from another font with a different weight and size. The original setup used five glyphs PragmataPro lacks: U+E725 (Nerd Font branch), `✕`, `⬢`, `✎` and `🧭`.
- **Collisions confuse.** `⊙` meant both Rust and the `ocos` session; `◉` meant both Java and the `bots` window.
- **Font coverage is fixed.** PragmataPro 0.829 lacks `✕ ⬢ ⬡ ✎ ✐ ✍ ✉ ⚿ ✱ ⚕ ⚗ ⧉ ✦ ❖ ⚖ ⛭ ⛁`. A registry checked once against the font stops the next adopter from repeating the trial and error.

**Session and window vocabulary** (24 categories plus a default; the name is matched case-insensitively and the first match wins):

| Glyph | Category | Glyph | Category | Glyph | Category |
|---|---|---|---|---|---|
| `⊙` | ocos (project) | `◫` | workspace | `⌁` | code / dev / lab |
| `◍` | review / qa | `☰` | infra / ops | `⌘` | tools |
| `¶` | docs / notes | `◎` | app / web | `⌂` | home |
| `∴` | research | `¤` | finance | `⊛` | agents / ai |
| `⌬` | bio / health | `⊞` | data | `≋` | logs / monitoring |
| `⊠` | security | `⟳` | ci / build / deploy | `▤` | planning |
| `◐` | design | `♪` | media | `☼` | personal |
| `⁂` | scratch / ad-hoc | `⎈` | kubernetes | `◌` | chat / mail |
| `○` | default | | | | |

**Prompt tool vocabulary:** `⏣` node, `◭` bun, `◮` deno, `◆` python, `▦` go, `⚒` rust, `◉` java, `⟁` swift, `⋈` zig, `⊕` C, `☾` Lua, `◊` ruby, `△` terraform, `◈` docker, `⌖` helm, `⎈` kubernetes, `▲` aws, `⧖` duration, `⚙` jobs.
**Chrome punctuation:** `┌ └ ─` rails, `⟪ ⟫` primary context (session, directory), `⟨ ⟩` secondary context, `⌥` branch, `▸` current, `❯ ❮` prompt, `✘` failure.

A semantic glyph fits the bundle's terminal advice ("restrained markers") better than coloured badges, and it still works with no colour at all.

## 6. Chrome follows the light/dark appearance

**Change.** Add an adoption note to `terminal/README.md` §3. "`--theme` selects colours; it does not detect the host's appearance" is true of the adapter, but chrome has to switch live. Document the patterns that worked:

| Tool | Mechanism | Notes |
|---|---|---|
| tmux 3.6+ | `client-light-theme` / `client-dark-theme` hooks source a per-theme role file. An `if -F '#{==:#{client_theme},light}'` handles the initial load. | Status formats read roles as `#{@role}`. Hex in user options needs no escaping. Style options (`pane-border-style`, `mode-style`, `message-style`) can't read formats, so the role file sets them directly. |
| Starship | One config with `palettes.glacier_dark` and `palettes.glacier_light`. A zsh `precmd` hook sets `STARSHIP_CONFIG` to a cached copy with `palette = "glacier_light"` when macOS is in light mode. | It reads the appearance at most every 5 seconds. `[palettes.*]` tables must come last in the TOML, or they swallow the top-level keys that follow them (this caused a real bug here). |
| Ghostty | `theme = light:<copy>,dark:<copy>` | See section 7. |

**Rationale.** Hex-coded chrome tuned for one theme failed badly in the other. The original Nord prompt measured 1.3–1.7:1 for accents in light mode and 1.2:1 for rules in dark mode. ANSI names alone don't fix this, because Glacier roles match no Nord palette slot. Per-theme truecolor roles are the only faithful mapping, and the bundle should say so.

**Pitfall to document:** the default `starship.toml` selects `glacier_dark`. Any shell that hasn't loaded the hook, including shells started before installation, shows the dark palette on a light background. Adopters must restart open shells (`exec zsh`).

## 7. Cursor policy

**Change.** State in `terminal/README.md`:
- Cursor and selection colours come from copies of the installed Nord / Nord Light themes, with only the fragment's cursor and selection values merged in. Do not set one global `cursor-color`.
- Choose one cursor shape and blink setting for everywhere. This adoption used a steady bar (`cursor-style = bar`, `cursor-style-blink = false`), keeping the shell integration's block cursor in vi normal mode. tmux's cursor reset should restore the terminal default (`Se=\E[0 q`) rather than hard-code a shape.

**Rationale.**
- **Theme copies keep the palette intact.** This is what the bundle already asks for in §3. A single cursor colour can't meet the bundle's per-theme `signalAccent` values (`#286F89` / `#88C0D0`).
- **Before:** the shape changed with context. The prompt had a blinking bar, running commands had a block, and tmux's reset gave a steady bar. Nothing in the bundle addresses this today.

## 8. Verification note: Nord Light port differences

**Change.** In `code/README.md`, record that Ghostty 1.4.0's bundled "Nord Light" has foreground `#414858`. The bundle's fragment and profiles assume `#2E3440`. The ANSI palette also differs from Nord: green `#96b17f`, yellow `#c5a565`, bright-black `#4c566a`. The adoption kept the installed foreground, as the bundle instructs.

**Rationale.** The bundle says "Nord Light ports vary, so the exact installed port must be checked". This is the first recorded check, and the bundle's light canvas values should list it.

---

## Not changed by the adoption (left for the bundle owner)

- **Font features:** `font-feature = calt, lima, dig, ss20` stayed in the Ghostty config. These enable features rather than disable them, so the "keep normal ligature shaping" rule isn't broken. But the bundle's "leave font-feature unset unless needed" wording should say whether enabling stylistic sets is acceptable.
- **Bold:** only the Regular weight of PragmataPro is installed, so Ghostty fakes bold. If the bundle's bold roles depend on a real Bold, the font contract should say so.

## How to verify after incorporating

1. `python3 terminal/generate.py --check` and `python3 terminal/smoke.py` pass.
2. The contrast report includes the chrome roles against `code.terminalBackground` in both themes. `chrome_rule` reaches at least 3:1 (light) and 4:1 (dark), and every text role reaches at least 4.5:1.
3. Every glyph in the registry passes the font-coverage check against the local PragmataPro, and none is wide.
4. Look at it in a real terminal, in both appearances. The bundle's checks don't cover native rendering; its own README says so.
