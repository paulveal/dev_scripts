#!/bin/zsh

# Shell script to clone repositories from a GitHub organization using 'gh' CLI tool.
# The script allows cloning all repositories from the organization or a specific repository based on input arguments.
# It also supports updating existing clones by pulling changes from the remote repository.

# Function to display usage information when script is run without required arguments
usage() {
  echo "Usage: clone_repo.sh <github org> [<github repo>]"
  exit
}

# Flag to indicate if single repository cloning is specified
singlerepo=false

# Check if script is run without any arguments
if [ "$1" = "" ]; then
  usage
  exit
# Check if only the organization name is provided
elif [ "$2" = "" ] && [ "$1" != "" ]; then
  echo "All repos being cloned for org: $1"
else
  # Indicates that a specific repository will be cloned
  echo "Single specific repo being cloned: $1/$2"
  singlerepo=true
fi

# Authenticates with GitHub using 'gh' CLI
# gh auth login

# Store the organization name provided as input
myorgname=$1

# Get the total number of repositories in the organization
total_repos=$(gh repo list $myorgname --limit 1000 | wc -l | awk '{$1=$1};1')

current_repo=0

# Function to clone a repository using 'gh' CLI
# Parameters:
#   $1 - Repository name
#   $2 - Current repository count
#   $3 - Total number of repositories
clone_repo() {
  # Repository name
  local repo=$1
  # Current repository count
  local current_repo=$2
  # Total number of repositories
  local total_repos=$3

  echo "Cloning repository $current_repo out of $total_repos: $repo"

  # Clone the repository using 'gh repo clone' command
  gh repo clone "$repo" -- -q 2>/dev/null || (
    # Extract the repository directory name
    repodir=$(echo "$repo" | sed -E 's/.*\/([^\/]*)/\1/' | sed -E "s/${myorgname}\///I")

    echo "Updating: $repodir"
    cd "$repodir" || exit

    # Try to update the cloned repository
    set +e
    git checkout -q main 2>/dev/null
    git checkout -q master 2>/dev/null
    git pull -q
    set -e
  )
}

# Check if single repository cloning is specified
if [ "$singlerepo" = true ]; then
  clone_repo "$myorgname/$2" 1 1
else
  # Loop through all repositories in the organization and clone/update them
  gh repo list $myorgname --limit 1000 | while read -r repo _; do
    current_repo=$((current_repo + 1))
    clone_repo "$repo" "$current_repo" "$total_repos"
  done
fi
