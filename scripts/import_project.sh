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

URL="${BASE_URL}/ic/api/integration/v1/projects/archive?integrationInstance=${INSTANCE_NAME}"

TMP_BODY="$(mktemp)"
TMP_HEADERS="$(mktemp)"
trap 'rm -f "$TMP_BODY" "$TMP_HEADERS"' EXIT

echo "Calling import endpoint"
echo "Using instance: ${INSTANCE_NAME}"
echo "URL: ${URL}"
echo "Archive file: ${CAR_FILE}"

HTTP_CODE="$(curl -sS \
  -D "${TMP_HEADERS}" \
  -o "${TMP_BODY}" \
  -w "%{http_code}" \
  -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Accept: application/json" \
  -F "file=@${CAR_FILE}" \
  -F "type=application/octet-stream" \
  "${URL}")"

echo "HTTP status: ${HTTP_CODE}"
echo "Response headers:"
sed -n '1,120p' "${TMP_HEADERS}"

if [ "${HTTP_CODE}" != "200" ] && [ "${HTTP_CODE}" != "204" ]; then
  echo "Import failed. Response body:"
  cat "${TMP_BODY}"
  exit 1
fi

if [ -s "${TMP_BODY}" ]; then
  echo "Response body:"
  cat "${TMP_BODY}"
fi

echo "Import completed for ${CAR_FILE}"
