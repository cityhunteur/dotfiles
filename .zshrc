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
# Oh My Zsh Configuration
# -----------------------------------------------------------------------------
#
# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme configuration - using starship prompt
ZSH_THEME=""

# Update configuration
export UPDATE_ZSH_DAYS=7

# Plugins configuration
plugins=(
    autojump
    fzf
    git
    kubectl
    tmuxinator
    vi-mode
    zsh-autosuggestions
    zsh-syntax-highlighting
    macos
)

# Disable Oh My Zsh prompt modifications before loading
DISABLE_AUTO_TITLE="true"
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""

# Initialize Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Starship is initialized at the end of the file after all other integrations

# -----------------------------------------------------------------------------
# Shell Configuration
# -----------------------------------------------------------------------------
# Editor configuration
export EDITOR='hx'

# Git configuration
export GIT_TERMINAL_PROMPT=1
export GPG_TTY=$(tty)

# Shell key bindings
bindkey -v

# Completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit
    compinit
fi

# Bash completions
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Directory colors
test -r ~/.dir_colors && eval "$(gdircolors ~/.dir_colors)"

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
# System utilities
alias ll="gls --color=always -gGh --group-directories-first"
alias ls="gls --color=always -G"
alias vi="hx"
alias vim="hx"
alias pip="pip3"

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
alias gk="gitkraken"
alias gemini='NODE_OPTIONS="--disable-warning=DEP0040" gemini'

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
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PATH:$HOME/.local/bin"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export UV_LINK_MODE=copy

# Node.js Configuration
# Volta (primary Node version manager)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# NVM (lazy-loaded to avoid PATH conflicts with Volta)
load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

# Bun Configuration
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Java Configuration (SDKMAN)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# -----------------------------------------------------------------------------
# Tool Configurations
# -----------------------------------------------------------------------------

# FZF Configuration
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:#768390,bg:#24292e,hl:#cdd9e5 --color=fg+:#adbac7,bg+:#24292e,hl+:#f69d50 --color=info:#c69026,prompt:#539bf5,pointer:#986ee2 --color=marker:#57ab5a,spinner:#636e7b,header:#3c434d'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Kubernetes Configuration
export KUBECONFIG="$HOME/.kube/kind.yaml:$HOME/.kube/dev.yaml"
[ -f ~/.kubectl_aliases ] && source \
    <(sed -E 's/(kubectl.*) --watch/watch \1/g' ~/.kubectl_aliases)
complete -F __start_kubectl k

# Direnv Configuration
eval "$(direnv hook zsh)"

# Shell History Configuration
eval "$(atuin init zsh)"

# Directory Navigation
eval "$(zoxide init zsh)"

# Terminal Integration
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
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

# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Keep Codex on the Bun global install, even if other tool paths are prepended later.
export PATH="$HOME/.bun/bin:$PATH"
alias codex="$HOME/.bun/bin/codex"

# -----------------------------------------------------------------------------
# Prompt Configuration (must be last)
# -----------------------------------------------------------------------------
# Initialize starship AFTER all other shell integrations (Ghostty, atuin, etc.)
eval "$(starship init zsh)"
