#!/bin/zsh
usage() { echo "Usage: clone_repo.sh <github org>"; exit; }

if [ "$1" = "" ]
then
  usage
  exit
fi

# # 1. Login with gh for private repos, and follow prompts
# gh auth login

# 2. Clone (or update) up to 1000 repos under `./myorgname` folder
#    [replace 'myorgname' with your org name and increase repo limit if needed]
gh repo list $1 --limit 1000 | while read -r repo _; do
    gh repo clone "$repo" -- -q 2>/dev/null || (
        cd "$repo"
        # Handle case where local checkout is on a non-main/master branch
        # - ignore all errors because some repos may have zero commits, 
        # so no main or master
        set +e
        git checkout -q main 2>/dev/null
        git checkout -q master 2>/dev/null
        git pull -q
        set -e
    )
done