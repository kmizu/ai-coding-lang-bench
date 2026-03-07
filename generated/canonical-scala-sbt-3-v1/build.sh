#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
sbt --batch compile writeRuntimeClasspath
CP="$(cat "$SCRIPT_DIR/target/runtime-classpath.txt")"
cat > "$SCRIPT_DIR/minigit" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec java -cp "$CP" minigit.Main "\$@"
EOF
chmod +x "$SCRIPT_DIR/minigit"
