#!/usr/bin/env bash
set -euo pipefail
pnpm exec tsc --pretty false
DIST_DIR="$(cd "$(dirname "$0")" && pwd)/dist"
cat > minigit <<LAUNCHER
#!/usr/bin/env bash
set -euo pipefail
exec node "${DIST_DIR}/minigit.js" "\$@"
LAUNCHER
chmod +x minigit
