#!/usr/bin/env bash
set -euo pipefail

# Rollback production to previous tag quickly.
# Usage:
#   ./scripts/rollback-prod.sh v1.4.1

TARGET_TAG="${1:-}"
APP_DIR="${APP_DIR:-/srv/new-api/prod/current}"
SERVICE_NAME="${SERVICE_NAME:-new-api-prod}"

if [ -z "${TARGET_TAG}" ]; then
  echo "Usage: $0 <target_tag>"
  exit 1
fi

cd "${APP_DIR}"

echo "==> Fetch tags"
git fetch --tags

echo "==> Checkout tag ${TARGET_TAG}"
git checkout "tags/${TARGET_TAG}" -B rollback/"${TARGET_TAG}"

echo "==> Rebuild binary"
go build -o "${APP_DIR}/new-api-prod" ./main.go

echo "==> Restart service ${SERVICE_NAME}"
sudo systemctl restart "${SERVICE_NAME}"
sudo systemctl status "${SERVICE_NAME}" --no-pager -n 20

echo "Rollback finished to ${TARGET_TAG}."
