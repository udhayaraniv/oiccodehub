#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:?base url required}"
INSTANCE_NAME="${2:?instance name required}"
ACCESS_TOKEN="${3:?access token required}"
CAR_FILE="${4:?car file required}"

if [ ! -f "${CAR_FILE}" ]; then
  echo "File not found: ${CAR_FILE}"
  exit 1
fi

curl -sS -f -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Accept: application/json" \
  -F "file=@${CAR_FILE}" \
  -F "type=application/octet-stream" \
  "${BASE_URL}/ic/api/integration/v1/projects/archive?integrationInstance=${INSTANCE_NAME}"

echo
echo "Import completed for ${CAR_FILE}"
