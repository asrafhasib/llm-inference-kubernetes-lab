# Observed lab results

These values are transcribed from the completed simulator lab session. They are illustrative observations from that run, not a benchmark or a guarantee of routing behavior.

## Workload

- Gateway Pod: `inference-gateway` — 1/1 Running
- Qwen simulator Deployment: 3/3 Running
- EPP Deployment: 1/1 Running
- Gateway Service: type `LoadBalancer`; external IP was `<pending>` in kind
- Model ID: `demo/qwen3-0.6b`

## Routing observations

| Test | Observation |
|---|---|
| Initial gateway request | Pod counters: Pod 1 = 0, Pod 2 = 0, Pod 3 = 1 |
| 10 long-prompt requests through gateway | Pod counters: Pod 1 = 0, Pod 2 = 10, Pod 3 = 1 |
| 10 requests through normal `qwen-svc` | Counter increments observed: Pod 1 +4, Pod 2 +0, Pod 3 +6 |
| 60 concurrent requests through gateway (`xargs -P 12`) | Final cumulative counters: 26, 30, 25 (total 81) |

**Important interpretation:** the final values 26, 30, and 25 are cumulative counters. They total 81 and include earlier traffic, so they must not be presented as the result of only the 60-request batch.

The observations show that the gateway/EPP path and the normal Service path can produce different backend distributions. A controlled benchmark should capture per-Pod counters immediately before and after each isolated test, use a fixed prompt/request body, and record errors and duration.

## EPP log evidence

The EPP logs included messages equivalent to:

- EPP received request
- EPP sent request body response(s) to proxy

with `modelName` and `targetModelName` set to `demo/qwen3-0.6b`.

This supports that EPP participated in request processing. Those messages alone do not prove which Pod was selected; backend metrics/logs are needed for that.
