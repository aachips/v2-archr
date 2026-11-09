#!/bin/bash
# deploy.sh — Rebuild Vue portal and deploy to PHP-serving portal/
# Run from repo root: /Users/archrmac/Desktop/v2-archr
#
# Usage: ./deploy.sh
#   Or with migration: ./deploy.sh path/to/migration.sql

set -e

REPO="/Users/archrmac/Desktop/v2-archr"
cd "$REPO"

echo "=== [1/4] Pulling latest code ==="
git pull

echo "=== [2/4] Building Vue app ==="
cd "$REPO/vue-view"
npm run build

echo "=== [3/4] Deploying dist/ → portal/ ==="
cd "$REPO"
rm -rf portal/assets
mkdir -p portal/assets
cp -R vue-view/dist/assets portal/assets
cp vue-view/dist/portal.html portal/portal.html
cp vue-view/dist/intake.html portal/intake.html
cp vue-view/dist/favicon.ico portal/favicon.ico

echo "=== [4/4] Build complete ==="
echo "Portal is now served from $REPO/portal/"

# Optional: run a SQL migration if provided
if [ -n "$1" ] && [ -f "$1" ]; then
    echo "=== Running SQL migration: $1 ==="
    psql -d archr -f "$1"
    echo "Migration complete."
elif [ -n "$1" ]; then
    echo "WARNING: Migration file not found: $1"
    echo "Skipping migration."
fi

echo "=== Done! ==="
