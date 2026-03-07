#!/usr/bin/env bash
set -euo pipefail
sbt compile writeRuntimeClasspath
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CP="$(cat "$SCRIPT_DIR/target/runtime-classpath.txt")"
cat > minigit <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec java -cp "$CP" minigit.Main "\$@"
EOF
chmod +x minigit
