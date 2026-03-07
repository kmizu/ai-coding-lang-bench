#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cobc -x -free -o minigit src/minigit.cob
