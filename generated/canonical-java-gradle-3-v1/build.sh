#!/usr/bin/env bash
set -euo pipefail
gradle -q classes writeRuntimeClasspath
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cat > minigit <<EOF
#!/usr/bin/env bash
set -euo pipefail
CP="\$(cat '$SCRIPT_DIR/build/runtime-classpath.txt')"
exec java -cp "\$CP" minigit.Main "\$@"
EOF
chmod +x minigit
