#!/usr/bin/env bash
set -euo pipefail
sbt compile writeRuntimeClasspath
cat > minigit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CP="$(cat "$DIR/target/runtime-classpath.txt")"
exec java -cp "$CP" minigit.Main "$@"
EOF
chmod +x minigit
