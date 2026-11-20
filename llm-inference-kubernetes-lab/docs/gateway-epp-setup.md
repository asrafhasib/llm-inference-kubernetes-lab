# Gateway and EPP setup

The original lab used an inference gateway and EPP that were installed separately from the Qwen simulator Deployment. Their exact manifests/Helm values and gateway implementation are not fully represented in this repository, so this guide deliberately avoids publishing guessed YAML that might not match the tested release.

## Before you start

Record the versions and resources from your working cluster:

```bash
kubectl version
helm version
kubectl get gatewayclass
kubectl get gateway -A
kubectl get httproute -A
kubectl get inferencepool -A
kubectl get deploy,svc -A | grep -Ei 'gateway|epp|inference'
```

Save the exact upstream chart values and manifests used by your setup in this repository if licensing and project policy allow it. Remove tokens, credentials, private endpoints, and other sensitive values first.

## Version-matched upstream references

- llm-d documentation: https://llm-d.ai/docs/
- llm-d artifacts: https://llm-d.ai/docs/0.7/getting-started/artifacts
- Envoy AI Gateway integration guide: https://github.com/llm-d/llm-d/blob/main/docs/infrastructure/gateway/envoy-ai-gateway.md
- Gateway API Inference Extension: https://github.com/kubernetes-sigs/gateway-api-inference-extension
- llm-d Router: https://github.com/llm-d/llm-d-router

The upstream llm-d guides describe the Gateway API CRDs, gateway integration, InferencePool, and EPP deployment. Follow the instructions for the release that matches the cluster components you installed. Do not mix chart and CRD versions arbitrarily.

## Validate the request path

After deploying the gateway/EPP with the matching upstream guide:

```bash
kubectl get pods -A
kubectl get gateway -A
kubectl get httproute -A
kubectl get inferencepool -A
```

Inspect EPP logs while sending a request:

```bash
kubectl logs -n <EPP_NAMESPACE> deployment/<EPP_DEPLOYMENT> --since=5m -f
```

A log showing the EPP received a request and returned a routing response confirms EPP participation. It does not alone prove which backend Pod was selected. Correlate it with backend-specific metrics or logs.

## kind networking note

In kind, a Service of type `LoadBalancer` may show `EXTERNAL-IP: <pending>` unless a load-balancer integration is installed and configured. For a local lab, `kubectl port-forward` is a simple way to access the gateway Service.
