#!/bin/bash

echo -e "\033[1;34m[INFO] Checking and installing dependencies (nc and lsof)...\033[0m"
for cmd in nc lsof; do
    if ! command -v $cmd &>/dev/null; then
        sudo apt install -y $cmd &>/dev/null
    fi
done
echo -e "\033[1;32m[SUCCESS] Dependencies already installed.\033[0m"

echo -e "\033[1;34m[INFO] Checking rl-swarm directory...\033[0m"
if [ -d "$HOME/gensyn-testnet" ]; then
    echo -e "\033[1;32m[SUCCESS] Found gensyn-testnet directory in HOME.\033[0m"
else
    echo -e "\033[1;31m[ERROR] gensyn-testnet directory not found in HOME.\033[0m"
    exit 1
fi

echo -e "\033[1;34m[INFO] Checking cloudflared...\033[0m"
if ! command -v cloudflared &>/dev/null; then
    echo -e "\033[1;33m[WARNING] cloudflared not found. Installing with npx...\033[0m"
else
    echo -e "\033[1;32m[SUCCESS] cloudflared is already installed.\033[0m"
fi

echo -e "\033[1;34m[INFO] Checking python3...\033[0m"
if command -v python3 &>/dev/null; then
    echo -e "\033[1;32m[SUCCESS] python3 is already installed.\033[0m"
else
    echo -e "\033[1;31m[ERROR] python3 not installed. Please install python3.\033[0m"
    exit 1
fi

# Create backup directory
BACKUP_DIR="$HOME/gensyn-backup/modal-login/temp-data"
mkdir -p "$BACKUP_DIR"

cp "$HOME/gensyn-testnet/swarm.pem" "$HOME/gensyn-backup/swarm.pem"
cp "$HOME/.gensyn/modal-login/temp-data/userData.json" "$BACKUP_DIR/userData.json"
cp "$HOME/.gensyn/modal-login/temp-data/userApiKey.json" "$BACKUP_DIR/userApiKey.json"

echo -e "\033[1;34m[INFO] Starting HTTP server...\033[0m"
cd "$HOME/gensyn-backup"
python3 -m http.server 8000 &>/dev/null &
sleep 3

echo -e "\033[1;34m[INFO] Attempting to start HTTP server on port 8000...\033[0m"
sleep 1

echo -e "\033[1;34m[INFO] Starting cloudflared tunnel to http://localhost:8000...\033[0m"
sleep 2

npx cloudflared tunnel --url http://localhost:8000
# Start Cloudflare tunnel and capture the URL
CLOUDFLARE_URL=$(npx cloudflared tunnel --url http://localhost:8000 2>&1 | grep -o 'https://[-a-z0-9]*\.trycloudflare\.com' | head -n 1)

echo -e "\n\033[1;32m[SUCCESS] Cloudflare tunnel established at: $CLOUDFLARE_URL\033[0m"

echo -e "\n========== VPS/GPU/WSL to PC =========="
echo "If you want to backup these files from VPS/GPU/WSL to your PC, visit the URLs and download."

echo -e "\n1. swarm.pem"
echo "$CLOUDFLARE_URL/swarm.pem"

echo -e "\n2. userData.json"
echo "$CLOUDFLARE_URL/modal-login/temp-data/userData.json"

echo -e "\n3. userApiKey.json"
echo "$CLOUDFLARE_URL/modal-login/temp-data/userApiKey.json"

echo -e "\n======= ONE VPS/GPU/WSL to ANOTHER VPS/GPU/WSL ======="
echo "To send these files to another VPS/GPU/WSL, use the wget commands instead of the URLs."

echo -e "\nwget -O swarm.pem $CLOUDFLARE_URL/swarm.pem"
echo "wget -O userData.json $CLOUDFLARE_URL/modal-login/temp-data/userData.json"
echo "wget -O userApiKey.json $CLOUDFLARE_URL/modal-login/temp-data/userApiKey.json"

echo -e "\nPress Ctrl+C to stop the server when you're done."
