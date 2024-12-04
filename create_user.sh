#!/bin/bash

# Script to add a user and password in any Linux distro

# Check if the number of arguments is exactly 2
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# Assign the first argument to USERNAME
USERNAME=$1
# Assign the second argument to PASSWORD
PASSWORD=$2

# Create a new user with a home directory
sudo useradd -m "$USERNAME"

# Set the password for the newly created user
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# Print a message indicating the user has been created and the password has been set
echo "User $USERNAME created and password set."
