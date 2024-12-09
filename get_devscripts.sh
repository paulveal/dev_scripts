#!/bin/bash

# Download the repository as a ZIP file quietly (-q) and save it as dev_scripts.zip (-O)
wget -q -O dev_scripts.zip https://github.com/paulveal/dev_scripts/archive/refs/heads/main.zip

# Unzip the downloaded file quietly (without showing the output)
unzip -q dev_scripts.zip

# Rename the unzipped directory
if [ -d "dev_scripts-main" ]; then
    mv dev_scripts-main dev_scripts
else
    echo "Directory dev_scripts-main does not exist."
    exit 1
fi

# Clean up the ZIP file
rm dev_scripts.zip

# Add the new dev_scripts directory to the PATH environment variable in .bashrc and .zshrc
DEV_SCRIPTS_PATH=$(pwd)/dev_scripts

# Function to add path to a shell configuration file
add_to_path() {
  local shell_rc=$1
  if ! grep -q "$DEV_SCRIPTS_PATH" "$shell_rc"; then
    echo "export PATH=\$PATH:$DEV_SCRIPTS_PATH" >> "$shell_rc"
    echo "Added dev_scripts to PATH in $shell_rc."
  else
    echo "dev_scripts is already in the PATH in $shell_rc."
  fi
}

# Add to .bashrc
add_to_path ~/.bashrc

# Add to .zshrc
add_to_path ~/.zshrc

# Single output message
echo "Please restart your terminal or run 'source ~/.bashrc' if using bash, or 'source ~/.zshrc' if using zsh to apply the changes."
