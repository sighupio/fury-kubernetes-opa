# Kyverno - maintenance

To maintain the Kyverno package, you should follow this steps.

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/

helm repo update

helm search repo kyverno/kyverno # get the latest chart version
helm pull kyverno/kyverno --version 3.1.0  --untar --untardir /tmp 
```

> Note: if the templating gives some error, change `kubeVersion:`  on the /tmp/kyverno/Chart.yaml.

```bash
helm template kyverno /tmp/kyverno --values MAINTENANCE.values.yaml --namespace kyverno > built-kyverno.yaml
helm template kyverno /tmp/kyverno --values MAINTENANCE.values.yaml --set crds.install=true --namespace kyverno | yq 'select(.kind == "CustomResourceDefinition")' > crds.yaml
```

Compare the deploy.yaml file with the built-kyverno.yaml to find differences with the current version.

What was changed:
- Removed all the helm hooks from the deploy
- Manually added policies to have a similar ruleset as gatekeeper
- Whitelisted all the `infra` fury namespaces in the `MAINTENANCE.values.yaml` variable file