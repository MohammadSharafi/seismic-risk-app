#!/usr/bin/env bash
set -euo pipefail

baseUrl="http://34.229.182.170:8000"
uri="${baseUrl}/v1/chat/completions"
port=8000

# Optional prompt override: ./call_medgemma.sh "your question"
PROMPT="${1:-What are the common symptoms of type 2 diabetes?}"
export PROMPT

echo "Checking if ${baseUrl} is reachable..."

# Extract host (works for http://HOST:PORT or https://HOST:PORT)
hostOnly="${baseUrl#http://}"
hostOnly="${hostOnly#https://}"
hostOnly="${hostOnly%%:*}"

# 1) Quick TCP connectivity check (uses nc)
if command -v nc >/dev/null 2>&1; then
  if nc -vz -w 3 "$hostOnly" "$port" >/dev/null 2>&1; then
    echo "Port ${port} is open."
  else
    echo "Port ${port} is not reachable (timeout or refused)."
    echo "Ensure the server is running and reachable (firewall, VPN, correct IP)."
    exit 1
  fi
else
  echo "Error: 'nc' (netcat) not found. Install it or use the PowerShell (pwsh) option below."
  exit 1
fi

# 2) Build JSON body safely (needs python3 for proper JSON escaping)
if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 not found. Install python3 or replace JSON creation with a manual payload."
  exit 1
fi

body="$(python3 - <<'PY'
import json, os
prompt = os.environ["PROMPT"]
payload = {
  "model": "google/medgemma-27b-text-it",
  "messages": [{"role":"user","content": prompt}],
  "max_tokens": 512,
  "stream": False
}
print(json.dumps(payload))
PY
)"

echo "Calling API..."
resp="$(curl -sS -X POST "$uri" \
  -H "Content-Type: application/json" \
  --max-time 60 \
  -d "$body")"

# Pretty print if possible
if command -v python3 >/dev/null 2>&1; then
  echo "$resp" | python3 -m json.tool
else
  echo "$resp"
fi
