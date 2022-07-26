<!-- markdownlint-disable MD033 -->
<h1>
    <img src="https://github.com/sighupio/fury-distribution/blob/master/docs/assets/fury-epta-white.png?raw=true" align="left" width="90" style="margin-right: 15px"/>
    Kubernetes Fury OPA
</h1>
<!-- markdownlint-enable MD033 -->

![Release](https://img.shields.io/github/v/release/sighupio/fury-kubernetes-opa?label=Latest%20Release)
![License](https://img.shields.io/github/license/sighupio/fury-kubernetes-opa?label=License)
![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)

<!-- <KFD-DOCS> -->

**Kubernetes Fury OPA** provides policy enforcement for the [Kubernetes Fury Distribution (KFD)][kfd-repo] using OPA Gatekeeper.

If you are new to KFD please refer to the [official documentation][kfd-docs] on how to get started with KFD.

## Overview

The Kubernetes API server provides a mechanism to review every request that is made, being object creation, modification or deletion. To use this mechanism the API server allows us to create a [Validating Admission Webhook][kubernetes-vaw-docs] that, as the name says, will validate every request and let the API server know if the request is allowed or not based on some logic (policy).

**Kubernetes Fury OPA** module is based on [OPA Gatekeeper][gatekeeper-page], a popular open-source Kubernetes-native policy engine with [OPA](https://www.openpolicyagent.org/) as its core that runs as a Validating Admission Webhook. It allows writing custom constraints (policies) in `rego` (a tailor-made language) as Kubernetes objects and enforcing them at runtime.

[SIGHUP][sighup-page] provides a set of base constraints that could be used both as a starting point to apply constraints to your current workloads or to give you an idea on how to implement new rules matching your requirements.

## Packages

Fury Kubernetes OPA provides the following packages:

| Package                                             | Version  | Description                                                       |
| --------------------------------------------------- | -------- | ----------------------------------------------------------------- |
| [Gatekeeper Core](katalog/gatekeeper/core)          | `v3.9.0` | Gatekeeper deployment, ready to apply rules.                      |
| [Gatekeeper Rules](katalog/gatekeeper/rules)        | `N.A.`   | A set of custom rules to get started.                             |
| [Gatekeeper Policy Manager](katalog/gatekeeper/gpm) | `v1.0.0` | Gatekeeper Policy Manager, a simple to use web-ui for Gatekeeper. |

Click on each package name to see its full documentation.

## Compatibility

| Kubernetes Version |   Compatibility    | Notes                                               |
| ------------------ | :----------------: | --------------------------------------------------- |
| `1.20.x`           | :white_check_mark: | No known issues                                     |
| `1.21.x`           | :white_check_mark: | No known issues                                     |
| `1.22.x`           | :white_check_mark: | No known issues                                     |
| `1.23.x`           |     :warning:      | Conformance tests passed. Not officially supported. |

Check the [compatibility matrix][compatibility-matrix] for additional information on previous releases of the module.

## Usage

### Prerequisites

| Tool                                    | Version    | Description                                                                                                                                                    |
| --------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [furyctl][furyctl-repo]                 | `>=0.6.0`  | The recommended tool to download and manage KFD modules and their packages. To learn more about `furyctl` read the [official documentation][furyctl-repo].     |
| [kustomize][kustomize-repo]             | `>=3.5.0`  | Packages are customized using `kustomize`. To learn how to create your customization layer with `kustomize`, please refer to the [repository][kustomize-repo]. |
| [KFD Monitoring Module][kfd-monitoring] | `>v1.10.0` | Expose metrics to Prometheus *(optional)*.                                                                                                                     |

> You can comment out the service monitor in the [kustomization.yaml][core-kustomization] file if you don't want to install the monitoring module.

### Deployment

1. List the packages you want to deploy and their version in a `Furyfile.yml`

```yaml
bases:
  - name: opa/gatekeeper
    version: "v1.6.2"
```

> See `furyctl` [documentation][furyctl-repo] for additional details about `Furyfile.yml` format.

2. Execute `furyctl vendor -H` to download the packages

3. Inspect the download packages under `./vendor/katalog/opa/gatekeeper`.

4. Define a `kustomization.yaml` that includes the `./vendor/katalog/opa/gatekeeper` directory as a resource.

```yaml
resources:
- ./vendor/katalog/opa/gatekeeper
```

5. Apply the necessary patches. You can find a list of common customization [here](#common-customizations).

6. To deploy the packages to your cluster, execute:

```bash
kustomize build . | kubectl apply -f -
```

> ⛔️ Gatekeeper is deployed by default as a Fail open (`Ignore` mode) Admission Webhook. Should you decide to change it to `Fail` mode read carefully [the project's documentation on the topic first][gatekeeper-failmode].
<!-- space left blank -->
> ⚠️ if you decide to deploy Gatekeeper to a different namespace than the default `gatekeeper-system`, you'll need to patch the file `vwh.yml` to point to the right namespace for the webhook service due to limitations in the `kustomize` tool.

### Common Customizations

#### Exempting a namespace

There are three points where you can exempt a namespace from Gatekeeper's policy enforcement:

1. The API webhook configuration & Gatekeeper's command flag (exempt at API server level)
2. Gatekeeper's configuration CRD (exempt at Gatekeeper global configuration level)
3. Constraint definition (exempt at constraint level)

Method `1` has the advantage that API requests for the namespace won't be sent to the webhook.

The following namespaces are already included as `--exempt-namespace` in the default deployment:

- `kube-node-lease`
- `kube-public`
- `kube-system`
- `gatekeeper-system`
- `monitoring`
- `logging`
- `ingress-nginx`
- `cert-manager`

To completely exempt one of them, label it with the following command:

```bash
kubectl label namespace <NAMESPACE> admission.gatekeeper.sh/ignore=yes
```

> ✋🏻 replace `<NAMESPACE>` with the namespace you want to exempt.

If you prefer, you can label all the namespaces at once (namespaces that are not exempted as flags won't be labeled because Gatekeeper will reject the request):

```bash
kubectl label namespace --all admission.gatekeeper.sh/ignore=yes
```

> ⚠️ please notice that exempting these namespaces [won't guarantee that the cluster will function properly with Gatekeeper webhook in `Fail` mode][gatekeeper-failmode].

For more details, head to the [official Gatekeeper documentation][gatekeeper-exemption].

#### Disable constraints

Disable one of the default constraints by creating the following kustomize patch:

```yml
patchesJson6902:
    - target:
          group: constraints.gatekeeper.sh
          version: v1beta1
          kind: K8sUniqueIngressHost # replace with the kind of the constraint you want to disable
          name: unique-ingress-host # replace with the name of the constraint you want to disable
      path: patches/allow.yml
```

add this to the `patches/allow.yml` file:

```yml
- op: "replace"
  path: "/spec/enforcementaction"
  value: "allow"
```

### Emergency brake

If for some reason OPA Gatekeeper is giving you issues and blocking normal operations in your cluster, you can disable it by removing the Validating Admission Webhook definition from your cluster:

```bash
kubectl delete ValidatingWebhookConfiguration gatekeeper-validating-webhook-configuration
```

<!-- Links -->
[gatekeeper-page]: https://github.com/open-policy-agent/gatekeeper
[gatekeeper-failmode]: https://open-policy-agent.github.io/gatekeeper/website/docs/failing-closed/
[gatekeeper-exemption]: https://open-policy-agent.github.io/gatekeeper/website/docs/exempt-namespaces/
[kubernetes-vaw-docs]: https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/
[kfd-monitoring]: https://github.com/sighupio/fury-kubernetes-monitoring
[core-kustomization]: ./katalog/gatekeeper/core/kustomization.yaml
[furyctl-repo]: https://github.com/sighupio/furyctl
[sighup-page]: https://sighup.io
[kfd-repo]: https://github.com/sighupio/fury-distribution
[kustomize-repo]: https://github.com/kubernetes-sigs/kustomize
[kfd-docs]: https://docs.kubernetesfury.com/docs/distribution/
[compatibility-matrix]: https://github.com/sighupio/fury-kubernetes-opa/blob/master/docs/COMPATIBILITY_MATRIX.md

<!-- </KFD-DOCS> -->

<!-- <FOOTER> -->

## Contributing

Before contributing, please read the [Contributing Guidelines](docs/CONTRIBUTING.md).

### Reporting Issues

In case you experience any problem with the module, please [open a new issue](https://github.com/sighupio/fury-kubernetes-opa/issues/new/choose).

## License

This module is open-source and it's released under the following [LICENSE](LICENSE)

<!-- </FOOTER> -->
