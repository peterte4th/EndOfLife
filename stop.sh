#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8080}"

PIDS="$(lsof -ti tcp:"$PORT" || true)"

if [[ -z "$PIDS" ]]; then
  echo "No process found listening on port ${PORT}."
  exit 0
fi

echo "Stopping process(es) on port ${PORT}: $PIDS"
kill $PIDS

echo "Stopped."
