#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

# Create user
sudo useradd -m "$USERNAME"

# Set password
echo "$USERNAME:$PASSWORD" | sudo chpasswd

echo "User $USERNAME created and password set."
