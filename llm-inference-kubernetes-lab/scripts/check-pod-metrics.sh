#!/usr/bin/env bash
set -euo pipefail
NAMESPACE="${NAMESPACE:-llm-inference}"
LABEL_SELECTOR="${LABEL_SELECTOR:-app=qwen}"
METRIC="${METRIC:-vllm:request_success_total}"

echo "Pod request counters (cumulative): namespace=${NAMESPACE}, metric=${METRIC}"
for pod in $(kubectl get pods -n "$NAMESPACE" -l "$LABEL_SELECTOR" -o name); do
  name="${pod#pod/}"
  printf '\n--- %s ---\n' "$name"
  # This endpoint is exposed by the simulator in the lab. If your image/version
  # exposes metrics on a different port/path, adjust the command accordingly.
  kubectl get --raw "/api/v1/namespaces/${NAMESPACE}/pods/${name}:8000/proxy/metrics" \
    | grep -E "^${METRIC//:/\\:}" || true
done
