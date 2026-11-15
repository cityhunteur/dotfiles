#!/bin/sh
# Prints the tmux status segment for the git branch of a directory, or nothing
# when the directory is not in a git repository.
#   $1  directory (#{pane_current_path})
#   $2  rule colour                       (#{@rule})
#   $3  muted colour for marker/brackets  (#{@muted})
#   $4  primary colour for the branch     (#{@primary})
branch=$(git -C "$1" branch --show-current 2>/dev/null) || exit 0
[ -n "$branch" ] || exit 0
printf '#[fg=%s]─── #[fg=%s]⟨ ⌥ #[fg=%s]%s#[fg=%s] ⟩ ' "$2" "$3" "$4" "$branch" "$3"
