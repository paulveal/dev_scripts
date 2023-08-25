#!/bin/zsh
usage() { echo "Usage: create_new_repo.sh <github_org> <repo>"; exit; }

if [ "$1" = "" ]
then
  usage
  exit
elif [ "$2" = "" ]
then
  usage
  exit
fi

# gh auth login

echo "Creating GitHub repo: $1/$2"

gh repo create $1/$2 --private
mkdir $2
cd $2
git init
echo "# $2" >> README.md
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/$1/$2
git push --set-upstream origin main

# if need to delete a repo on GitHub
#gh repo delete $1/$2 --yes
