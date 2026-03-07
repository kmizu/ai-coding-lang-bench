#!/usr/bin/env bash
set -euo pipefail
cabal build exe:minigit >/dev/null
BIN="$(cabal list-bin exe:minigit)"
cp "$BIN" minigit
chmod +x minigit
