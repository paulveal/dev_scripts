#!/bin/bash

# Function to check if a directory is a Git repository
is_git_repo() {
    git -C "$1" rev-parse 2>/dev/null
}

# Function to check if a Git repository is up to date
is_up_to_date() {
    local repo_dir=$1
    git -C "$repo_dir" fetch --quiet
    local local_hash=$(git -C "$repo_dir" rev-parse @)
    local remote_hash
    local base_hash

    if ! remote_hash=$(git -C "$repo_dir" rev-parse @{u} 2>/dev/null); then
        echo "Repository not in GitHub"
        return
    fi

    base_hash=$(git -C "$repo_dir" merge-base @ @{u})

    if [ "$local_hash" = "$remote_hash" ]; then
        echo "Up to date"
    elif [ "$local_hash" = "$base_hash" ]; then
        echo "Need to pull"
    elif [ "$remote_hash" = "$base_hash" ]; then
        echo "Need to push"
    else
        echo "Diverged"
    fi
}

# Function to recursively check directories
check_directories() {
    local parent_dir=$1
    find "$parent_dir" -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' -not -path '*/node_modules/*' | while read -r dir; do
        if [ -d "$dir/.git" ]; then
            echo "Directory: $dir"
            echo "Git repository: Yes"
            echo "Status: $(is_up_to_date "$dir")"
            echo
        else
            echo "Directory: $dir"
            echo "Git repository: No"
            echo
            check_directories "$dir"
        fi
    done
}

# Start checking from the current directory
check_directories .