# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

# -----------------------------------------------------------------------------
# Secrets (API keys, tokens) - loaded from separate file
# -----------------------------------------------------------------------------
[ -f ~/.secrets ] && source ~/.secrets

# -----------------------------------------------------------------------------
# PATH Configuration
# -----------------------------------------------------------------------------
# Base PATH components
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1

# Development tools
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# -----------------------------------------------------------------------------
# Completion system (cached)
# -----------------------------------------------------------------------------
# oh-my-zsh was removed for speed (it ran an uncached compinit + compaudit +
# a `git rev-parse` on every startup). We keep ~/.oh-my-zsh only as a library
# of plugin files, sourced directly below. See ~/.config/zsh-speedup-backup/
# for the previous config.
#
# Put extra completions on fpath BEFORE compinit. Hardcode the Homebrew prefix
# so we don't fork `brew --prefix` at every startup.
fpath=(/opt/homebrew/share/zsh-completions $fpath)

# Run a full compinit at most once per day; otherwise trust the cached dump (-C).
autoload -Uz compinit
if [[ -n $HOME/.zcompdump(#qNmh-24) ]]; then
	compinit -C
else
	compinit
fi

# bash-style completions (used by terraform + aws-sso further down).
autoload -U +X bashcompinit && bashcompinit

# History (previously inherited from oh-my-zsh lib/history.zsh).
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history hist_expire_dups_first hist_ignore_dups \
	hist_ignore_space hist_verify inc_append_history share_history

# Completion UX (previously inherited from oh-my-zsh lib/completion.zsh).
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
# ANSI colours follow the terminal theme when macOS changes appearance.
if [[ -r ~/.dir_colors ]] && (( $+commands[gdircolors] )); then
	eval "$(gdircolors -b ~/.dir_colors)"
else
	export LS_COLORS='di=34:ln=35:ex=32:or=31:mi=31:pi=33:so=36:bd=33:cd=33:su=31:sg=33:tw=34:ow=33:st=34:*.md=33'
fi
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
zstyle ':completion:*:descriptions' format '%B%d%b'

# -----------------------------------------------------------------------------
# Plugins (sourced directly — no framework, no plugin manager)
# -----------------------------------------------------------------------------
ZSH="$HOME/.oh-my-zsh"            # plugin library location (framework not loaded)
autoload -Uz is-at-least         # used by the git plugin
source "$ZSH/lib/key-bindings.zsh"   # Home/End/word-nav/history-search bindings

for _plugin in \
	"$ZSH/plugins/git/git.plugin.zsh" \
	"$ZSH/plugins/macos/macos.plugin.zsh" \
	"$ZSH/plugins/tmuxinator/tmuxinator.plugin.zsh" \
	"$ZSH/plugins/vi-mode/vi-mode.plugin.zsh" \
	"$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
do
	[ -r "$_plugin" ] && source "$_plugin"
done
unset _plugin
# NOTE: zsh-syntax-highlighting is sourced at the very END of this file (required).
# Dropped vs. the old oh-my-zsh plugin list: `autojump` (zoxide is loaded below
# and replaces it) and `fzf` (replaced by `fzf --zsh` further down).

# -----------------------------------------------------------------------------
# Eval cache — avoid forking a tool to generate its init script on every start
# -----------------------------------------------------------------------------
# `eval "$(tool init zsh)"` forks `tool` at every startup just to print a static
# script (mise ~80ms, atuin ~30ms, direnv ~20ms). The output only changes when
# the tool binary itself changes, so we cache it and source the file instead.
# Cache auto-busts when the tool binary is newer than the cached script.
# To force a refresh: rm -rf ~/.zsh/cache/evalcache
_evalcache() {
	local cmd="$*"
	local file="$HOME/.zsh/cache/evalcache/${cmd//[^A-Za-z0-9]/_}.zsh"
	local bin; bin=$(command -v "$1" 2>/dev/null)
	if [[ ! -s $file || ( -n $bin && $bin -nt $file ) ]]; then
		mkdir -p "${file:h}"
		"$@" > "$file" 2>/dev/null
	fi
	source "$file"
}

# Starship is initialized at the end of the file after all other integrations

# -----------------------------------------------------------------------------
# Shell Configuration
# -----------------------------------------------------------------------------
# Editor configuration
export EDITOR='hx'

# Git configuration
export GIT_TERMINAL_PROMPT=1
export GPG_TTY=$(tty)

# Shell key bindings (vi mode; re-asserted after the plugins above)
bindkey -v

# Completion system + bashcompinit are initialized once, cached, near the top.
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
# System utilities
alias date=gdate
alias ll="gls --color=always -gGh --group-directories-first"
alias ls="gls --color=always -G"
alias vi="nvim"
alias vim="nvim"
alias pip="pip3"

# Directory navigation (previously from oh-my-zsh lib/directories.zsh)
alias j='z'          # zoxide jump (function defined by `zoxide init` below)
alias -- -='cd -'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Configuration shortcuts
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"
alias zshconfig="$EDITOR ~/.zshrc"

# iA Apps
alias ia='open -a "iA Writer"'
alias iap='open -a "iA Presenter"'

# Development tools
alias k="kubectl"
alias kc="kubectx"
alias kn="kubens"
alias rgf='rg --files | rg'
alias tf='terraform'

# Temporal workflow
alias t='temporal'
alias ts='temporal server start-dev'
alias tsbg='temporal server start-dev &> /dev/null & disown'
alias tsdb='temporal server start-dev --db-filename ~/temporal.db'
alias tw='temporal workflow'

# Custom functions
function lk {
		cd "$(walk "$@")"
}

# tmux session/window symbols: tmux_session_symbol, tmux_symbols
[[ -r ~/.config/zsh/tmux-symbols.zsh ]] && source ~/.config/zsh/tmux-symbols.zsh

# k9s theme switching
k9s_theme_dark() {
    sed -i '' 's/skin: .*/skin: nord/' "$HOME/Library/Application Support/k9s/config.yaml"
    sed -i '' 's/skin: .*/skin: nord/' "$HOME/.config/k9s/config.yaml" 2>/dev/null
    echo "k9s theme set to dark (nord)"
}

k9s_theme_light() {
    sed -i '' 's/skin: .*/skin: nord-light/' "$HOME/Library/Application Support/k9s/config.yaml"
    sed -i '' 's/skin: .*/skin: nord-light/' "$HOME/.config/k9s/config.yaml" 2>/dev/null
    echo "k9s theme set to light (nord-light)"
}

# -----------------------------------------------------------------------------
# Programming Language Environments
# -----------------------------------------------------------------------------

# Go Configuration
export GOPATH=/Volumes/Workspace
export GOBIN="$GOPATH"/bin
export PATH="$PATH:${GOPATH//://bin:}/bin"

# Python Configuration
export PATH="$PATH:$HOME/.local/bin"
export UV_LINK_MODE=copy

# Bun Configuration
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# mise - polyglot tool version manager (replaces nvm, pyenv, rbenv, volta, sdkman, jenv)
_evalcache mise activate zsh

# -----------------------------------------------------------------------------
# Tool Configurations
# -----------------------------------------------------------------------------

# FZF Configuration
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:#768390,bg:#24292e,hl:#cdd9e5 --color=fg+:#adbac7,bg+:#24292e,hl+:#f69d50 --color=info:#c69026,prompt:#539bf5,pointer:#986ee2 --color=marker:#57ab5a,spinner:#636e7b,header:#3c434d'
# Keybindings (Ctrl-T, Alt-C) + fuzzy completion. Replaces the old oh-my-zsh
# fzf plugin. Kept eager: fzf is fast and used constantly.
_evalcache fzf --zsh

# Kubernetes Configuration
export KUBECONFIG="$HOME/.kube/kind.yaml:$HOME/.kube/dev.yaml"
[ -f ~/.kubectl_aliases ] && source \
			<(sed -E 's/(kubectl.*) --watch/watch \1/g' ~/.kubectl_aliases)

# Lazy-load kubectl completion on first use — generating it shells out to the
# kubectl binary, which is too slow to do on every shell startup.
kubectl() {
	command kubectl "$@"
	local ret=$?
	if [[ -z $KUBECTL_COMPLETE ]]; then
		source <(command kubectl completion zsh)
		compdef __start_kubectl k 2>/dev/null
		KUBECTL_COMPLETE=1
	fi
	return $ret
}

# Direnv Configuration
_evalcache direnv hook zsh

# Shell History Configuration
_evalcache atuin init zsh

# Directory Navigation
_evalcache zoxide init zsh

# Terminal Integration
if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
		source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

# -----------------------------------------------------------------------------
# Cloud Platform Configurations
# -----------------------------------------------------------------------------

# AWS Configuration
assume_role_by_arn() {
	read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN \
		< <(aws sts assume-role --role-arn "$1" --role-session-name "$(whoami)" \
			| jq -r '.Credentials | "\(.AccessKeyId) \(.SecretAccessKey) \(.SessionToken)"') \
		&& export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}

assume_role() {
		role_arn="$(aws iam list-roles | jq -r --arg role_name "$1" '.Roles[] | select(.RoleName==$role_name).Arn')"
		assume_role_by_arn "$role_arn"
}

unassume_role() {
	unset AWS_SESSION_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
}

# AWS SSO CLI Configuration
__aws_sso_profile_complete() {
					local _args=${AWS_SSO_HELPER_ARGS:- -L error}
				_multi_parts : "($(/opt/homebrew/bin/aws-sso ${=_args} list --csv Profile))"
}

aws-sso-profile() {
				local _args=${AWS_SSO_HELPER_ARGS:- -L error}
				if [ -n "$AWS_PROFILE" ]; then
								echo "Unable to assume a role while AWS_PROFILE is set"
								return 1
				fi
				eval "$(/opt/homebrew/bin/aws-sso ${=_args} eval -p "$1")"
				if [ "$AWS_SSO_PROFILE" != "$1" ]; then
								return 1
				fi
}

aws-sso-clear() {
				local _args=${AWS_SSO_HELPER_ARGS:- -L error}
				if [ -z "$AWS_SSO_PROFILE" ]; then
								echo "AWS_SSO_PROFILE is not set"
								return 1
				fi
				eval "$(/opt/homebrew/bin/aws-sso ${=_args} eval -c)"
}

compdef __aws_sso_profile_complete aws-sso-profile
complete -C /opt/homebrew/bin/aws-sso aws-sso

# Granted - AWS SSO credential management
alias assume="source assume"

# Google Cloud SDK Configuration
if [ -f '/Volumes/Workspace/tools/google-cloud-sdk/path.zsh.inc' ]; then
		. '/Volumes/Workspace/tools/google-cloud-sdk/path.zsh.inc'
fi

if [ -f '/Volumes/Workspace/tools/google-cloud-sdk/completion.zsh.inc' ]; then
		. '/Volumes/Workspace/tools/google-cloud-sdk/completion.zsh.inc'
fi

# -----------------------------------------------------------------------------
# Development Tools
# -----------------------------------------------------------------------------
# Windsurf (AI-powered code editor)
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# GitKraken CLI
export PATH="/Applications/GitKraken.app/Contents/Resources/bin:$PATH"
alias gk="gitkraken"

# LLMs
export GEMINI_MODEL="gemini-2.5-pro"

# AI Assistant Function - Query OpenRouter API using Cerebras provider
llm() {
    if [ -z "$1" ]; then
        echo "Usage: llm <question>"
        return 1
    fi

    local payload
    payload=$(jq -n \
        --arg content "$1" \
        '{
            model: "openai/gpt-oss-120b",
            provider: { only: ["Cerebras"] },
            messages: [
                {role: "system", content: "You are a helpful assistant."},
                {role: "user", content: $content}
            ]
        }')

    curl -s https://openrouter.ai/api/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -d "$payload" \
        | jq -r '.choices[0].message.content' | glow -p
}

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Keep Codex on the Bun global install, even if other tool paths are prepended later.
export PATH="$HOME/.bun/bin:$PATH"
alias codex="$HOME/.bun/bin/codex"

# -----------------------------------------------------------------------------
# Prompt Configuration (must be last)
# -----------------------------------------------------------------------------
# Initialize starship AFTER all other shell integrations (Ghostty, atuin, etc.)
# Signal palette for the prompt (must precede starship init)
[[ -r ~/.config/zsh/signal.zsh ]] && source ~/.config/zsh/signal.zsh
_evalcache starship init zsh

# =============================================================================
# END OF CONFIGURATION
# =============================================================================
alias gemini='NODE_OPTIONS="--disable-warning=DEP0040" gemini'

# Matter CLI
export PATH="$HOME/.matter/bin:$PATH"



# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

# -----------------------------------------------------------------------------
# Syntax highlighting (MUST be sourced last, after all widgets are defined)
# -----------------------------------------------------------------------------
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
