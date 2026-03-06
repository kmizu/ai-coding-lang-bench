# Repository Guidelines

## Project Structure & Module Organization
Core orchestration lives in `benchmark.rb`, report generation in `report.rb`, and plotting in `plot.py`. Canonical workflow definitions live in `config/toolchains.yml`, scaffold generation in `scripts/scaffold/`, and Ubuntu 24 setup scripts in `scripts/setup/ubuntu24/`. Task definitions and acceptance criteria live in `SPEC-v1.txt`, `SPEC-v2.txt`, `test-v1.sh`, and `test-v2.sh`. Committed outputs belong under `results/` and `figures/`. Transient benchmark runs may create `generated/` and `logs/`; keep those off `main` and use the orphan `data` branch for large generated artifacts.

## Build, Test, and Development Commands
Use the Ruby runner as the main entry point:

```bash
./scripts/run-canonical-all.sh --trials 1

./scripts/run-benchmark.sh --toolchains python-uv,rust-cargo --trials 1

bash scripts/setup/ubuntu24/install-toolchains.sh --group primary
source ~/.local/share/ai-coding-lang-bench/env.sh
ruby benchmark.rb --track greenfield --lang python --trials 1
ruby benchmark.rb --track canonical --toolchains python-uv,rust-cargo --trials 1
ruby benchmark.rb --track canonical --tiers primary,secondary --dry-run
ruby report.rb
python3 plot.py results/results.json --track canonical --tiers primary,secondary
```

`benchmark.rb` executes either the legacy `greenfield` track or the new `canonical` workflow track. `--dry-run` validates scaffold generation without calling Claude, `report.rb` rebuilds `results/report.md`, and `plot.py` regenerates `figures/*.png`. When validating a generated MiniGit implementation, run `bash test-v1.sh` or `bash test-v2.sh` inside that implementation directory.

## Coding Style & Naming Conventions
Match the surrounding language style instead of introducing a new one. Ruby files use 2-space indentation, `snake_case` methods, and uppercase constants (`LANGUAGES`, `RESULTS_DIR`). Python follows 4-space indentation, `snake_case`, and standard-library-first imports. Shell scripts should remain Bash with `set -e` and simple, portable commands. Prefer descriptive filenames with the existing hyphenated versioning pattern, such as `test-v2.sh` and `SPEC-v1.txt`.

## Testing Guidelines
There is no separate unit-test framework for the harness; the shell scripts are the contract. If you change MiniGit behavior, update both the relevant `SPEC-v*.txt` file and the matching `test-v*.sh`. For harness changes, run a focused dry run first, then a small real benchmark if the required toolchain is installed. Regenerate the report and plots after changing result formats.

## Commit & Pull Request Guidelines
Keep commit subjects short, imperative, and capitalized, matching recent history such as `Fix incorrect relative path in "log with no commits" test`. In pull requests, describe the benchmark impact, list touched scripts/specs, and mention regenerated artifacts when `results/` or `figures/` change. Include before/after notes for methodology changes so readers can judge comparability.

## Environment & Data Notes
Contributors need Ruby, Python 3, the `claude` CLI, and any language/toolchain pairs being benchmarked. Prefer `scripts/run-canonical-all.sh` when you want the default canonical suite in one shot, or `scripts/run-benchmark.sh` when you need custom workflow selection. Treat generated Claude logs as reproducibility data: useful, but often large. Avoid committing ad hoc run directories to `main`.

## Session Notes
2026-03-07: The benchmark was reworked to separate `greenfield` startup measurements from `canonical` workflow measurements, and to label weakly canonical Perl/Lua/Scheme entries as reference-only.
2026-03-07: Added `scripts/run-benchmark.sh` so Ubuntu 24 users can bootstrap toolchains, run benchmarks, rebuild reports, and regenerate plots with one command.
2026-03-07: Added `scripts/run-canonical-all.sh` so the default canonical suite can run end-to-end, and optionally stage or commit the generated benchmark artifacts in one command.
