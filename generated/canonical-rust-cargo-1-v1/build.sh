#!/usr/bin/env bash
set -euo pipefail
cargo build --quiet
cp target/debug/minigit minigit
chmod +x minigit
