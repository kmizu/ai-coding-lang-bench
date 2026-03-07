#!/usr/bin/env bash
set -euo pipefail
mvn -q -DskipTests compile
CLASSES_DIR="$(cd "$(dirname "$0")" && pwd)/target/classes"
cat > minigit <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec java -cp "$CLASSES_DIR" minigit.Main "\$@"
EOF
chmod +x minigit
