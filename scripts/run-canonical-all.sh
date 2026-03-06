#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUN_BENCHMARK="${REPO_ROOT}/scripts/run-benchmark.sh"
TOOLCHAINS_CONFIG="${REPO_ROOT}/config/toolchains.yml"

INCLUDE_SECONDARY=0
INCLUDE_REFERENCE=0
TRIALS="1"
START=""
SEED=""
DRY_RUN=0
SKIP_REPORT=0
SKIP_PLOT=0
BOOTSTRAP_MODE=""
INSTALL_ROOT=""
STAGE_RESULTS=0
COMMIT_MESSAGE=""
PUSH_AFTER_COMMIT=0

usage() {
  cat <<'EOF'
Usage: ./scripts/run-canonical-all.sh [options]

Runs the canonical benchmark suite with one command.
By default, this means every toolchain with `canonical: true` in config/toolchains.yml.

Examples:
  ./scripts/run-canonical-all.sh
  ./scripts/run-canonical-all.sh --include-secondary
  ./scripts/run-canonical-all.sh --stage-results
  ./scripts/run-canonical-all.sh --commit "Refresh canonical benchmark results"
  ./scripts/run-canonical-all.sh --commit "Refresh canonical benchmark results" --push

Options:
  --trials N              number of trials (default: 1)
  --start N               starting trial number
  --seed N                shuffle seed
  --include-secondary     include non-canonical secondary workflows
  --include-reference     include weakly canonical reference workflows
  --dry-run               skip Claude execution and result writes
  --skip-report           skip ruby report.rb
  --skip-plot             skip plot generation
  --bootstrap             always run bootstrap
  --no-bootstrap          never run bootstrap
  --install-root PATH     override toolchain install root
  --stage-results         git add benchmark outputs after the run
  --commit MESSAGE        stage outputs and create a git commit
  --push                  push after a successful --commit
  --help                  show this message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --trials)
      TRIALS="$2"
      shift 2
      ;;
    --start)
      START="$2"
      shift 2
      ;;
    --seed)
      SEED="$2"
      shift 2
      ;;
    --include-secondary)
      INCLUDE_SECONDARY=1
      shift
      ;;
    --include-reference)
      INCLUDE_REFERENCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --skip-report)
      SKIP_REPORT=1
      shift
      ;;
    --skip-plot)
      SKIP_PLOT=1
      shift
      ;;
    --bootstrap)
      BOOTSTRAP_MODE="--bootstrap"
      shift
      ;;
    --no-bootstrap)
      BOOTSTRAP_MODE="--no-bootstrap"
      shift
      ;;
    --install-root)
      INSTALL_ROOT="$2"
      shift 2
      ;;
    --stage-results)
      STAGE_RESULTS=1
      shift
      ;;
    --commit)
      COMMIT_MESSAGE="$2"
      STAGE_RESULTS=1
      shift 2
      ;;
    --push)
      PUSH_AFTER_COMMIT=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "${PUSH_AFTER_COMMIT}" -eq 1 && -z "${COMMIT_MESSAGE}" ]]; then
  echo "--push requires --commit" >&2
  exit 1
fi

resolve_toolchains() {
  ruby -ryaml -e '
    config = YAML.load_file(ARGV[0])
    include_secondary = ENV["INCLUDE_SECONDARY"] == "1"
    include_reference = ENV["INCLUDE_REFERENCE"] == "1"
    toolchains = config.fetch("toolchains").select do |tc|
      tc["canonical"] || (include_secondary && tc["tier"] == "secondary") || (include_reference && tc["tier"] == "reference")
    end
    puts toolchains.map { |tc| tc.fetch("id") }.join(",")
  ' "${TOOLCHAINS_CONFIG}"
}

stage_outputs() {
  git add results/results.json results/meta.json results/report.md figures
}

TOOLCHAINS="$(INCLUDE_SECONDARY="${INCLUDE_SECONDARY}" INCLUDE_REFERENCE="${INCLUDE_REFERENCE}" resolve_toolchains)"
if [[ -z "${TOOLCHAINS}" ]]; then
  echo "No toolchains selected" >&2
  exit 1
fi

echo "Selected toolchains: ${TOOLCHAINS}"

run_args=(--track canonical --toolchains "${TOOLCHAINS}")
[[ -n "${TRIALS}" ]] && run_args+=(--trials "${TRIALS}")
[[ -n "${START}" ]] && run_args+=(--start "${START}")
[[ -n "${SEED}" ]] && run_args+=(--seed "${SEED}")
[[ -n "${BOOTSTRAP_MODE}" ]] && run_args+=("${BOOTSTRAP_MODE}")
[[ -n "${INSTALL_ROOT}" ]] && run_args+=(--install-root "${INSTALL_ROOT}")
[[ "${DRY_RUN}" -eq 1 ]] && run_args+=(--dry-run)
[[ "${SKIP_REPORT}" -eq 1 ]] && run_args+=(--skip-report)
[[ "${SKIP_PLOT}" -eq 1 ]] && run_args+=(--skip-plot)

"${RUN_BENCHMARK}" "${run_args[@]}"

if [[ "${DRY_RUN}" -eq 1 ]]; then
  exit 0
fi

if [[ "${STAGE_RESULTS}" -eq 1 ]]; then
  (
    cd "${REPO_ROOT}"
    stage_outputs
    echo
    echo "Staged benchmark outputs:"
    git status --short results/results.json results/meta.json results/report.md figures

    if [[ -n "${COMMIT_MESSAGE}" ]]; then
      git commit -m "${COMMIT_MESSAGE}"
      if [[ "${PUSH_AFTER_COMMIT}" -eq 1 ]]; then
        git push
      fi
    fi
  )
fi
