# Gatekeeper Rules

- deny of docker images with the latest tag
- deny of pods that have no limit declared *(both CPU and memory)*
- deny of pods that allow privilege escalation explicitly
- deny of pods that run as root
- deny of pods that don't declare `livenessProbe` and `readinessProbe`
- deny duplicated ingresses
- unique service selector

[security_controls_template.yml](templates/security_controls_template.yml): it's an all in one pod security policies
measures, that contains a lot more rules, that are currently commented on. This file can be splitter into several
`constraintTemplates` with the counterpart of having to manage an additional `constraint`/`constraintTemplate` resource
for each one.
