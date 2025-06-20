#!/bin/zsh

# Find all .DS_Store files from current directory
echo "Searching for .DS_Store files..."
ds_store_files=($(find . -type f -name '.DS_Store'))

if [[ ${#ds_store_files[@]} -eq 0 ]]; then
  echo "No .DS_Store files found."
  exit 0
fi

# Display files
echo "The following .DS_Store files will be deleted:"
for file in "${ds_store_files[@]}"; do
  echo "$file"
done

# Prompt for confirmation
echo -n "Delete these files? (Y/n): "
read -r confirmation

# Default to 'yes' if empty
if [[ -z "$confirmation" || "$confirmation" =~ ^[Yy]$ ]]; then
  for file in "${ds_store_files[@]}"; do
    rm "$file"
  done
  echo "Files deleted."
else
  echo "Deletion aborted."
fi