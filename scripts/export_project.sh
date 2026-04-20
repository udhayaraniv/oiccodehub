#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:?base url required}"
INSTANCE_NAME="${2:?instance name required}"
ACCESS_TOKEN="${3:?access token required}"
PROJECT_ID="${4:?project id required}"
PROJECT_LABEL="${5:-}"
OUTPUT_FILE="${6:?output file required}"

URL="${BASE_URL}/ic/api/integration/v1/projects/${PROJECT_ID}/archive?integrationInstance=${INSTANCE_NAME}"

TMP_BODY="$(mktemp)"
TMP_HEADERS="$(mktemp)"
TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_BODY" "$TMP_HEADERS" "$TMP_JSON"' EXIT

echo "Calling export endpoint for project: ${PROJECT_ID}"
echo "Using instance: ${INSTANCE_NAME}"
echo "URL: ${URL}"

if [ -n "${PROJECT_LABEL}" ]; then
  cat > "${TMP_JSON}" <<EOF
{
  "name": "${PROJECT_ID}",
  "code": "${PROJECT_ID}",
  "type": "DEVELOPED",
  "builtBy": "",
  "label": "${PROJECT_LABEL}"
}
EOF

  HTTP_CODE="$(curl -sS \
    -D "${TMP_HEADERS}" \
    -o "${TMP_BODY}" \
    -w "%{http_code}" \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Accept: application/octet-stream" \
    -H "Content-Type: application/json" \
    --data @"${TMP_JSON}" \
    "${URL}")"
else
  HTTP_CODE="$(curl -sS \
    -D "${TMP_HEADERS}" \
    -o "${TMP_BODY}" \
    -w "%{http_code}" \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Accept: application/octet-stream" \
    "${URL}")"
fi

echo "HTTP status: ${HTTP_CODE}"
echo "Response headers:"
sed -n '1,120p' "${TMP_HEADERS}"

if [ "${HTTP_CODE}" != "200" ]; then
  echo "Export failed. Response body:"
  cat "${TMP_BODY}"
  exit 1
fi

mv "${TMP_BODY}" "${OUTPUT_FILE}"
echo "Exported to ${OUTPUT_FILE}"
