# Dev Scripts

This repository contains a collection of shell scripts for managing GitHub repositories and user accounts. These scripts utilize the GitHub CLI (`gh`) to perform various tasks such as cloning repositories, creating new repositories, authenticating with GitHub, and managing user accounts on Linux systems.

## Scripts

### `clone_repo.sh`

This script clones all repositories from a specified GitHub organization or a single repository if specified.

Usage:

```sh
clone_repo.sh <github_org> [<github_repo>]
```

### `create_new_repo.sh`

This script creates a new GitHub repository under a specified organization and sets up the local repository.

Usage:

```sh
create_new_repo.sh <github_org> <repo> [private]
```

### `create_user.sh`

This script adds a new user and sets a password on any Linux distribution.

Usage:

```sh
create_user.sh <username> <password>
```

### `gh_auth.sh`

This script authenticates with GitHub using a token stored in a file and configures the Git user name and email.

Usage:

```sh
gh_auth.sh <path_to_token_file>
```

### `get_devscripts.sh`

This script downloads and sets up the development scripts from dev_scripts repository.

Usage:

```sh
get_devscripts.sh
```

### `unminimise.sh`

This script restores content and packages that are found on a default Ubuntu server system to make a minimized system more suitable for interactive use.

Usage:

```sh
unminimise.sh
```

## Requirements

- [GitHub CLI (`gh`)](https://cli.github.com/)
- `git`
- `wget`
- `unzip`
- `awk`
- `sed`
