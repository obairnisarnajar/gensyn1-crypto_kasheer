#!/bin/bash

echo -e "\033[1;34m[INFO] Checking and installing dependencies (nc and lsof)...\033[0m"
sudo apt-get update -y >/dev/null
sudo apt-get install -y netcat lsof python3 curl >/dev/null
echo -e "\033[1;32m[SUCCESS] Dependencies already installed.\033[0m"

echo -e "\n\033[1;34m[INFO] Checking rl-swarm directory...\033[0m"
BASE_DIR="$HOME/gensyn-testnet"
if [ -d "$BASE_DIR" ]; then
  echo -e "\033[1;32m[SUCCESS] Found gensyn-testnet directory in HOME.\033[0m"
else
  echo -e "\033[1;31m[ERROR] gensyn-testnet directory not found.\033[0m"
  exit 1
fi

echo -e "\n\033[1;34m[INFO] Checking cloudflared...\033[0m"
if ! command -v cloudflared &>/dev/null; then
  echo "[INFO] cloudflared not found. Installing..."
  wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
  sudo dpkg -i cloudflared-linux-amd64.deb >/dev/null
  rm cloudflared-linux-amd64.deb
else
  echo -e "\033[1;32m[SUCCESS] cloudflared is already installed.\033[0m"
fi

echo -e "\n\033[1;34m[INFO] Checking python3...\033[0m"
if ! command -v python3 &>/dev/null; then
  echo "[INFO] Installing python3..."
  sudo apt-get install -y python3 >/dev/null
else
  echo -e "\033[1;32m[SUCCESS] python3 is already installed.\033[0m"
fi

# Prepare files
echo -e "\n\033[1;34m[INFO] Copying files...\033[0m"
BACKUP_DIR="./backup-temp"
mkdir -p "$BACKUP_DIR/modal-login/temp-data"

FILES=(
  "$HOME/gensyn-testnet/swarm.pem"
  "$HOME/.gensyn/modal-login/temp-data/userData.json"
  "$HOME/.gensyn/modal-login/temp-data/userApiKey.json"
)

NAMES=("swarm.pem" "userData.json" "userApiKey.json")
LINKS=()

for i in "${!FILES[@]}"; do
  SRC="${FILES[$i]}"
  NAME="${NAMES[$i]}"
  DEST="$BACKUP_DIR"

  [[ $NAME != "swarm.pem" ]] && DEST="$BACKUP_DIR/modal-login/temp-data"

  if [ -f "$SRC" ]; then
    cp "$SRC" "$DEST/"
    echo -e "\033[1;32m[SUCCESS] $NAME copied.\033[0m"
    LINKS+=("$NAME")
  else
    echo -e "\033[1;33m[WARNING] $NAME not found.\033[0m"
  fi
done

# Start server on available port
echo -e "\n\033[1;34m[INFO] Starting HTTP server...\033[0m"
PORT=8000
while lsof -i:$PORT &>/dev/null; do
  echo "[WARNING] Port $PORT is already in use. Trying next port."
  ((PORT++))
done

echo "[INFO] Attempting to start HTTP server on port $PORT..."
cd "$BACKUP_DIR"
python3 -m http.server $PORT >/dev/null 2>&1 &
SERVER_PID=$!

# Start Cloudflare Tunnel
echo -e "\n\033[1;34m[INFO] Starting cloudflared tunnel to http://localhost:$PORT...\033[0m"
TUNNEL_URL=$(cloudflared tunnel --url http://localhost:$PORT 2>&1 | grep -o 'https://[-a-zA-Z0-9.@:%_+~#=]*.trycloudflare.com' | head -n 1)

if [ -z "$TUNNEL_URL" ]; then
  echo -e "\033[1;31m[ERROR] Cloudflare tunnel failed.\033[0m"
  kill $SERVER_PID
  exit 1
fi

echo -e "\n\033[1;32m[SUCCESS] Cloudflare tunnel established at: $TUNNEL_URL\033[0m"

# Show download links
echo ""
echo "========== VPS/GPU/WSL to PC =========="
echo "If you want to backup these files from VPS/GPU/WSL to your PC, visit the URLs and download."

index=1
for f in "${LINKS[@]}"; do
  echo ""
  echo "$index. $f"
  echo "$TUNNEL_URL/$f"
  ((index++))
done

echo ""
echo "======= ONE VPS/GPU/WSL to ANOTHER VPS/GPU/WSL ========"
echo "To send these files to another VPS/GPU/WSL, use the wget commands instead of the URLs."

index=1
for f in "${LINKS[@]}"; do
  echo "wget -O $f $TUNNEL_URL/$f"
  ((index++))
done

echo ""
echo "Press Ctrl+C to stop the server when you're done."

# Trap Ctrl+C
trap "echo -e '\nStopping servers...'; kill $SERVER_PID; exit" INT

# Wait forever
wait
