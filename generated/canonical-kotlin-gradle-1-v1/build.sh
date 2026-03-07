#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
gradle -q classes writeRuntimeClasspath
CP="$(cat build/runtime-classpath.txt)"
cat > minigit <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec java -cp "$CP" minigit.MainKt "\$@"
EOF
chmod +x minigit
