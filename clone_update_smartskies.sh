# Login with gh for private repos, and follow prompts
# gh auth login

myorgname="SmartSkies"  # Set the organization name to 'SmartSkies'

total_repos=$(gh repo list $myorgname --limit 1000 | wc -l)  # Count the total number of repositories in the organization
current_repo=0  # Initialize the current repository counter

# Loop through each repository within the organization
gh repo list $myorgname --limit 1000 | while read -r repo _; do
    current_repo=$((current_repo + 1))  # Increment the current repository counter
    echo "Cloning repository" $current_repo "out of" $total_repos: $repo  # Display the progress of cloning the repository

    repo=${repo#$myorgname/}  # Remove 'orgname/' prefix from the repository name

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
