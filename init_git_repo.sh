#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for necessary tools
if ! command_exists git; then
    echo "Error: Git is not installed. Please install it and try again."
    exit 1
fi

if ! command_exists gh; then
    echo "Error: GitHub CLI (gh) is not installed. Please install it and try again."
    exit 1
fi

# Get the current directory name as the repository name
REPO_NAME=$(basename "$PWD")

# Initialise a new Git repository
git init
echo "Initialized empty Git repository in $(pwd)"

# Copy the standard_gitignore to .gitignore
cp "$(dirname "$0")/standard_gitignore" .gitignore
echo "Copied standard_gitignore to .gitignore."

# Create a README.md file if it doesn't exist
if [ ! -f README.md ]; then
    echo "# $REPO_NAME" > README.md
    echo "README.md file created."
fi

# If .gitignore is not present, create it from standard_gitignore
if [ ! -f .gitignore ]; then
    cp "$(dirname "$0")/standard_gitignore" .gitignore
    echo "Copied standard_gitignore to .gitignore."
fi

# Stage all files and commit with "Initial Commit"
git add .
git commit -m "Initial Commit"
echo "Created initial commit."

# Create a GitHub repository using gh CLI
gh repo create "$REPO_NAME" --private --source=. --push
if [ $? -eq 0 ]; then
    echo "GitHub repository '$REPO_NAME' created and pushed successfully."
else
    echo "Error: Failed to create or push to GitHub repository."
    exit 1
fi
``