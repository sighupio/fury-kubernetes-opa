# Release notes

## Changelog

Changes between `1.1.0` and this release: `1.2.0`

- Update gatekeeper from `v3.1.0-beta.9` -> `v3.1.0`
- Re-enable High Availability
- The grafana dashboard is now part of this module
- Namespaces `kube-system` and `gatekeeper-system` namespaces are exempted.

## Upgrade path

This version changes the labels for gatekeeper-controller-manager, so the usual `kustmize build | kubectl apply -f`
should be used toghether with the `--force` flag, or the `gatekeeper-controller-manager` deployment should be deleted
manually before applying this new version.
