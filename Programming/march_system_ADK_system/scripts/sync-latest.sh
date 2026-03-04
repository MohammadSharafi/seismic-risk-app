#!/usr/bin/env bash
# Sync to latest MarchAgent (API + UI). Run from project root or MarchAgent/.
# Ensures you and your collaborator have the same version.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MARCH_AGENT="${ROOT}/MarchAgent"

echo "==> Syncing to latest MarchAgent..."
cd "$MARCH_AGENT"
git fetch origin
git checkout main
git pull origin main

LATEST=$(git rev-parse HEAD)
echo ""
echo "==> You are now at MarchAgent commit: $LATEST"
echo "    UI: MarchAgent/web/"
echo "    Run UI: cd MarchAgent/web && npm install && npm run dev"
echo ""
echo "==> To verify you match a teammate, both run: cd MarchAgent && git log -1 --oneline"
echo "    Expected: $LATEST"
