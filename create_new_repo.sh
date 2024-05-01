#!/bin/zsh

# Define a function called 'usage' to display the script usage instructions
usage() {
  echo "Usage: create_new_repo.sh <github_org> <repo>"
  exit
}

# Check if the first or second command line argument is empty, if either is empty then display usage and exit
if [ "$1" = "" ] || [ "$2" = "" ]
then
  usage
fi

# This script creates a new GitHub repository with the specified owner and name
echo "Creating GitHub repo: $1/$2"

# Create a new private repository on GitHub using the 'gh repo create' command
gh repo create $1/$2 --private

# Create a new directory with the same name as the repository, navigate into it and initialize a new git repository
mkdir $2 && cd $2 && git init

# Add a README.md file with the repository name as the heading, stage and commit the changes
echo "# $2" >> README.md
git add README.md
git commit -m "first commit"

# Set the main branch as the default branch, add the GitHub repository as the remote origin and push the local repository to GitHub
git branch -M main && git remote add origin https://github.com/$1/$2 && git push --set-upstream origin main

# If you need to delete a repo on GitHub, uncomment the following line
#gh repo delete $1/$2 --yes
