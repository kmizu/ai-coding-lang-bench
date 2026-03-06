#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INSTALL_SCRIPT="${REPO_ROOT}/scripts/setup/ubuntu24/install-toolchains.sh"

if [[ "${EUID}" -eq 0 ]]; then
  DEFAULT_INSTALL_ROOT="/opt/ai-coding-lang-bench"
else
  DEFAULT_INSTALL_ROOT="${HOME}/.local/share/ai-coding-lang-bench"
fi

INSTALL_ROOT="${INSTALL_ROOT:-${DEFAULT_INSTALL_ROOT}}"
TRACK="canonical"
TOOLCHAINS=""
TIERS="primary"
LANGS=""
TRIALS=""
START=""
SEED=""
DRY_RUN=0
BOOTSTRAP_MODE="auto"
RUN_REPORT=1
RUN_PLOT=1
PLOT_TRACK=""
PLOT_TIERS=""
PLOT_OUTDIR=""

usage() {
  cat <<'EOF'
Usage: ./scripts/run-benchmark.sh [options]

Examples:
  ./scripts/run-benchmark.sh --toolchains python-uv,rust-cargo --trials 1
  ./scripts/run-benchmark.sh --track canonical --tiers primary,secondary --dry-run
  ./scripts/run-benchmark.sh --track greenfield --lang python,rust --trials 1

Options:
  --track TRACK           greenfield or canonical (default: canonical)
  --toolchains IDS        comma-separated canonical toolchain ids
  --tiers TIERS           comma-separated canonical tiers (default: primary)
  --lang LANGS            comma-separated legacy greenfield languages
  --trials N              number of trials
  --start N               starting trial number
  --seed N                shuffle seed
  --install-root PATH     toolchain install root
  --bootstrap             always run the installer first
  --no-bootstrap          never run the installer
  --skip-report           skip ruby report.rb
  --skip-plot             skip plot generation
  --plot-track TRACK      plotting filter (defaults to benchmark track)
  --plot-tiers TIERS      plotting tier filter for canonical runs
  --plot-outdir DIR       plotting output directory
  --dry-run               pass --dry-run to benchmark.rb and skip report/plot
  --help                  show this message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --track)
      TRACK="$2"
      shift 2
      ;;
    --toolchains)
      TOOLCHAINS="$2"
      shift 2
      ;;
    --tiers)
      TIERS="$2"
      shift 2
      ;;
    --lang|--langs)
      LANGS="$2"
      shift 2
      ;;
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
    --install-root)
      INSTALL_ROOT="$2"
      shift 2
      ;;
    --bootstrap)
      BOOTSTRAP_MODE="always"
      shift
      ;;
    --no-bootstrap)
      BOOTSTRAP_MODE="never"
      shift
      ;;
    --skip-report)
      RUN_REPORT=0
      shift
      ;;
    --skip-plot)
      RUN_PLOT=0
      shift
      ;;
    --plot-track)
      PLOT_TRACK="$2"
      shift 2
      ;;
    --plot-tiers)
      PLOT_TIERS="$2"
      shift 2
      ;;
    --plot-outdir)
      PLOT_OUTDIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
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

if [[ "${TRACK}" != "greenfield" && "${TRACK}" != "canonical" ]]; then
  echo "Unsupported track: ${TRACK}" >&2
  exit 1
fi

resolve_canonical_toolchains() {
  local tiers="$1"
  ruby -ryaml -e '
    config = YAML.load_file(ARGV[0])
    tiers = ENV.fetch("TIERS").split(",").map(&:strip)
    toolchains = config.fetch("toolchains").select { |tc| tiers.include?(tc.fetch("tier")) }
    puts toolchains.map { |tc| tc.fetch("id") }.join(",")
  ' "${REPO_ROOT}/config/toolchains.yml"
}

resolve_legacy_install_toolchains() {
  ruby -e '
    mapping = {
      "python" => "python-uv",
      "python/mypy" => "python-uv",
      "rust" => "rust-cargo",
      "typescript" => "typescript-pnpm",
      "javascript" => "typescript-pnpm",
      "go" => "go-go",
      "java" => "java-maven",
      "ruby" => "ruby-bundler",
      "ruby/steep" => "ruby-bundler",
      "ocaml" => "ocaml-dune",
      "haskell" => "haskell-cabal",
      "scheme" => "scheme-guile",
      "perl" => "perl-raw",
      "lua" => "lua-raw"
    }
    langs = ENV.fetch("LANGS").split(",").map(&:strip)
    ids = langs.filter_map { |lang| mapping[lang] }.uniq
    puts ids.join(",")
  '
}

bootstrap_if_needed() {
  local env_file="${INSTALL_ROOT}/env.sh"
  local should_bootstrap=0

  case "${BOOTSTRAP_MODE}" in
    always)
      should_bootstrap=1
      ;;
    auto)
      [[ -f "${env_file}" ]] || should_bootstrap=1
      ;;
    never)
      should_bootstrap=0
      ;;
  esac

  if [[ "${should_bootstrap}" -eq 0 ]]; then
    return
  fi

  local install_args=(--install-root "${INSTALL_ROOT}")
  local resolved_toolchains=""

  if [[ "${TRACK}" == "canonical" ]]; then
    if [[ -n "${TOOLCHAINS}" ]]; then
      resolved_toolchains="${TOOLCHAINS}"
    elif [[ "${TIERS}" == "all" ]]; then
      install_args+=(--group all)
    elif [[ "${TIERS}" != *","* ]]; then
      install_args+=(--group "${TIERS}")
    else
      resolved_toolchains="$(TIERS="${TIERS}" resolve_canonical_toolchains "${TIERS}")"
    fi
  else
    if [[ -n "${LANGS}" ]]; then
      resolved_toolchains="$(LANGS="${LANGS}" resolve_legacy_install_toolchains)"
    fi
    if [[ -z "${resolved_toolchains}" ]]; then
      install_args+=(--group primary)
    fi
  fi

  if [[ -n "${resolved_toolchains}" ]]; then
    install_args+=(--toolchains "${resolved_toolchains}")
  fi

  "${INSTALL_SCRIPT}" "${install_args[@]}"
}

bootstrap_if_needed

ENV_FILE="${INSTALL_ROOT}/env.sh"
if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Environment file not found: ${ENV_FILE}" >&2
  echo "Run ${INSTALL_SCRIPT} first, or omit --no-bootstrap." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

benchmark_args=(ruby benchmark.rb --track "${TRACK}")

if [[ "${TRACK}" == "canonical" ]]; then
  if [[ -n "${TOOLCHAINS}" ]]; then
    benchmark_args+=(--toolchains "${TOOLCHAINS}")
  else
    benchmark_args+=(--tiers "${TIERS}")
  fi
else
  if [[ -n "${LANGS}" ]]; then
    benchmark_args+=(--lang "${LANGS}")
  fi
fi

[[ -n "${TRIALS}" ]] && benchmark_args+=(--trials "${TRIALS}")
[[ -n "${START}" ]] && benchmark_args+=(--start "${START}")
[[ -n "${SEED}" ]] && benchmark_args+=(--seed "${SEED}")
[[ "${DRY_RUN}" -eq 1 ]] && benchmark_args+=(--dry-run)

(
  cd "${REPO_ROOT}"
  "${benchmark_args[@]}"
)

if [[ "${DRY_RUN}" -eq 1 ]]; then
  exit 0
fi

if [[ "${RUN_REPORT}" -eq 1 ]]; then
  (
    cd "${REPO_ROOT}"
    ruby report.rb
  )
fi

if [[ "${RUN_PLOT}" -eq 1 ]]; then
  plot_args=(results/results.json)
  if [[ -n "${PLOT_TRACK}" ]]; then
    plot_args+=(--track "${PLOT_TRACK}")
  else
    plot_args+=(--track "${TRACK}")
  fi

  if [[ "${TRACK}" == "canonical" ]]; then
    if [[ -n "${PLOT_TIERS}" ]]; then
      plot_args+=(--tiers "${PLOT_TIERS}")
    elif [[ -z "${TOOLCHAINS}" ]]; then
      plot_args+=(--tiers "${TIERS}")
    fi
  fi

  [[ -n "${PLOT_OUTDIR}" ]] && plot_args+=(--outdir "${PLOT_OUTDIR}")

  (
    cd "${REPO_ROOT}"
    uv run \
      --with matplotlib \
      --with numpy \
      --with pandas \
      python3 plot.py "${plot_args[@]}"
  )
fi
