#!/bin/bash

# Check if a token file path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_token_file>"
  exit 1
fi

TOKEN_FILE=$1

# Check if the token file exists
if [ ! -f "$TOKEN_FILE" ]; then
  echo "Token file not found: $TOKEN_FILE"
  exit 1
fi

# Read the token from the file
TOKEN=$(cat "$TOKEN_FILE")

# Login to GitHub using the token
echo "$TOKEN" | gh auth login --with-token

# Check if authentication was successful
if [ $? -ne 0 ]; then
  echo "Authentication failed. Please check your token and try again."
  exit 1
else
  echo "Authentication successful."
fi

# Get the authenticated user's details
USER_DETAILS=$(gh api user)

# Extract real name and email using awk
NAME=$(echo "$USER_DETAILS" | awk -F'"name":' '{print $2}' | awk -F'"' '{print $2}')
EMAIL=$(echo "$USER_DETAILS" | awk -F'"email":' '{print $2}' | awk -F'"' '{print $2}')

# Check if email is null and prompt the user to enter their email
if [ "$EMAIL" = "null" ] || [ -z "$EMAIL" ]; then
  read -p "Email not found in GitHub profile. Please enter your email: " EMAIL
fi

# Set the Git configuration for user name and email
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

echo "Git configuration updated: user.name = '$NAME' and user.email = '$EMAIL'."
