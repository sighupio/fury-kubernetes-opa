# OPA Core Module version XXX

SIGHUP team maintains this module updated and tested. That is the main reason why we worked on this new release.
With the Kubernetes 1.21 release, it became the perfect time to start testing this module against this Kubernetes
release.

Continue reading the [Changelog](#changelog) to discover them:

## Changelog

- Add a Constraint Template to protect namespaces for being deleted. If you want to avoid accidental deletion of namespace, add annotation to your namespace
```yaml
annotations:
  protected: "yes"
```

Otherwise to enable deletion use the annotation:

```yaml
annotations:
  protected: "no"
```
If you don't put any annotation, the default is to protect the namespace.

By default the constraint is disabled - while the constrainttemplate is deployed - , but you can enable it by removing the comment in the line in the [kustomization.yaml](../../katalog/gatekeeper/rules/constraints/kustomization.yaml)

## Breaking Changes

- Now Gatekeeper watches also for `DELETE` events as well. If you have custom constraints *you have to* adapt them in order to handle this with something like the follow rego code:

```go
operation := input.review.operation
any([ operation == "CREATE", operation == "UPDATE" ])
operation != "DELETE"
```

## Upgrade path

To upgrade this core module from `v1.3.1`, you need to download this new version, then apply the
`kustomize` project. No further action is required.

```bash
kustomize build katalog/gatekeeper | kubectl apply -f - --force
```
