# Fury Kubernetes OPA

Fury Kubernetes OPA provides a policy engine based on OPA Gatekeeper to enable custom policy enforcement in a
Kubernetes Cluster.

## OPA Packages

The following packages are included in the Fury Kubernetes OPA module:

- [Gatekeeper](katalog/gatekeeper): Ready to use gatekeeper deployment plus a set of rules. Version: **v3.2.2**
  - [Gatekeeper Core](katalog/gatekeeper/core): Gatekeeper deployment, ready to apply rules. Version: **v3.2.2**
  - [Gatekeeper Rules](katalog/gatekeeper/rules): Gatekeeper rules:
    - deny of docker images with the latest tag
    - deny of pods that have no limit declared (both CPU and memory)
    - deny of pods that allow privilege escalation explicitly
    - deny of pods that run as root
    - deny of pods that don't declare `livenessProbe` and `readinessProbe`
    - deny of duplicated ingresses

You can click on each package to see its documentation.

## Requirements

All packages in this repository have the following dependencies, for package
specific dependencies please visit the single package's documentation:

- [Kubernetes](https://kubernetes.io) >= `v1.17.0`
- [Furyctl](https://github.com/sighupio/furyctl) package manager to download
    Fury packages >= [`v0.2.2`](https://github.com/sighupio/furyctl/releases/tag/v0.2.2)
- [Kustomize](https://github.com/kubernetes-sigs/kustomize) = `v3.3.0`
- [prometheus-operator](https://github.com/sighupio/fury-kubernetes-monitoring/tree/master/katalog/prometheus-operator)
from the [Fury Monitoring Module](https://github.com/sighupio/fury-kubernetes-monitoring) is required by
[Service monitor](./katalog/gatekeeper/core/service-monitor.yml) to export metrics to Prometheus.

> You can comment out the service monitor in the [kustomization.yaml](./katalog/gatekeeper/core/kustomization.yaml)
file if you don't want to install the monitoring module.

## Compatibility

| Module Version / Kubernetes Version |       1.14.X       |       1.15.X       |       1.16.X       |       1.17.X       |       1.18.X       |       1.19.X       |       1.20.X       |
| ----------------------------------- | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: |
| v1.0.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |
| v1.0.1                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |
| v1.0.2                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |
| v1.1.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |
| v1.2.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |
| v1.2.1                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |
| v1.3.0                              |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |

### Warning

- :warning: : module version: `v1.3.0` along with Kubernetes Version: `1.20.x`. It works as expected.
Marked as a warning because it is not officially supported by [SIGHUP](https://sighup.io).

## License

For license details please see [LICENSE](./LICENSE)
