# Gatekeeper Rules

- deny of docker images with latest tag
- deny of pods that have no limit declared (both cpu and memory)
- deny of pods that allow privilege escalation explicitly
- deny of pods that run as root
- deny of pods that doesn't declare livenessProbe and readinessProbe
- deny of duplicated ingresses

[security_controls_template.yml](templates/security_controls_template.yml): its a all in one pod security policies
measures, that contains a lot more rules, that are currently commented. I choose this approach, but probably
can be splitted in several constraintTemplate but this will have to handle lot of more constraint/constraintTemplate
resources.
