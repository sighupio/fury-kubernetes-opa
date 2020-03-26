# Gatekeeper

### Requirements

minimum kubernetes version >= 1.14

It is needed to add the admission plugins the ValidatingAdmissionWebhook

### Uninstallation

Before uninstalling Gatekeeper, be sure to clean up old `Constraints`, `ConstraintTemplates`, and
the `Config` resource in the `gatekeeper-system` namespace. This will make sure all finalizers
are removed by Gatekeeper. Otherwise the finalizers will need to be removed manually.

#### Before Uninstall, Clean Up Old Constraints

Currently the uninstall mechanism only removes the Gatekeeper system, it does not remove any `ConstraintTemplate`, `Constraint`, and `Config` resources that have been created by the user, nor does it remove their accompanying `CRDs`.

When Gatekeeper is running it is possible to remove unwanted constraints by:

-   Deleting all instances of the constraint resource
-   Deleting the `ConstraintTemplate` resource, which should automatically clean up the `CRD`
-   Deleting the `Config` resource removes finalizers on synced resources

### Naming of Constraints and ConstraintTemplates

For being more explicit should be useful give a verbose name to constraints such as : `all_pod_must_have_gatekeeper_namespaceselector.yml`
In this way will be crystal clear the scope of the constraint that is going to be applied
For the ConstraintTemplate (that is the general logic - a function basically -) could be reasonable to have something like: `k8srequiredlabels_template.yml`

### Uninstall Constraints

For uninstalling rules you first need to remove the constraint, then the constraintTemplate:

here an example for the following resource:

```
kubectl delete crd k8scontainerlimits.constraints.gatekeeper.sh # this will remove the constraint
kubectl delete constrainttemplates.templates.gatekeeper.sh k8scontainerlimits  # this will remove the constraintTemplate
```
