#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl apply -f "${ROOT_DIR}/kubernetes/namespace.yaml"
kubectl apply -f "${ROOT_DIR}/kubernetes/qwen-deployment.yaml"
kubectl apply -f "${ROOT_DIR}/kubernetes/qwen-service.yaml"
kubectl rollout status deployment/qwen -n llm-inference --timeout=180s
echo
kubectl get pods,svc -n llm-inference -o wide
