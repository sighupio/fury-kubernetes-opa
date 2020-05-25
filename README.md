# Fury Kubernetes OPA

Fury Kubernetes OPA provides a policy engine based on OPA Gatekeeper to enable custom policy enforcement in a
Kubernetes Cluster.

## OPA Packages

The following packages are included in Fury Kubernetes OPA module:

- [Gatekeeper](katalog/gatekeeper): Ready to use gatekeeper deployment plus a set of rules. Version: **v3.1.0-beta.8**
  - [Gatekeeper Core](katalog/gatekeeper/core): Gatekeeper deployment, ready to apply rules. Version: **v3.1.0-beta.8**
  - [Gatekeeper Rules](katalog/gatekeeper/rules): Gatekeeper rules:
    - deny of docker images with latest tag
    - deny of pods that have no limit declared (both cpu and memory)
    - deny of pods that allow privilege escalation explicitly
    - deny of pods that run as root
    - deny of pods that doesn't declare livenessProbe and readinessProbe
    - deny of duplicated ingresses

You can click on each package to see its documentation.

## Requirements

All packages in this repository have following dependencies, for package
specific dependencies please visit the single package's documentation:

- [Kubernetes](https://kubernetes.io) >= `v1.14.0`
- [Furyctl](https://github.com/sighupio/furyctl) package manager to download
    Fury packages >= [`v0.2.2`](https://github.com/sighupio/furyctl/releases/tag/v0.2.2)
- [Kustomize](https://github.com/kubernetes-sigs/kustomize) = `v3.3.0`
- [prometheus-operator](https://github.com/sighupio/fury-kubernetes-monitoring/tree/master/katalog/prometheus-operator) from the [Fury Monitoring Module](https://github.com/sighupio/fury-kubernetes-monitoring) is required by [Service monitor](./katalog/gatekeeper/core/service-monitor.yml) to export metrics to Prometheus.

> You can comment out the service monitor in the [kustomization.yaml](./katalog/gatekeeper/core/kustomization.yaml) file if you don't want to install the monitoring module.

## Compatibility

| Module Version / Kubernetes Version |       1.14.X       |       1.15.X       |       1.16.X       |
| ----------------------------------- | :----------------: | :----------------: | :----------------: |
| v1.0.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.0.1                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.0.2                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |

## License

For license details please see [LICENSE](./LICENSE)
