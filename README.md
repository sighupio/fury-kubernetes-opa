<h1>
    <img src="https://github.com/sighupio/fury-distribution/blob/master/docs/assets/fury-epta-white.png?raw=true" align="left" width="90" style="margin-right: 15px"/>
    Kubernetes Fury OPA
</h1>

![Release](https://img.shields.io/github/v/release/sighupio/fury-kubernetes-opa?label=Latest%20Release)
![License](https://img.shields.io/github/license/sighupio/fury-kubernetes-opa?label=License)
![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)

<!-- <KFD-DOCS> -->

**Kubernetes Fury OPA** provides a policy engine based on OPA Gatekeeper to enable enforcement of custom policies in a Kubernetes Cluster for the [Kubernetes Fury Distribution (KFD)][kfd-repo] via a [Validating Admission Webhook][kubernetes-vaw-docs].

If you are new to KFD please refer to the [official documentation][kfd-docs] on how to get started with KFD.

## Overview

The Kubernetes API server provides a mechanism to review every request that is made, being objects creation, modification or deletion. To use this mechanism the API server allow us to create a [Validating Admission Webhook][kubernetes-vaw-docs] that, as the name says, will validate every requests and let the API server know if the request is allowed or not based on some logic (policy).

**Kubernetes Fury OPA** module is based on [OPA Gatekeeper][gatekeeper-page], a popular open-source Kubernetes-native policy engine with [OPA](https://www.openpolicyagent.org/) as its core that runs as a Validating Admission Webhook. It allows writing custom constraints (policies) in `rego` (a tailor-made language) as Kubernetes objects and enforce at runtime.

[SIGHUP][sighup-page] provides a set of base constraints that could be used both as a starting point to apply constraints to your current workloads or to give you an idea on how to implement new rules matching your requirements.

## Packages

Fury Kubernetes OPA provides the following packages:

| Package                                             | Version  | Description                                                                      |
|-----------------------------------------------------|----------|----------------------------------------------------------------------------------|
| [Gatekeeper Core](katalog/gatekeeper/core)          | `v3.7.0` | Gatekeeper deployment, ready to apply rules.                                     |
| [Gatekeeper Rules](katalog/gatekeeper/rules)        | `N.A.`   | A set of custom rules to get started. See the package documentation for details. |
| [Gatekeeper Policy Manager](katalog/gatekeeper/gpm) | `v0.5.1` | Gatekeeper Policy Manager, a simple to use web-ui for Gatekeeper.                |

Click on each package to see its full documentation.

## Compatibility

| Kubernetes Version |   Compatibility    |                        Notes                        |
| ------------------ | :----------------: | --------------------------------------------------- |
| `1.20.x`           | :white_check_mark: | No known issues                                     |
| `1.21.x`           | :white_check_mark: | No known issues                                     |
| `1.22.x`           | :white_check_mark: | No known issues                                     |
| `1.23.x`           |     :warning:      | Conformance tests passed. Not officially supported. |

Check the [compatibility matrix][compatibility-matrix] for additional informations about previous releases of the modules.

## Usage

### Prerequisites

|            Tool             |  Version  |                                                                          Description                                                                           |
| --------------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [furyctl][furyctl-repo]     | `>=0.6.0` | The recommended tool to download and manage KFD modules and their packages. To learn more about `furyctl` read the [official documentation][furyctl-repo]. |
| [kustomize][kustomize-repo] | `>=3.5.0` | Packages are customized using `kustomize`. To learn how to create your customization layer with `kustomize`, please refer to the [repository][kustomize-repo]. |
| [KFD Monitoring Module][kfd-monitoring] | `>v1.10.0` | Expose metrics to Prometheus *(optional)* |

> You can comment out the service monitor in the [kustomization.yaml][core-kustomization] file if you don't want to install the monitoring module.

#### Resources

Gatekeeper core package gets deployed by default with the following resource limits:

- CPU: 1000m
- Memory: 512Mi

Gatekeeper Policy Manager package gets deployed by default with the following resource limits:

- CPU: 500m
- Memory: 256Mi

### Deployment

1. List the packages you want to deploy and their version in a `Furyfile.yml`

```yaml
bases:
  - name: opa/gatekeeper
    version: "v1.6.0"
```

> See `furyctl` [documentation][furyctl-repo] for additional details about `Furyfile.yml` format.

1. Execute `furyctl vendor -H` to download the packages

1. Inspect the download packages under `./vendor/katalog/opa/gatekeeper`.

1. Define a `kustomization.yaml` that includes the `./vendor/katalog/opa/gatekeeper` directory as resource.

```yaml
resources:
- ./vendor/katalog/opa/gatekeeper
```

1. Apply the necessary patches. You can find a list of common customization [here](#common-customizations).

1. To deploy the packages to your cluster, execute:

```bash
kustomize build . | kubectl apply -f -
```

### Common Customizations

#### Disable constraints

If you need to disable one of the constraints thats provided by default,
you can do it by creating a kustomize patch like the following:

```yml
patchesJson6902:
    - target:
          group: constraints.gatekeeper.sh
          version: v1beta1
          kind: K8sUniqueIngressHost # replace with the kind of the constraint you want to disable
          name: unique-ingress-host # replace with the name of the constraint you want to disable
      path: patches/allow.yml
```

add this in the `patches/allow.yml` file:

```yml
- op: "replace"
  path: "/spec/enforcementaction"
  value: "allow"
```

### Emergency break

If for some reason OPA Gatekeeper is giving you issues and blocking normal operations in your cluster, you can disable it by removing the Validating Admission Webhook definition from your cluster:

```bash
kubectl delete ValidatingWebhookConfiguration gatekeeper-validating-webhook-configuration
```

<!-- Links -->
[gatekeeper-page]: https://github.com/open-policy-agent/gatekeeper
[kubernetes-vaw-docs]: https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/
[kfd-monitoring]: https://github.com/sighupio/fury-kubernetes-monitoring
[core-kustomization]: ./katalog/gatekeeper/core/kustomization.yaml
[furyctl-repo]: https://github.com/sighupio/furyctl
[sighup-page]: https://sighup.io
[kfd-repo]: https://github.com/sighupio/fury-distribution
[kustomize-repo]: https://github.com/kubernetes-sigs/kustomize
[kfd-docs]: https://docs.kubernetesfury.com/docs/distribution/
[compatibility-matrix]: docs/COMPATIBILITY_MATRIX.md

<!-- </KFD-DOCS> -->

<!-- <FOOTER> -->

## Contributing

Before contributing, please read first the [Contributing Guidelines](docs/CONTRIBUTING.md).

### Reporting Issues

In case you experience any problem with the module, please [open a new issue](https://github.com/sighupio/fury-kubernetes-opa/issues/new/choose).

## License

This module is open-source and it's released under the following [LICENSE](LICENSE)

<!-- </FOOTER> -->
