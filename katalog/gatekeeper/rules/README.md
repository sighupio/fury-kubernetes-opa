# Gatekeeper Rules

<!-- <KFD-DOCS> -->

A Policy is a group of rules that enforce desired behavior. The module provides a set of common policies out of the box to get started in securing your cluster.

A policy in Gatekeeper is defined by two objects: a `ConstraintTemplate` and a `Constraint`.

As the name suggests, the `ConstraintTemplate` defines the common logic of the policy and the `Constraint` takes that logic and creates the actual policy by creating an instance of the template with the right values for the required parameters.

For example, one could have a `ConstraintTemplate` to check that a set of labels are present. But, what particular labels to check could be a parameter of the template that should be configured in the `Constraint`. Let's say that the `Constraint` will check that the label `application-group: FURY` should be present for deployments in a defined namespace.

> For a more detailed explanation, please refer to [Gatekeeper's official documentation][gatekeeper-docs].

## SIGHUP base rules

Below, you can find a list of constraint templates shipped with SIGHUP Distribution:

| Rule Name                  | Description                                                                                                                                           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `k8slivenessprobe`         | Deny pods that don't declare `livenessProbe`.                                                                                                         |
| `k8sreadinessprobe`        | Deny pods that don't declare `readinessProbe`.                                                                                                        |
| `k8suniqueingresshost`     | Deny duplicated ingress across the cluster.                                                                                                           |
| `k8suniqueserviceselector` | Deny duplicated services selector in the same namespace.                                                                                              |
| `securitycontrols`         | Deny container images with the `latest` tag, with no limits declared (both CPU and memory), with privilege escalation capability and root containers. |

> [security_controls_template.yml][security-controls-template]: it's an all-in-one pod security policy measure composed of several rules. Most of the rules are commented out and provided as examples and to be used as starting point for your own rules.
> This file can be split into several `ConstraintTemplates` with the counterpart of having to manage an additional `constraint`/`constraintTemplate` resource for each one.
<!-- space left blank on purpose to separate both quotes -->
> The Gatekeeper package provides both `ConstraintTemplates` and `Constraints` for each rule out of the box.
<!-- space left blank on purpose to separate both quotes -->
> All the `Constraints` exclude by default SD "infra" namespaces (`kube-system`, `logging`, `monitoring`, `ingress-nginx`, `cert-manager`) to avoid service disruption.

### Usage

Creating a constraint from a SIGHUP base constraint template is done by declaring a new CRD, for example, the following `Constraint` will check that all `Deployments` have a liveness probe defined in all namespaces except in `kube-system` and deny the creation of the ones that do not have it:

```yaml
---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sLivenessProbe
metadata:
  name: liveness-probe
spec:
  enforcementAction: deny
  match:
    excludedNamespaces:
      - kube-system
    kinds:
      - apiGroups: ["apps", "extensions"]
        kinds: ["Deployment"]
```

ℹ️ change `enforcementAction` value to `dryrun` first and look into the audit logs to understand if your constraint is working as expected without blocking anything. Once you are sure, you can set the `Constraint` to `deny` and start blocking.

ℹ️ take a look at [Gatekeeper Policy Manager][gpm] if you want to see the status of your constraints (and more) in a nice web UI.

> Please refer to [the official documentation][gatekeeper-constraint-docs] to better understand how to create `Constraints`.

<!-- Links -->
[security-controls-template]: templates/security_controls_template.yml
[gatekeeper-docs]: https://open-policy-agent.github.io/gatekeeper/website/docs/
[gatekeeper-constraint-docs]: https://open-policy-agent.github.io/gatekeeper/website/docs/howto#constraints
[gpm]: ../gpm/

<!-- </KFD-DOCS> -->
