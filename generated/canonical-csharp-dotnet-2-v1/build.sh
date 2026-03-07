#!/usr/bin/env bash
set -euo pipefail
dotnet publish -c Release -r linux-x64 --self-contained -o publish/ -nologo -v quiet
cp publish/minigit-app minigit
chmod +x minigit
