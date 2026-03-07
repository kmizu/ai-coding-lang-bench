#!/usr/bin/env bash
set -euo pipefail
pnpm exec tsc --pretty false
cat > minigit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exec node dist/minigit.js "$@"
EOF
chmod +x minigit
