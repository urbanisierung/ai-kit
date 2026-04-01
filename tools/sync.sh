#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
git -C "$REPO" pull --ff-only
bash "$REPO/tools/setup.sh"
echo "Synced."
