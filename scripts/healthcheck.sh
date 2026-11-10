#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 || -z "$1" || -z "$2" ]]; then
  echo "Использование: $0 <URL> <commit-sha>" >&2
  exit 2
fi
url="$1"
sha="${2:0:12}"
attempts="${ATTEMPTS:-12}"
delay="${DELAY:-10}"

body="$(mktemp)"
trap 'rm -f "$body"' EXIT
separator='?'
[[ "$url" == *'?'* ]] && separator='&'
for i in $(seq 1 "$attempts"); do
  code="$(curl --connect-timeout 10 --max-time 30 -sS -L -o "$body" -w '%{http_code}' "${url}${separator}hc=$(date +%s)")" || code=000
  if [[ "$code" == "200" ]] && grep -q "BUILD-STAMP commit=${sha}" "$body"; then
    echo "OK: $url -> HTTP $code, commit=$sha (попытка $i)"
    exit 0
  fi
  found="$(grep -o 'BUILD-STAMP commit=[a-z0-9]*' "$body" || echo 'метка не найдена')"
  echo "Попытка $i/$attempts: HTTP $code, $found; жду ${delay}s"
  if (( i < attempts )); then sleep "$delay"; fi
done

echo "FAIL: $url не отдаёт сборку $sha" >&2
exit 1
