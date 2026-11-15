# Semantic monochrome symbols for tmux session and window names.
#
# One vocabulary drives both the session prefix (tmux_session_symbol) and the
# window renaming prompt (tmux_symbols). Every glyph is single-width and is
# covered by PragmataPro Mono Liga 0.829, so nothing falls back to another
# font. No emoji (Meister / Continuum Glacier: restrained markers only).
#
# Glyphs used by the starship prompt for tools are kept out of this list
# unless the meaning is the same (⎈ = Kubernetes in both places).
#
# Format: "<glyph> <label> <zsh pattern matching the lower-cased name>"
typeset -ga TMUX_SYMBOL_VOCABULARY=(
	"⊙ ocos       (ocos|opencorex|opencoreos)"
	"◫ workspace  (workspace|work|ws)"
	"⌁ code       (hacker|hack*|code*|dev*|lab|sandbox)"
	"◍ review     (review*|qa|audit*)"
	"☰ infra      (stack|infra*|ops|platform*)"
	"⌘ tools      (tools|tooling|utils|bin)"
	"¶ docs       (doc*|notes|wiki|writing|blog*)"
	"◎ app        (app|app-*|ui|web|frontend*)"
	"⌂ home       (home|main|root)"
	"∴ research   (research*|explore*|spike*|study|reading)"
	"¤ finance    (account*|finance*|tax*|invoice*|bank*|money|budget*)"
	"⊛ agents     (bot|bots|agent*|ai|llm*|claude*|codex*)"
	"⌬ bio        (bio*|health*|fitness)"
	"⊞ data       (data*|db|sql|analytics|warehouse)"
	"≋ observe    (log|logs|monitor*|observ*|metrics|alert*)"
	"⊠ security   (sec|security|secret*|auth*|vault)"
	"⟳ delivery   (ci|cd|build*|release*|deploy*|pipeline*)"
	"▤ planning   (plan*|todo*|task*|backlog|roadmap)"
	"◐ design     (design*|figma|ux)"
	"♪ media      (music|media|audio|video|podcast*)"
	"☼ personal   (personal|life|me|journal*)"
	"⁂ scratch    (ad-hoc|adhoc|scratch*|tmp|temp|misc)"
	"⎈ cluster    (k8s|kube*|cluster*)"
	"◌ comms      (chat|comms|mail|email|slack)"
)
typeset -g TMUX_SYMBOL_DEFAULT="○"

# Prints the symbol for a session or window name.
tmux_session_symbol() {
	local name="${1:l}" entry glyph pattern
	for entry in "${TMUX_SYMBOL_VOCABULARY[@]}"; do
		glyph="${entry%% *}"
		pattern="${entry##* }"
		if [[ "$name" == ${~pattern} ]]; then
			print -r -- "$glyph"
			return
		fi
	done
	print -r -- "$TMUX_SYMBOL_DEFAULT"
}

# Prefixes a session with its symbol and asks codex to prefix its windows.
tmux_symbols() {
	local requested_session="${1:-ocos}"
	local session="$requested_session"
	local base_session_name="$requested_session"
	local -a known_session_prefixes=("${TMUX_SYMBOL_DEFAULT}-")
	local entry known_prefix candidate_session
	for entry in "${TMUX_SYMBOL_VOCABULARY[@]}"; do
		known_session_prefixes+=("${entry%% *}-")
	done

	_tmux_symbols_strip_prefix() {
		base_session_name="$1"
		for known_prefix in "${known_session_prefixes[@]}"; do
			if [[ "$base_session_name" == "${known_prefix}"* ]]; then
				base_session_name="${base_session_name#${known_prefix}}"
				break
			fi
		done
	}

	_tmux_symbols_strip_prefix "$requested_session"
	local session_symbol="$(tmux_session_symbol "$base_session_name")"
	local session_prefix="${session_symbol}-"
	local prefixed_session="${session_prefix}${base_session_name}"

	if ! command -v codex >/dev/null 2>&1; then
		echo "codex is not installed or not on PATH"
		return 1
	fi
	if ! command -v tmux >/dev/null 2>&1; then
		echo "tmux is not installed or not on PATH"
		return 1
	fi

	if ! tmux has-session -t "$session" 2>/dev/null; then
		if tmux has-session -t "$prefixed_session" 2>/dev/null; then
			session="$prefixed_session"
		else
			for known_prefix in "${known_session_prefixes[@]}"; do
				candidate_session="${known_prefix}${base_session_name}"
				if tmux has-session -t "$candidate_session" 2>/dev/null; then
					session="$candidate_session"
					break
				fi
			done
		fi

		if [[ "$session" == "$requested_session" ]] && tmux has-session -t "$base_session_name" 2>/dev/null; then
			session="$base_session_name"
		fi

		if ! tmux has-session -t "$session" 2>/dev/null; then
			echo "tmux session '$requested_session' does not exist"
			return 1
		fi
	fi

	_tmux_symbols_strip_prefix "$session"
	session_symbol="$(tmux_session_symbol "$base_session_name")"
	session_prefix="${session_symbol}-"
	prefixed_session="${session_prefix}${base_session_name}"

	if [[ "$session" != "$prefixed_session" ]]; then
		if tmux has-session -t "$prefixed_session" 2>/dev/null; then
			echo "tmux session rename target '$prefixed_session' already exists"
			return 1
		fi
		tmux rename-session -t "$session" "$prefixed_session"
		session="$prefixed_session"
	fi

	local vocabulary="" glyph label pattern
	for entry in "${TMUX_SYMBOL_VOCABULARY[@]}"; do
		glyph="${entry%% *}"
		label="${${entry#* }%% *}"
		pattern="${entry##* }"
		vocabulary+="- ${glyph} ${label}: names matching ${pattern}"$'\n'
	done

	local prompt
	prompt=$(cat <<EOF
Update the tmux session "$session" window names to use minimalist semantic monochrome symbols in front of the names.

Vocabulary (symbol, category, zsh glob patterns for the lower-cased name):
${vocabulary}- ${TMUX_SYMBOL_DEFAULT} anything else

Instructions:
- Inspect the existing tmux windows in session "$session" first.
- Keep the session name "$session" unchanged. It has already been normalized with the minimal symbol prefix "$session_prefix".
- Rename only windows that exist.
- Format each name as "<symbol> <readable name>", preserving the readable name.
- Use the symbol of the first matching category above.
- For a name that matches no pattern, pick the category that fits its meaning; use ${TMUX_SYMBOL_DEFAULT} only when none does.
- Replace any existing leading symbol, including ones not in this vocabulary.
- Use only symbols from this vocabulary. Never use emoji.
- Use tmux commands directly.
- Do not modify files.
- Print a short summary of what changed.
EOF
)

	codex exec \
		--skip-git-repo-check \
		--dangerously-bypass-approvals-and-sandbox \
		--ephemeral \
		-C "$HOME" \
		"$prompt"
}
