
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/pravin/miniconda3/bin/conda
    eval /Users/pravin/miniconda3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<

set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
