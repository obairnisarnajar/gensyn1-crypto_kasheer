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
