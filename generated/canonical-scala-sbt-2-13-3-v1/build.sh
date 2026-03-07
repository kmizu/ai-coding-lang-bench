#!/usr/bin/env bash
set -euo pipefail
sbt compile writeRuntimeClasspath
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cat > minigit <<EOF
#!/usr/bin/env bash
set -euo pipefail
CP="\$(cat '$SCRIPT_DIR/target/runtime-classpath.txt')"
exec java -cp "\$CP" minigit.Main "\$@"
EOF
chmod +x minigit
