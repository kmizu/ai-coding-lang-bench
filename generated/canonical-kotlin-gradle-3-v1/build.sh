#!/usr/bin/env bash
set -euo pipefail
gradle -q classes writeRuntimeClasspath
DIR="$(cd "$(dirname "$0")" && pwd)"
cat > minigit <<EOF
#!/usr/bin/env bash
set -euo pipefail
CP="\$(cat '$DIR/build/runtime-classpath.txt')"
exec java -cp "\$CP" minigit.MainKt "\$@"
EOF
chmod +x minigit
