# Kyverno

<!-- <KFD-DOCS> -->

Kyverno is a policy engine designed for Kubernetes. It can validate, mutate, and generate configurations using admission controls and background scans. Kyverno policies are Kubernetes resources and do not require learning a new language. Kyverno is designed to work nicely with tools you already use like kubectl, kustomize, and Git.

## Requirements

- Kubernetes >= `1.25.0`
- Kustomize >= `v3.5.3`

## Image repositories

- registry.sighup.io/fury/kyverno/kyverno
- registry.sighup.io/fury/kyverno/kyvernopre
- registry.sighup.io/fury/kyverno/background-controller
- registry.sighup.io/fury/kyverno/cleanup-controller
- registry.sighup.io/fury/kyverno/reports-controller
- registry.sighup.io/fury/bitnami/kubectl

## Configuration

Kyverno is deployed in HA mode, and whitelists the KFD `infra` namespaces by default on the webhooks.

## Pre-configured policies

This package comes with a set of predefined policies from the main kyverno repository. These policies are our own KFD baseline, and are similar to what is provided with the Gatekeeper package.

| Policy                         | Description                                                                                                                                                                                                                                                                                                                          |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| disallow-capabilities-strict   | Adding capabilities other than `NET_BIND_SERVICE` is disallowed. In addition, all containers must explicitly drop `ALL` capabilities.                                                                                                                                                                                                |
| disallow-capabilities          | Adding capabilities beyond those listed in the policy must be disallowed.                                                                                                                                                                                                                                                            |
| disallow-host-namespaces       | Host namespaces (Process ID namespace, Inter-Process Communication namespace, and network namespace) allow access to shared information and can be used to elevate privileges. Pods should not be allowed access to host namespaces. This policy ensures fields which make use of these host namespaces are unset or set to `false`. |
| disallow-host-path             | HostPath volumes let Pods use host directories and volumes in containers. Using host resources can be used to access shared data or escalate privileges and should not be allowed. This policy ensures no hostPath volumes are in use.                                                                                               |
| disallow-host-ports            | Access to host ports allows potential snooping of network traffic and should not be allowed, or at minimum restricted to a known list. This policy ensures the `hostPort` field is unset or set to `0`.                                                                                                                              |
| disallow-latest-tag            | The ':latest' tag is mutable and can lead to unexpected errors if the image changes. A best practice is to use an immutable tag that maps to a specific version of an application Pod. This policy validates that the image specifies a tag and that it is not called `latest`.                                                      |
| disallow-privilege-escalation  | Privilege escalation, such as via set-user-ID or set-group-ID file mode, should not be allowed. This policy ensures the `allowPrivilegeEscalation` field is set to `false`.                                                                                                                                                          |
| disallow-privileged-containers | Privileged mode disables most security mechanisms and must not be allowed. This policy ensures Pods do not call for privileged mode.                                                                                                                                                                                                 |
| disallow-proc-mount            | The default /proc masks are set up to reduce attack surface and should be required. This policy ensures nothing but the default procMount can be specified.                                                                                                                                                                          |
| require-pod-probes             | Liveness and readiness probes need to be configured to correctly manage a Pod's lifecycle during deployments, restarts, and upgrades.                                                                                                                                                                                                |
| require-run-as-nonroot         | Containers must be required to run as non-root users. This policy ensures `runAsNonRoot` is set to `true`. 2.                                                                                                                                                                                                                        |
| restrict-sysctls               | Sysctls can disable security mechanisms or affect all containers on a host, and should be disallowed except for an allowed "safe" subset.                                                                                                                                                                                            |
| unique-ingress-host-and-path   | This policy ensures that no Ingress can be created or updated unless it is globally unique with respect to host plus path  combination.                                                                                                                                                                                              |

## Deployment

You can deploy kyverno by running the following command in the root of
the project:

```shell
kustomize build | kubectl create -f -
```

<!-- Links -->

<!-- </KFD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
