# Troubleshooting

## Gateway Service has `EXTERNAL-IP: <pending>`

This is common with kind if no LoadBalancer implementation is configured. Use:

```bash
kubectl port-forward -n <GATEWAY_NAMESPACE> svc/<GATEWAY_SERVICE> 8080:80
```

## Qwen Pods are not Ready

```bash
kubectl describe pods -n llm-inference -l app=qwen
kubectl logs -n llm-inference deployment/qwen --all-pods=true
kubectl get events -n llm-inference --sort-by=.lastTimestamp
```

Check image pull status and confirm the simulator image/tag is available.

## `InferencePool` or `Gateway` resource is unknown

The relevant CRD/controller may not be installed. Check:

```bash
kubectl get crd | grep -Ei 'inference|gateway'
kubectl get gatewayclass
```

Install the CRDs and gateway implementation using the version-matched upstream guide.

## Port-forward fails

Confirm the Service name and namespace:

```bash
kubectl get svc -A | grep -Ei 'gateway|inference'
kubectl get endpoints -A | grep -Ei 'gateway|inference'
```

## Metrics query returns no result

The metric name, port, or endpoint may differ by simulator version. Inspect the metrics endpoint directly:

```bash
kubectl get pods -n llm-inference -o wide
kubectl get --raw /api/v1/namespaces/llm-inference/pods/<POD_NAME>:8000/proxy/metrics | head
```

Update `scripts/check-pod-metrics.sh` if the endpoint differs.

## EPP logs show request processing but backend is unclear

EPP request/response logs alone do not identify the selected Pod. Correlate request IDs with backend logs or compare per-Pod request counter deltas.
