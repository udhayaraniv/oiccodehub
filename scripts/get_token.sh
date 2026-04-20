#!/usr/bin/env bash
set -euo pipefail

TOKEN_URL="${1:?token url required}"
CLIENT_ID="${2:?client id required}"
CLIENT_SECRET="${3:?client secret required}"

response="$(curl -sS -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}" \
  "${TOKEN_URL}")"

access_token="$(echo "${response}" | jq -r '.access_token')"

if [ -z "${access_token}" ] || [ "${access_token}" = "null" ]; then
  echo "Failed to obtain access token"
  echo "${response}"
  exit 1
fi

echo "${access_token}"
