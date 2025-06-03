#!/bin/sh

# ANSI colours
RESET="\033[0m"
YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"

# Usage help
if [ -z "$1" ]; then
  echo "Usage: $0 <org-name> [repo-name] [--delete]"
  echo "  <org-name>   Required GitHub organisation name"
  echo "  [repo-name]  Optional repository name within the org"
  echo "  --delete     Optional flag to actually delete merged branches"
  exit 1
fi

ORG="$1"
REPO=""
DELETE_MODE=false

# Parse optional arguments
shift
while [ $# -gt 0 ]; do
  case "$1" in
    --delete)
      DELETE_MODE=true
      ;;
    *)
      REPO="$1"
      ;;
  esac
  shift
done

if [ "$DELETE_MODE" = true ]; then
  echo "${GREEN}Running in DELETE mode. Merged branches will be permanently removed.${RESET}"
else
  echo "${YELLOW}Running in DRY-RUN mode. No branches will be deleted.${RESET}"
fi

# Branch names to skip regardless of protection
DEFAULT_BRANCHES="main master develop test"

process_repo() {
  repo_name="$1"
  echo "----------------------------------------"
  echo "Processing repo: $repo_name"

  DEFAULT=$(gh repo view "$ORG/$repo_name" --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null)
  if [ -z "$DEFAULT" ]; then
    echo "${RED}  [ERROR] Failed to fetch default branch for $repo_name${RESET}"
    return
  fi

  echo "Default branch: $DEFAULT"

  gh api "repos/$ORG/$repo_name/branches" --paginate --jq '.[].name' | while read BRANCH; do
    # 1. Check GitHub protection
    IS_PROTECTED=$(gh api "repos/$ORG/$repo_name/branches/$BRANCH" --jq '.protected' 2>/dev/null)
    if [ "$IS_PROTECTED" = "true" ]; then
      echo "${YELLOW}  Skipping branch '$BRANCH' – GitHub reports it is protected${RESET}"
      continue
    fi

    # 2. Skip known default-like branch names
    if echo "$DEFAULT_BRANCHES" | grep -qw "$BRANCH"; then
      echo "${YELLOW}  Skipping branch '$BRANCH' – matches protected name list${RESET}"
      continue
    fi
    if [ "$BRANCH" = "$DEFAULT" ]; then
      echo "${YELLOW}  Skipping branch '$BRANCH' – default branch${RESET}"
      continue
    fi

    # 3. Check if branch has been merged via PR
    PR_MERGED=$(gh pr list --repo "$ORG/$repo_name" --head "$BRANCH" --state merged --json number -q '.[].number')
    if [ -n "$PR_MERGED" ]; then
      if [ "$DELETE_MODE" = true ]; then
        echo "${GREEN}  Deleting merged branch: $BRANCH${RESET}"
        gh api -X DELETE --silent "repos/$ORG/$repo_name/git/refs/heads/$BRANCH"
      else
        echo "${GREEN}  [DRY-RUN] Would delete merged branch: $BRANCH${RESET}"
      fi
    else
      echo "${YELLOW}  Skipping branch '$BRANCH' – no merged PR found${RESET}"
    fi
  done
}

# Run on a single repo or across the org
if [ -n "$REPO" ]; then
  process_repo "$REPO"
else
  gh repo list "$ORG" --limit 1000 --json name -q '.[].name' | while read repo_name; do
    process_repo "$repo_name"
  done
fi