#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
gfortran -o minigit src/minigit.f90
