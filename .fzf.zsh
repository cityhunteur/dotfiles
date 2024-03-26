# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/pravin/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/pravin/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/pravin/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/pravin/.fzf/shell/key-bindings.zsh"
