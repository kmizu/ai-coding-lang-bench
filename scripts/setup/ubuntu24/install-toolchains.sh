#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
# shellcheck source=./versions.sh
source "${SCRIPT_DIR}/versions.sh"

if [[ "${EUID}" -eq 0 ]]; then
  DEFAULT_INSTALL_ROOT="/opt/ai-coding-lang-bench"
else
  DEFAULT_INSTALL_ROOT="${HOME}/.local/share/ai-coding-lang-bench"
fi

INSTALL_ROOT="${INSTALL_ROOT:-${DEFAULT_INSTALL_ROOT}}"
GROUP="primary"
TOOLCHAINS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --group)
      GROUP="$2"
      shift 2
      ;;
    --toolchains)
      TOOLCHAINS="$2"
      shift 2
      ;;
    --install-root)
      INSTALL_ROOT="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "${REPO_ROOT}/config/toolchains.yml" ]]; then
  echo "config/toolchains.yml not found" >&2
  exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

env_file="${INSTALL_ROOT}/env.sh"

apt_install() {
  ${SUDO} apt-get update
  ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

install_adoptium_jdk() {
  if command -v java >/dev/null 2>&1 && java --version 2>&1 | grep -q "25."; then
    return
  fi

  apt_install ca-certificates curl gpg wget
  if [[ ! -f /usr/share/keyrings/adoptium.gpg ]]; then
    wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public | ${SUDO} gpg --dearmor -o /usr/share/keyrings/adoptium.gpg
  fi
  if [[ ! -f /etc/apt/sources.list.d/adoptium.list ]]; then
    . /etc/os-release
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb ${VERSION_CODENAME} main" | ${SUDO} tee /etc/apt/sources.list.d/adoptium.list >/dev/null
  fi
  ${SUDO} apt-get update
  ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y "temurin-${JDK_MAJOR}-jdk"
}

install_node() {
  local node_dir="${INSTALL_ROOT}/node-v${NODE_VERSION}-linux-x64"
  if [[ -x "${node_dir}/bin/node" ]]; then
    return
  fi

  apt_install xz-utils
  curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o "${INSTALL_ROOT}/dist/node-v${NODE_VERSION}-linux-x64.tar.xz"
  tar -C "${INSTALL_ROOT}" -xf "${INSTALL_ROOT}/dist/node-v${NODE_VERSION}-linux-x64.tar.xz"
  "${node_dir}/bin/corepack" enable
  "${node_dir}/bin/corepack" install -g pnpm@latest
}

install_uv() {
  if [[ -x "${INSTALL_ROOT}/uv-bin/uv" ]]; then
    return
  fi

  mkdir -p "${INSTALL_ROOT}/uv-bin"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL="${INSTALL_ROOT}/uv-bin" sh
}

install_bun() {
  if [[ -x "${INSTALL_ROOT}/bun/bin/bun" ]]; then
    return
  fi

  apt_install unzip
  curl -fsSL https://bun.com/install | env BUN_INSTALL="${INSTALL_ROOT}/bun" bash
}

install_rust() {
  if [[ -x "${INSTALL_ROOT}/cargo/bin/cargo" ]]; then
    return
  fi

  apt_install build-essential pkg-config libssl-dev
  curl https://sh.rustup.rs -sSf | env CARGO_HOME="${INSTALL_ROOT}/cargo" RUSTUP_HOME="${INSTALL_ROOT}/rustup" sh -s -- -y --profile minimal --default-toolchain stable
}

install_go() {
  local go_dir="${INSTALL_ROOT}/go"
  if [[ -x "${go_dir}/bin/go" ]] && "${go_dir}/bin/go" version | grep -q "go${GO_VERSION}"; then
    return
  fi

  rm -rf "${go_dir}"
  curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o "${INSTALL_ROOT}/dist/go${GO_VERSION}.linux-amd64.tar.gz"
  tar -C "${INSTALL_ROOT}" -xzf "${INSTALL_ROOT}/dist/go${GO_VERSION}.linux-amd64.tar.gz"
}

install_maven() {
  local dir="${INSTALL_ROOT}/apache-maven-${MAVEN_VERSION}"
  if [[ -x "${dir}/bin/mvn" ]]; then
    return
  fi

  curl -fsSL "https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/${MAVEN_VERSION}/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -o "${INSTALL_ROOT}/dist/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
  tar -C "${INSTALL_ROOT}" -xzf "${INSTALL_ROOT}/dist/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
}

install_gradle() {
  local dir="${INSTALL_ROOT}/gradle-${GRADLE_VERSION}"
  if [[ -x "${dir}/bin/gradle" ]]; then
    return
  fi

  apt_install unzip
  curl -fsSL "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -o "${INSTALL_ROOT}/dist/gradle-${GRADLE_VERSION}-bin.zip"
  unzip -q -o "${INSTALL_ROOT}/dist/gradle-${GRADLE_VERSION}-bin.zip" -d "${INSTALL_ROOT}"
}

install_sbt() {
  local dir="${INSTALL_ROOT}/sbt-${SBT_VERSION}"
  if [[ -x "${dir}/bin/sbt" ]]; then
    return
  fi

  curl -fsSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" -o "${INSTALL_ROOT}/dist/sbt-${SBT_VERSION}.tgz"
  tar -C "${INSTALL_ROOT}" -xzf "${INSTALL_ROOT}/dist/sbt-${SBT_VERSION}.tgz"
  mv "${INSTALL_ROOT}/sbt" "${dir}"
}

install_scala_cli() {
  if [[ -x "${INSTALL_ROOT}/bin/scala-cli" ]]; then
    return
  fi

  curl -fL https://github.com/VirtusLab/scala-cli/releases/latest/download/scala-cli-x86_64-pc-linux.gz | gzip -d > "${INSTALL_ROOT}/bin/scala-cli"
  chmod +x "${INSTALL_ROOT}/bin/scala-cli"
}

install_ocaml_dune() {
  apt_install bubblewrap darcs git m4 opam pkg-config rsync unzip

  export OPAMROOT="${INSTALL_ROOT}/opam"
  mkdir -p "${OPAMROOT}"
  if [[ ! -f "${OPAMROOT}/config" ]]; then
    opam init --disable-sandboxing --yes --bare default https://opam.ocaml.org
  fi
  if ! opam switch show --root="${OPAMROOT}" 2>/dev/null | grep -q '^default$'; then
    opam switch create default ocaml-base-compiler.5.3.0 --root="${OPAMROOT}" --yes
  fi
  eval "$(opam env --root="${OPAMROOT}" --switch=default --set-root --set-switch)"
  opam install --yes "dune.3.21.0"
}

install_haskell() {
  apt_install binutils build-essential curl g++ gcc libffi-dev libgmp-dev libncurses-dev libncurses5-dev libtinfo-dev make xz-utils zlib1g-dev

  export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
  export BOOTSTRAP_HASKELL_MINIMAL=1
  export BOOTSTRAP_HASKELL_INSTALL_STACK=0
  export BOOTSTRAP_HASKELL_INSTALL_HLS=0
  export GHCUP_INSTALL_BASE_PREFIX="${INSTALL_ROOT}"
  if [[ ! -x "${INSTALL_ROOT}/.ghcup/bin/ghcup" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
  fi
  export PATH="${INSTALL_ROOT}/.ghcup/bin:${PATH}"
  ghcup install ghc recommended --set
  ghcup install cabal recommended --set
}

install_dotnet() {
  local dotnet_dir="${INSTALL_ROOT}/dotnet"
  if [[ -x "${dotnet_dir}/dotnet" ]]; then
    return
  fi

  mkdir -p "${dotnet_dir}"
  curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel "${DOTNET_CHANNEL}" --install-dir "${dotnet_dir}"
}

install_leiningen() {
  if [[ -x "${INSTALL_ROOT}/bin/lein" ]]; then
    return
  fi

  curl -fsSL "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein" -o "${INSTALL_ROOT}/bin/lein"
  chmod +x "${INSTALL_ROOT}/bin/lein"
  # Trigger self-install (downloads standalone JAR)
  "${INSTALL_ROOT}/bin/lein" version
}

install_reference_packages() {
  apt_install guile-3.0 lua5.4 perl
}

write_env_file() {
  local java_home
  java_home="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
  cat > "${env_file}" <<EOF
export BENCH_TOOLCHAINS_ROOT="${INSTALL_ROOT}"
export JAVA_HOME="${java_home}"
export CARGO_HOME="${INSTALL_ROOT}/cargo"
export RUSTUP_HOME="${INSTALL_ROOT}/rustup"
export OPAMROOT="${INSTALL_ROOT}/opam"
export PATH="${INSTALL_ROOT}/dotnet:${INSTALL_ROOT}/uv-bin:${INSTALL_ROOT}/bun/bin:${INSTALL_ROOT}/bin:${INSTALL_ROOT}/go/bin:${INSTALL_ROOT}/node-v${NODE_VERSION}-linux-x64/bin:${INSTALL_ROOT}/apache-maven-${MAVEN_VERSION}/bin:${INSTALL_ROOT}/gradle-${GRADLE_VERSION}/bin:${INSTALL_ROOT}/sbt-${SBT_VERSION}/bin:${INSTALL_ROOT}/cargo/bin:${INSTALL_ROOT}/.ghcup/bin:${INSTALL_ROOT}/opam/default/bin:\$PATH"
EOF
}

select_toolchains() {
  ruby -ryaml -e '
    config = YAML.load_file(ARGV[0])
    toolchains = config.fetch("toolchains")
    ids = ENV["TOOLCHAINS"].to_s.split(",").map(&:strip).reject(&:empty?)
    group = ENV.fetch("GROUP")
    selected =
      if ids.empty?
        case group
        when "primary", "secondary", "reference"
          toolchains.select { |tc| tc["tier"] == group }
        when "all"
          toolchains
        else
          abort("Unknown group: #{group}")
        end
      else
        toolchains.select { |tc| ids.include?(tc["id"]) }
      end
    puts selected.map { |tc| tc["id"] }
  ' "${REPO_ROOT}/config/toolchains.yml"
}

ensure_common_packages() {
  apt_install bash build-essential curl git gzip tar unzip zip
}

main() {
  if [[ ! -d "${INSTALL_ROOT}" ]]; then
    mkdir -p "${INSTALL_ROOT}/bin" "${INSTALL_ROOT}/dist" "${INSTALL_ROOT}/state"
  fi

  if [[ ! -w "${INSTALL_ROOT}" ]]; then
    echo "Install root is not writable: ${INSTALL_ROOT}" >&2
    echo "Run with sudo, or choose a user-writable path via --install-root." >&2
    exit 1
  fi

  ensure_common_packages

  mapfile -t selected < <(GROUP="${GROUP}" TOOLCHAINS="${TOOLCHAINS}" select_toolchains)
  if [[ ${#selected[@]} -eq 0 ]]; then
    echo "No toolchains selected" >&2
    exit 1
  fi

  install_adoptium_jdk

  for id in "${selected[@]}"; do
    case "${id}" in
      python-uv)
        install_uv
        ;;
      rust-cargo)
        install_rust
        ;;
      typescript-pnpm|typescript-bun)
        install_node
        [[ "${id}" == "typescript-bun" ]] && install_bun
        ;;
      go-go)
        install_go
        ;;
      java-maven|kotlin-maven)
        install_maven
        ;;
      ruby-bundler)
        apt_install ruby-full
        ;;
      scala-sbt)
        install_maven
        install_sbt
        ;;
      scala-scala-cli)
        install_scala_cli
        ;;
      kotlin-gradle|java-gradle)
        install_gradle
        ;;
      fsharp-dotnet)
        install_dotnet
        ;;
      clojure-lein)
        install_leiningen
        ;;
      ocaml-dune)
        install_ocaml_dune
        ;;
      haskell-cabal)
        install_haskell
        ;;
      scheme-guile|perl-raw|lua-raw)
        install_reference_packages
        ;;
      *)
        echo "No installer registered for ${id}" >&2
        ;;
    esac
  done

  write_env_file
  echo "Toolchains installed. Source ${env_file} before running the benchmark."
}

main "$@"
