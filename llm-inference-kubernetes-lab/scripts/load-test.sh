#!/usr/bin/env bash
set -euo pipefail
GATEWAY_URL="${GATEWAY_URL:-http://localhost:8080}"
MODEL="${MODEL:-demo/qwen3-0.6b}"
REQUESTS="${REQUESTS:-60}"
CONCURRENCY="${CONCURRENCY:-12}"
PROMPT="${PROMPT:-Describe Kubernetes scheduling in a concise paragraph.}"

command -v xargs >/dev/null
command -v curl >/dev/null
if ! [[ "$REQUESTS" =~ ^[0-9]+$ && "$CONCURRENCY" =~ ^[0-9]+$ ]] || (( REQUESTS < 1 || CONCURRENCY < 1 )); then
  echo "REQUESTS and CONCURRENCY must be positive integers" >&2
  exit 1
fi

export GATEWAY_URL MODEL PROMPT
seq 1 "$REQUESTS" | xargs -P "$CONCURRENCY" -I '{}' bash -c '
  code=$(curl -sS -o /dev/null -w "%{http_code}" \
    "${GATEWAY_URL}/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d "$(printf "{\"model\":\"%s\",\"messages\":[{\"role\":\"user\",\"content\":\"%s\"}]}" "$MODEL" "$PROMPT")") || exit 1
  printf "request=%s http_status=%s\n" "$1" "$code"
  [[ "$code" == "200" ]]
' _ '{}'
