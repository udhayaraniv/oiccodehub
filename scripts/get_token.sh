#!/usr/bin/env bash
set -euo pipefail

TOKEN_URL="${1:?token url required}"
CLIENT_ID="${2:?client id required}"
CLIENT_SECRET="${3:?client secret required}"
SCOPE="${4:-}"

if [ -n "${SCOPE}" ]; then
  post_data="grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&scope=${SCOPE}"
else
  post_data="grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}"
fi

response="$(curl -sS -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "${post_data}" \
  "${TOKEN_URL}")"

access_token="$(echo "${response}" | jq -r '.access_token // empty')"

if [ -z "${access_token}" ]; then
  echo "Token request failed" >&2
  echo "${response}" >&2
  exit 1
fi

echo "${access_token}"
