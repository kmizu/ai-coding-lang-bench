#!/usr/bin/env bash
set -euo pipefail
lein uberjar
cat > minigit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exec java -jar "$(dirname "$0")/target/uberjar/minigit-standalone.jar" "$@"
EOF
chmod +x minigit
