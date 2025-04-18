#!/bin/bash
echo "🗂 Creating backup of Gensyn Node for crypto_kasheer..."

BACKUP_DIR="$HOME/gensyn-backup"
mkdir -p $BACKUP_DIR

cp -r $HOME/gensyn-testnet $BACKUP_DIR/ 2>/dev/null
cp $HOME/.gensyn* $BACKUP_DIR/ 2>/dev/null

echo "✅ Backup completed at $BACKUP_DIR"
