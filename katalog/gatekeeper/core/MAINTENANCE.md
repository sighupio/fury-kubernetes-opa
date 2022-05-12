# Gatekepeer Package Maintenance

```bash
curl https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.7/deploy/gatekeeper.yaml -o upstream.yaml
cat ns.yml crd.yml sa.yml rbac.yml vwh.yml secret.yml svc.yml deploy.yml pdb.yml > local.yml
```

diff `local.yaml` with `upstream.yaml` and port the needed differences.

## Customizations

The deployment for audit-controller has been customized setting a default value for `--audit-chunk-size` to avoid the audit-controller going into OOM. We've observed this behaviour in serveral clusters, and this seems to fix it.

See [issue #49](https://github.com/sighupio/fury-kubernetes-opa/issues/49)
