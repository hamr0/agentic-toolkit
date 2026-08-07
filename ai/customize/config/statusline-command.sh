#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Get git branch if in a git repo
git_branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        git_branch=" on $(printf '\033[35m')$branch$(printf '\033[0m')"
    fi
fi

# Show context percentage used, if context info is available
context_bar=""
if [ -n "$remaining" ]; then
    used=$(printf '%.0f' $(echo "100 - $remaining" | bc -l))

    if [ "$used" -lt 25 ]; then
        ctx_color=$(printf '\033[32m')   # green
    elif [ "$used" -lt 35 ]; then
        ctx_color=$(printf '\033[38;5;208m')   # orange
    else
        ctx_color=$(printf '\033[31m')   # red
    fi

    context_bar=" | ${ctx_color}${used}%$(printf '\033[0m')"
fi

# Output the status line
printf "$(printf '\033[36m')%s$(printf '\033[0m')%s | $(printf '\033[33m')%s$(printf '\033[0m')%s\n" "$cwd" "$git_branch" "$model" "$context_bar"
