#!/usr/bin/env bash
set -euo pipefail
sbt compile writeRuntimeClasspath
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CP_FILE="$SCRIPT_DIR/target/runtime-classpath.txt"
cat > minigit <<EOF
#!/usr/bin/env bash
set -euo pipefail
CP="\$(cat "$CP_FILE")"
exec java -cp "\$CP" minigit.Main "\$@"
EOF
chmod +x minigit
