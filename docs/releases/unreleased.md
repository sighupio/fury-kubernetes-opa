
# OPA Core Module Release TBD

Welcome to the latest release of `OPA` module of [Kubernetes Fury Distribution](https://github.com/sighupio/fury-distribution) maintained by team SIGHUP.

This is a major release updating the Gatekeeper package to the latest version upstream and fixing a bug in the provided ConstraintTemplates that made the audit not to trigger.

## Component Images 🚢

| Component                   | Supported Version                                                                     | Previous Version |
|-----------------------------|---------------------------------------------------------------------------------------|------------------|
| `gatekeeper`                | [`v3.8.1`](https://github.com/open-policy-agent/gatekeeper/releases/tag/v3.7.0)       | `v3.7.0`         |
| `gatekeeper-policy-manager` | [`v1.5.1`](https://github.com/sighupio/gatekeeper-policy-manager/releases/tag/v0.5.1) | `No update`      |

> Please refer the individual release notes to get a detailed info on the releases.

## Update Guide 🦮

### Warnings

- The `http.send` OPA built-in is now disabled. See: <https://open-policy-agent.github.io/gatekeeper/website/docs/externaldata#motivation>
- Enabled beta mutating capabilities. See: <https://open-policy-agent.github.io/gatekeeper/website/docs/mutation>

Upgrade from `v1.6.2` should be straight-forward and no downtime is expected.

### Process

To upgrade this core module from `v1.6.2` to `vTBD`, you need to download this new version, then apply the `kustomize` project. No further action is required.

```bash
kustomize build katalog/gatekeeper | kubectl apply -f -
```
