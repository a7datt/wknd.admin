#!/bin/bash
set -e

APP_DIR="/root/apps/wknd/admin"
APP_NAME="wknd-admin"

echo "[deploy] Starting at $(date)"
cd "$APP_DIR"

echo "[deploy] Pulling latest code..."
git pull origin main

echo "[deploy] Freeing space before install..."
rm -rf "$APP_DIR/node_modules"
find /root/apps/wknd/user/node_modules -name "*.d.ts" -o -name "*.md" -delete 2>/dev/null || true

echo "[deploy] Installing production deps..."
npm install --omit=dev --no-audit --no-fund

echo "[deploy] Installing build tools for build step..."
npm install --no-save vite @vitejs/plugin-react @tailwindcss/vite typescript 2>/dev/null

echo "[deploy] Building..."
npm run build

echo "[deploy] Pruning devDeps..."
npm prune --omit=dev
find "$APP_DIR/node_modules" \( -name "*.d.ts" -o -name "*.md" -o -name "LICENSE*" -o -name "*.map" \) -delete 2>/dev/null

echo "[deploy] Restarting..."
pm2 restart "$APP_NAME" --update-env || pm2 start "npx tsx server.ts" --name "$APP_NAME" --cwd "$APP_DIR"
pm2 save

echo "[deploy] Done at $(date)"
