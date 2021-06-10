# OPA Core Module version XXX

SIGHUP team maintains this module updated and tested. That is the main reason why we worked on this new release.
With the Kubernetes 1.21 release, it became the perfect time to start testing this module against this Kubernetes
release.

Continue reading the [Changelog](#changelog) to discover them:

## Changelog

- Add a Constraint Template to protect namespaces for being deleted.

## Upgrade path

To upgrade this core module from `v1.3.1`, you need to download this new version, then apply the
`kustomize` project. No further action is required.

```bash
kustomize build katalog/gatekeeper | kubectl apply -f - --force
```
