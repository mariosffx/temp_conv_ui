#!/usr/bin/env bash
set -euo pipefail

# PM2 deploy hook: Runs on remote after code is fetched to new release.

PATH="$PATH:/root/.toolkit/tools/.asdf/shims"
PATH="$PATH:/root/.toolkit/bin/Linux/aarch64"
PATH="$PATH:/root/.toolkit/tools/flutter/bin"


echo "[post-deploy] Building project..."
rm -rf build
flutter build web --release
npm install 

# Start Hosting
CONFIG_FILE="ecosystem.config.cjs"
echo "[post-deploy] Starting/Reloading pm2 using $CONFIG_FILE"


if pm2 describe api >/dev/null 2>&1; then
  pm2 reload "$CONFIG_FILE" --update-env
else
  pm2 start "$CONFIG_FILE"
fi

echo "[post-deploy] Saving pm2 process list..."
pm2 save

echo "[post-deploy] Completed successfully."
