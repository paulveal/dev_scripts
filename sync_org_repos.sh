#!/usr/bin/env bash
set -euo pipefail

ORG="${1:-}"

if [[ -z "$ORG" ]]; then
  echo "Usage: $0 <github-org>"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required. Install gh and run:"
  echo "gh auth login"
  exit 1
fi

if [[ ! -d "$ORG" ]]; then
  echo "Creating org directory: $ORG"
  mkdir -p "$ORG"
fi

cd "$ORG"

echo "Fetching active repositories for org: $ORG"

gh repo list "$ORG" \
  --limit 1000 \
  --json name,isArchived,defaultBranchRef \
  --jq '.[] | select(.isArchived == false) | [.name, .defaultBranchRef.name] | @tsv' |
while IFS=$'\t' read -r REPO DEFAULT_BRANCH; do

  BRANCH="${DEFAULT_BRANCH:-main}"

  if [[ -d "$REPO/.git" ]]; then
    echo
    echo "Updating $REPO on $BRANCH"

    cd "$REPO"

    git fetch origin --prune

    if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
      git checkout "$BRANCH"
    else
      git checkout -b "$BRANCH" "origin/$BRANCH"
    fi

    git pull --ff-only origin "$BRANCH"

    cd ..

  elif [[ -d "$REPO" ]]; then
    echo
    echo "Skipping $REPO, directory exists but is not a git repo"

  else
    echo
    echo "Cloning $REPO"

    gh repo clone "$ORG/$REPO" "$REPO"
  fi

done

echo
echo "Done."