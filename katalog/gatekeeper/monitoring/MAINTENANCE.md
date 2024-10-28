# Gatekeeper Monitoring

All the elements in this folder are tailor-made, there's no upstream version to follow.

Please notice that the alert for "Fail open" webhooks depends on a metric exposed by the Kubernetes API Server ([`apiserver_admission_webhook_fail_open_count`](https://github.com/kubernetes/kubernetes/pull/107171)) that is available since Kubernetes 1.24.

To generate the markdown of the alerts to put in the main readme you can use the following command:

```bash
yq e '.spec.groups[] | .rules[] |  "| " + .alert + " | " + (.annotations.summary // "-" | sub("\n",". "))+ " | " + (.annotations.description // "-" | sub("\n",". ")) + " |"' katalog/gatekeeper/monitoring/alert-rules.yaml
```
