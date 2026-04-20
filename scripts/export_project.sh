#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:?base url required}"
INSTANCE_NAME="${2:?instance name required}"
ACCESS_TOKEN="${3:?access token required}"
PROJECT_ID="${4:?project id required}"
PROJECT_LABEL="${5:-}"
OUTPUT_FILE="${6:?output file required}"

TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT

if [ -n "${PROJECT_LABEL}" ]; then
  cat > "${TMP_JSON}" <<EOF
{
  "label": "${PROJECT_LABEL}"
}
EOF

  curl -sS -f -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Accept: application/octet-stream" \
    -H "Content-Type: application/json" \
    --data @"${TMP_JSON}" \
    "${BASE_URL}/ic/api/integration/v1/projects/${PROJECT_ID}/archive?integrationInstance=${INSTANCE_NAME}" \
    -o "${OUTPUT_FILE}"
else
  curl -sS -f -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Accept: application/octet-stream" \
    -H "Content-Type: application/json" \
    --data '{}' \
    "${BASE_URL}/ic/api/integration/v1/projects/${PROJECT_ID}/archive?integrationInstance=${INSTANCE_NAME}" \
    -o "${OUTPUT_FILE}"
fi

echo "Exported to ${OUTPUT_FILE}"
