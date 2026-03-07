#!/usr/bin/env bash
set -euo pipefail
mvn -q -DskipTests compile
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
cat > minigit <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec java -cp "$SCRIPT_DIR/target/classes" minigit.Main "\$@"
EOF
chmod +x minigit
