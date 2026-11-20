# Validation checklist

## Workload health

```bash
kubectl get pods -n llm-inference -o wide
kubectl rollout status deployment/qwen -n llm-inference
kubectl get svc -n llm-inference
```

Expected: three Qwen simulator Pods become Ready and `qwen-svc` has three ready endpoints.

## API request

```bash
curl -sS http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "demo/qwen3-0.6b",
    "messages": [{"role": "user", "content": "Hello from Kubernetes"}]
  }'
```

Expected: an OpenAI-compatible JSON response. This is a simulator response, not evidence of real model execution.

## EPP participation

- Check EPP logs during a request.
- Confirm that the EPP logs show request processing.
- Confirm the selected backend using per-Pod counters or backend access logs.
- Record counters before and after a test window.

## Load test

```bash
./scripts/check-pod-metrics.sh
REQUESTS=60 CONCURRENCY=12 GATEWAY_URL=http://localhost:8080 ./scripts/load-test.sh
./scripts/check-pod-metrics.sh
```

Record deltas, HTTP failures, test duration, and concurrency in `results/observed-results.md`.
