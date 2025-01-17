# OPA Core Module Release vTBD

Welcome to the latest release of `OPA` module of [Kubernetes Fury Distribution](https://github.com/sighupio/fury-distribution) maintained by team SIGHUP.

This is a minor release including the following changes:

- [[#114]](https://github.com/sighupio/fury-kubernetes-opa/pull/114) Add kapp `rebaseRule` configuration to avoid replacing Gatekeeper's webhook TLS secret content. Notice that this change applies only when using the module trough `furyctl apply`.

## Component Images 🚢

| Component                   | Supported Version                                                                       | Previous Version |
| --------------------------- | --------------------------------------------------------------------------------------- | ---------------- |
| `gatekeeper`                | [`v3.17.1`](https://github.com/open-policy-agent/gatekeeper/releases/tag/v3.15.1)       | ``               |
| `gatekeeper-policy-manager` | [`v1.0.13`](https://github.com/sighupio/gatekeeper-policy-manager/releases/tag/v1.0.13) | ``               |
| `kyverno`                   | [`v1.12.6`](https://github.com/kyverno/kyverno/releases/tag/v1.12.6)                    | ``               |

> Please refer the individual release notes to get a detailed information on each release.

## Update Guide 🦮

### Process

To upgrade this core module from `v1.13.0` to `vTBD`, you need to download this new version, then apply the `kustomize` project. No further action is required.

```bash
kustomize build katalog/gatekeeper | kubectl apply -f -
```
