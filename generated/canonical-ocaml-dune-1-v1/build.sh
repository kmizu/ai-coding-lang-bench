#!/usr/bin/env bash
set -euo pipefail
dune build ./bin/main.exe
cp _build/default/bin/main.exe minigit
chmod +x minigit
