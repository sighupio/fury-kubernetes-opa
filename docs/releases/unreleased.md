# OPA Core Module version TBD

TBD

## Changelog

- Adds `excludeIstio` flag to:
  - `K8sLivenessProbe`
  - `K8sReadinessProbe`
  - `SecurityControls`

## Upgrade path

To upgrade this core module from `v1.2.1`, you need to download this new version, then apply the
`kustomize` project. No further action is required.

```bash
kustomize build katalog/gatekeeper | kubectl apply -f - --force
```
