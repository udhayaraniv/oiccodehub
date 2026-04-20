#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:?base url required}"
INSTANCE_NAME="${2:?instance name required}"
ACCESS_TOKEN="${3:?access token required}"
PROJECT_ID="${4:?project id required}"
PROJECT_LABEL="${5:-}"
OUTPUT_FILE="${6:?output file required}"

GET_URL="${BASE_URL}/ic/api/integration/v1/projects/${PROJECT_ID}?integrationInstance=${INSTANCE_NAME}"
EXPORT_URL="${BASE_URL}/ic/api/integration/v1/projects/${PROJECT_ID}/archive?integrationInstance=${INSTANCE_NAME}"

TMP_PROJECT="$(mktemp)"
TMP_EXPORT_BODY="$(mktemp)"
TMP_HEADERS="$(mktemp)"
TMP_RESPONSE="$(mktemp)"
trap 'rm -f "$TMP_PROJECT" "$TMP_EXPORT_BODY" "$TMP_HEADERS" "$TMP_RESPONSE"' EXIT

echo "Retrieving project metadata for: ${PROJECT_ID}"

PROJECT_HTTP_CODE="$(curl -sS \
  -o "${TMP_PROJECT}" \
  -w "%{http_code}" \
  -X GET \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Accept: application/json" \
  "${GET_URL}")"

echo "Retrieve project HTTP status: ${PROJECT_HTTP_CODE}"

if [ "${PROJECT_HTTP_CODE}" != "200" ]; then
  echo "Failed to retrieve project metadata"
  cat "${TMP_PROJECT}"
  exit 1
fi

PROJECT_NAME="$(jq -r '.name // .code // empty' "${TMP_PROJECT}")"
PROJECT_CODE="$(jq -r '.code // empty' "${TMP_PROJECT}")"
PROJECT_TYPE="$(jq -r '.type // empty' "${TMP_PROJECT}")"
PROJECT_BUILT_BY="$(jq -r '."built-by" // .builtBy // ""' "${TMP_PROJECT}")"

echo "Project name: ${PROJECT_NAME}"
echo "Project code: ${PROJECT_CODE}"
echo "Project type: ${PROJECT_TYPE}"
echo "Project built-by: ${PROJECT_BUILT_BY}"

if [ -z "${PROJECT_CODE}" ] || [ "${PROJECT_CODE}" = "null" ]; then
  echo "Project code is missing in retrieve-project response"
  cat "${TMP_PROJECT}"
  exit 1
fi

if [ -z "${PROJECT_TYPE}" ] || [ "${PROJECT_TYPE}" = "null" ]; then
  echo "Project type is missing in retrieve-project response"
  cat "${TMP_PROJECT}"
  exit 1
fi

if [ -n "${PROJECT_LABEL}" ]; then
  jq -n \
    --arg name "${PROJECT_NAME}" \
    --arg code "${PROJECT_CODE}" \
    --arg type "${PROJECT_TYPE}" \
    --arg builtBy "${PROJECT_BUILT_BY}" \
    --arg label "${PROJECT_LABEL}" \
    '{
      name: $name,
      code: $code,
      type: $type,
      builtBy: $builtBy,
      label: $label
    }' > "${TMP_EXPORT_BODY}"
else
  jq -n \
    --arg name "${PROJECT_NAME}" \
    --arg code "${PROJECT_CODE}" \
    --arg type "${PROJECT_TYPE}" \
    --arg builtBy "${PROJECT_BUILT_BY}" \
    '{
      name: $name,
      code: $code,
      type: $type,
      builtBy: $builtBy
    }' > "${TMP_EXPORT_BODY}"
fi

echo "Export payload:"
cat "${TMP_EXPORT_BODY}"

EXPORT_HTTP_CODE="$(curl -sS \
  -D "${TMP_HEADERS}" \
  -o "${TMP_RESPONSE}" \
  -w "%{http_code}" \
  -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  --data @"${TMP_EXPORT_BODY}" \
  "${EXPORT_URL}")"

echo "Export HTTP status: ${EXPORT_HTTP_CODE}"
echo "Response headers:"
sed -n '1,120p' "${TMP_HEADERS}"

if [ "${EXPORT_HTTP_CODE}" != "200" ]; then
  echo "Export failed. Response body:"
  cat "${TMP_RESPONSE}"
  exit 1
fi

mv "${TMP_RESPONSE}" "${OUTPUT_FILE}"
echo "Exported to ${OUTPUT_FILE}"
