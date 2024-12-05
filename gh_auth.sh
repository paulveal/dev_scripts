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
