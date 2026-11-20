# Architecture and request flow

## Components

- **Client:** sends an OpenAI-compatible inference request.
- **Inference Gateway:** accepts incoming HTTP traffic and forwards requests into the inference routing path.
- **HTTPRoute / InferencePool:** connects gateway traffic to the model-server pool.
- **Endpoint Picker (EPP):** selects a model-server endpoint according to the configured routing logic and available signals.
- **Qwen simulator Pods:** three replicas of the llm-d inference simulator.
- **Kubernetes Service:** provides a baseline endpoint abstraction for comparison.

## Request path

```text
Client
  |
  v
Inference Gateway
  |
  v
HTTPRoute -> InferencePool -> EPP
                             |
                 +-----------+-----------+
                 |           |           |
                 v           v           v
              Pod 1       Pod 2       Pod 3
```

The normal `qwen-svc` Service is a separate baseline path. Kubernetes Service balancing is connection/endpoint-oriented; it does not automatically inspect prompt tokens, prefix/KV cache locality, or inference queue state.

## Metrics

The lab inspected the per-Pod `vllm:request_success_total` counter. It is cumulative. Capture a baseline before each test and calculate:

```text
requests_served_during_test = counter_after - counter_before
```

Do not compare raw cumulative values as if they were counts from a single test batch.
