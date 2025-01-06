#!/usr/bin/env bash
source ~/.config/fish/config.fish
export PATH

# Define directories to search for projects
SEARCH_DIRS=(
  "$HOME"
)

# Use fd to find Git directories or fallback to find
find_projects() {
  if command -v fd &>/dev/null; then
    fd -HI -td "^.git$" --max-depth=4 --prune "${SEARCH_DIRS[@]}" | sed -r 's/\/.git\/$//'
  else
    find "${SEARCH_DIRS[@]}" -type d -name ".git" | sed -r 's/\/.git\/$//'
  fi
}

# Use fzf for selection
select_project() {
  find_projects | fzf --tmux center --prompt="Select a project: "
}

# Main logic
if [[ $# -eq 1 ]]; then
  selected=$1
else
  selected=$(select_project)
fi

if [[ -z $selected ]]; then
  exit 0
fi

# Generate a valid session name from the project directory
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  tmux new-session -s "$selected_name" -c "$selected"
  exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"
fi

if [[ -z $TMUX ]]; then
  tmux attach-session -t "$selected_name"
else
  tmux switch-client -t "$selected_name"
fi
