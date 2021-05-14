# Gatekeeper

## Requirements

Minimum Kubernetes version >= 1.18

> Requires the `ValidatingAdmissionWebhook` admission plugin

## Fury Setup

This module can easily be added to your existing Fury setup adding to your `Furyfile.yml`:

```yml
bases:
  (...)
  - name: opa/gatekeeper
    version: master
```

Once you'll do this, you can then proceed to integrate Gatekeeper into your project.

### Disable constraint

If you need to disable already existing constraints that are usually enabled by default,
you can just simply create a patch in kustomize like the following one:

```yml
patchesJson6902:
    - target:
          group: constraints.gatekeeper.sh
          version: v1beta1
          kind: K8sUniqueIngressHost # is just an example of already enabled constraints
          name: unique-ingress-host
      path: patches/allow.yml
```

in the `patches/allow.yml`:

```yml
- op: "replace"
  path: "/spec/enforcementaction"
  value: "allow"
```

### Exclude namespaces from gatekeeper constraints

There are already a bunch of namespaces excluded by default by the rules of Gatekeeper, that are the one
used by infra namespaces *(logging, monitoring, kube-system, ingress-nginx)*. If this subset must be modified for whatever
reason, you can just do it with a kustomize path like the following one:

```yml
patchesJson6902:
    - target:
          group: constraints.gatekeeper.sh
          version: v1beta1
          kind: K8sUniqueIngressHost # is just an example of already enabled constraints
          name: unique-ingress-host
      path: patches/ns.yml
```

in the `patches/allow.yml` :

```yml
- op: "replace"
  path: "/spec/match/excludedNamespaces"
  value:
      - myNs1
      - myNs2
      - myNs3
      - myNs4
```

### Naming of Constraints and ConstraintTemplates

To be more explicit, it is useful to give a verbose name to constraints, such as:
`all_pod_must_have_gatekeeper_namespaceselector.yml`
In this way, the scope of the constraint that is going to be applied will be crystal clear.
For the `ConstraintTemplate` (that is the general logic — a function basically —) could be reasonable to have something
like: `k8srequiredlabels_template.yml`

#### Uninstall Constraints

To uninstall rules you first need to remove the constraint, then the `constraintTemplate`:

here is an example of the following resource:

<!-- markdownlint-disable MD014 -->
```bash
$ kubectl delete crd k8scontainerlimits.constraints.gatekeeper.sh # this will remove the constraint
$ kubectl delete constrainttemplates.templates.gatekeeper.sh k8scontainerlimits # this will remove the constraintTemplate
```

### Modify constraintTemplates rules (securityControls)

There is a `constraintTemplate` *(`securityControl`)* that enables only a few subsets of the available rules, basically
because there are a lot of rules that require pretty much effort to achieve them. If you want to enable them, you can
just make a patch with kustomize (following the examples above) and enable a part or all of them
(you can find them here: [security_controls_template.yml](rules/templates/security_controls_template.yml)

## Uninstallation

Before uninstalling Gatekeeper, be sure to clean up old `Constraints`, `ConstraintTemplates`, and
the `Config` resource in the `gatekeeper-system` namespace. This will make sure all finalizers
are removed by Gatekeeper. Otherwise, the finalizers will need to be removed manually.

### Before Uninstall, Clean Up Old Constraints

Currently, the uninstall mechanism only removes the Gatekeeper system,
it does not remove any `ConstraintTemplate`, `Constraint`, and `Config` resources that have been created by the user,
nor does it remove their accompanying `CRDs`.

When Gatekeeper is running it is possible to remove unwanted constraints by:

- Deleting all instances of the constraint resource.
- Deleting the `ConstraintTemplate` resource, which should automatically clean up the `CRD`.
- Deleting the `Config` resource removes finalizers on synced resources.
