#!/usr/bin/env bash
set -euo pipefail
mix escript.build --no-deps-check
chmod +x minigit
