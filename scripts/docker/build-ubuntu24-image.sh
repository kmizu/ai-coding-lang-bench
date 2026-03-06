#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-ai-coding-lang-bench:ubuntu24}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

docker build -f "${REPO_ROOT}/docker/ubuntu24.Dockerfile" -t "${IMAGE_NAME}" "${REPO_ROOT}"
