# Gatekepeer Package Maintenance

1. Check the differences with upstream:


```bash
curl https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-<UPSTRREAM_VERSION>/deploy/gatekeeper.yaml -o upstream.yaml
cat ns.yml  crd.yml sa.yml psp.yml rbac.yml secret.yml svc.yml deploy.yml pdb.yml mwh.yml vwh.yml > local.yml 
```

Replace <UPSTRREAM_VERSION> with the upstream version you want to compare with. Example: `3.8`.
You can use the link from the [installation instructions](https://open-policy-agent.github.io/gatekeeper/website/docs/install#deploying-a-release-using-prebuilt-image).

diff the generated `local.yaml` with `upstream.yaml` and port the needed differences.

> You can also diff a single file to `upstream.yaml` to port more easily the differences.

Please notice that it is expected that some objects don't have the namespace set as in upstream, thi is because the namespace is set with kustomize.

2. Sync the new image to our registry by updateing the [OPA iamges.yaml file fury-distribution-container-image-sync repository](https://github.com/sighupio/fury-distribution-container-image-sync/blob/main/modules/opa/images.yml).

3. Update the `kustomization.yaml` file with the new version in the image tag.

## Customizations

- We enable monitoring of metrics by default, so we added some parameters to scrape them.

- The deployment for audit-controller has been customized setting a default value for `--audit-chunk-size` to avoid the audit-controller going into OOM. We've observed this behaviour in serveral clusters, and this seems to fix it.

See [issue #49](https://github.com/sighupio/fury-kubernetes-opa/issues/49)