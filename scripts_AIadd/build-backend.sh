#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/build-backend.sh [output_binary]
# Example: ./scripts/build-backend.sh ./dist/new-api

OUTPUT="${1:-./dist/new-api}"
mkdir -p "$(dirname "${OUTPUT}")"

echo "==> Building backend binary to ${OUTPUT}"
go build -o "${OUTPUT}" ./main.go
echo "Build success."
