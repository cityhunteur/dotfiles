# # Homebrew
# # Read-only access to public repos.
# export HOMEBREW_GITHUB_API_TOKEN=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

# If you come from bash you might have to change your $PATH.
export PATH="$HOME/.jenv/bin:$PATH"
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="/Users/pravin/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty . This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you wantvi to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom fol:wder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	autoenv
	autojump
	fzf
	git
	kubectl
	kubectl
	tmuxinator
	vi-mode
	zsh-autosuggestions
	zsh-syntax-highlighting
)

# Shell
source $ZSH/oh-my-zsh.sh

# Pure Prompt
# autoload -Uz compinit; compinit
# autoload -Uz promptinit; promptinit
# PURE_CMD_MAX_EXEC_TIME=3600
# prompt pure

# User configuration

bindkey -v

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias date=gdate
alias k="kubectl"
alias kc="kubectx"
alias kn="kubens"
alias ll="gls --color=always -gGh --group-directories-first"
alias ls="gls --color=always -G"
alias ohmyzsh="subl ~/.oh-my-zsh"
alias pip="pip3"
alias rgf='rg --files | rg'
alias t='temporal'
alias tf='terraform'
alias ts='temporal server start-dev'
alias tsbg='temporal server start-dev &> /dev/null & disown'
alias tsdb='temporal server start-dev --db-filename ~/temporal.db'
alias tw='temporal workflow'
alias vi="nvim"
alias vim="nvim"
alias zshconfig="subl ~/.zshrc"
function lk {
  cd "$(walk "$@")"
}

# Golang
export GOPATH=/Volumes/Workspace
export GOBIN="$GOPATH"/bin
export PATH="$PATH:${GOPATH//://bin:}/bin"

# Java
eval "$(jenv init -)"

# Python
export PATH="$PATH:/Users/pravin/.local/bin"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Node
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
# bun completions
[ -s "/Users/pravin/.bun/_bun" ] && source "/Users/pravin/.bun/_bun"

# Kubernetes
[ -f ~/.kubectl_aliases ] && source \
   <(cat ~/.kubectl_aliases | sed -r 's/(kubectl.*) --watch/watch \1/g')

# Shell
export GIT_TERMINAL_PROMPT=1

eval "$(direnv hook zsh)"

export EDITOR='nvim'

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:#768390,bg:#24292e,hl:#cdd9e5 --color=fg+:#adbac7,bg+:#24292e,hl+:#f69d50 --color=info:#c69026,prompt:#539bf5,pointer:#986ee2 --color=marker:#57ab5a,spinner:#636e7b,header:#3c434d'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)

source /Users/pravin/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

complete -F __start_kubectl kexport PATH="/usr/local/opt/openjdk/bin:$PATH"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform

export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/yq@3/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Volumes/Workspace/tools/google-cloud-sdk/path.zsh.inc' ]; then . '/Volumes/Workspace/tools/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Volumes/Workspace/tools/google-cloud-sdk/completion.zsh.inc' ]; then . '/Volumes/Workspace/tools/google-cloud-sdk/completion.zsh.inc'; fi

# AWS Utility funcs
assume_role_by_arn() {
	read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN < <(echo $(aws sts assume-role --role-arn "$1" --role-session-name "$(whoami)" | jq -r '.Credentials.AccessKeyId, .Credentials.SecretAccessKey, .Credentials.SessionToken')) && export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
}

# AWS helper functions to assume roles
assume_role() {
  role_arn="$(aws iam list-roles | jq -r --arg role_name "$1" '.Roles[] | select(.RoleName==$role_name).Arn')"
  assume_role_by_arn "$role_arn"
}

unassume_role() {
	unset AWS_SESSION_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
}

# BEGIN_AWS_SSO_CLI

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
    eval $(/opt/homebrew/bin/aws-sso ${=_args} eval -p "$1")
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
    eval $(/opt/homebrew/bin/aws-sso ${=_args} eval -c)
}

compdef __aws_sso_profile_complete aws-sso-profile
complete -C /opt/homebrew/bin/aws-sso aws-sso

# END_AWS_SSO_CLI

eval "$(starship init zsh)"
eval "$(atuin init zsh)"
