#!/bin/bash

# Define a function called 'usage' to display the script usage instructions
usage() {
  echo "Usage: create_new_repo.sh <repo> [-o <github_org>] [--public]"
  exit 1
}

# Check if the user is authenticated to GitHub
if ! gh auth status > /dev/null 2>&1; then
  echo "Error: You are not authenticated to GitHub. Please run 'gh auth login' to authenticate."
  exit 1
fi

# Get the default GitHub organization (personal org of the logged-in user)
DEFAULT_ORG=$(gh api user --jq '.login')

# Initialize variables
github_org="$DEFAULT_ORG"
visibility="--private"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -o)
      github_org="$2"
      shift 2
      ;;
    --public)
      visibility="--public"
      shift
      ;;
    *)
      if [[ -z "$repo" ]]; then
        repo="$1"
      else
        usage
      fi
      shift
      ;;
  esac
done

# Check if the repository name is provided
if [ -z "$repo" ]; then
  usage
fi

# This script creates a new GitHub repository with the specified owner and name
echo "Creating GitHub repo: $github_org/$repo with visibility $visibility"

# Create a new repository on GitHub using the 'gh repo create' command with the specified visibility
gh repo create "$github_org/$repo" $visibility

# Create a new directory with the same name as the repository, navigate into it and initialize a new git repository
mkdir "$repo"
cp "$(dirname "$0")/standard_gitignore" "$repo/.gitignore"
cd "$repo"
git init

# Add a README.md file with the repository name as the heading, stage and commit the changes
echo "# $repo" >> README.md
git add .

git commit -m "first commit"

# Set the main branch as the default branch, add the GitHub repository as the remote origin and push the local repository to GitHub
git branch -M main && git remote add origin "https://github.com/$github_org/$repo" && git push --set-upstream origin main