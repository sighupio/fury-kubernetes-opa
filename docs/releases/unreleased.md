# Release notes

## Changelog

Changes between `1.0.2` and this release: `TBD`

- Add metrics port to service
- Add service monitor definition for Prometheus scarping
- [prometheus-operator](https://github.com/sighupio/fury-kubernetes-monitoring/tree/master/katalog/prometheus-operator) from the [Fury Monitoring Module](https://github.com/sighupio/fury-kubernetes-monitoring) is now required by [Service monitor](./katalog/gatekeeper/core/service-monitor.yml) to export metrics to Prometheus (it can be disabled).
- Set default replica count to 1 due to HA not being supported upstream
