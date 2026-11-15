#!/bin/sh
# Prints the tmux status segment for the git branch of a directory, or nothing
# when the directory is not in a git repository.
#   $1  directory (#{pane_current_path})
#   $2  chrome colour for rails and brackets (#{E:@chrome})
branch=$(git -C "$1" branch --show-current 2>/dev/null) || exit 0
[ -n "$branch" ] || exit 0
printf '#[fg=%s]─── ⟨ ⌥ #[fg=default]%s#[fg=%s] ⟩ ' "${2:-brightblack}" "$branch" "${2:-brightblack}"
