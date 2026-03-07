#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/src"
mmc --make minigit
mv minigit ../ 2>/dev/null || true
