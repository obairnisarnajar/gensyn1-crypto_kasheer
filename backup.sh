#!/bin/bash

# Define the backup directory
BACKUP_DIR="$HOME/gensyn-backup"

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Define the list of files and directories to back up
BACKUP_ITEMS=(
  "$HOME/gensyn-testnet"
  "$HOME/.gensyn"
)

# Copy each item to the backup directory
for ITEM in "${BACKUP_ITEMS[@]}"; do
  if [ -e "$ITEM" ]; then
    cp -r "$ITEM" "$BACKUP_DIR"
  fi
done

echo "Backup completed successfully. Files are saved in $BACKUP_DIR."
