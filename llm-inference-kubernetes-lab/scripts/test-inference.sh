#!/usr/bin/env bash
set -euo pipefail
GATEWAY_URL="${GATEWAY_URL:-http://localhost:8080}"
MODEL="${MODEL:-demo/qwen3-0.6b}"
PROMPT="${PROMPT:-Explain what an inference gateway does in two sentences.}"
curl --fail-with-body -sS "${GATEWAY_URL}/v1/chat/completions" \
  -H 'Content-Type: application/json' \
  -d "$(jq -n --arg model "$MODEL" --arg prompt "$PROMPT" \
    '{model:$model,messages:[{role:"user",content:$prompt}]}')" \
  | { if command -v jq >/dev/null 2>&1; then jq .; else cat; fi; }
