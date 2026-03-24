#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8080}"

# Always serve from this script's directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Starting EOL Explorer at http://localhost:${PORT}/index.html"
exec ruby -run -e httpd . -p "$PORT"
