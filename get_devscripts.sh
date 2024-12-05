#!/bin/bash

# Download the repository as a ZIP file
wget -O dev_scripts.zip https://github.com/paulveal/dev_scripts/archive/refs/heads/main.zip

# Unzip the downloaded file
unzip dev_scripts.zip

# Rename the unzipped directory
mv dev_scripts-main dev_scripts

# Clean up the ZIP file
rm dev_scripts.zip