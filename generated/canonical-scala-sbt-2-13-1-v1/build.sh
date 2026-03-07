#!/usr/bin/env bash
set -euo pipefail
sbt compile writeRuntimeClasspath
cat > minigit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CP="$(cat "$SCRIPT_DIR/target/runtime-classpath.txt")"
exec java -cp "$CP" minigit.Main "$@"
EOF
chmod +x minigit
