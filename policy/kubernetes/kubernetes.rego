package main

import data.utilities

deny[msg] {
	not utilities.not_namespaced[input.kind]
	not input.metadata.namespace
	msg := utilities.wrap_error("namespace must be defined")
}

##
## CHECK MAX CONTAINERS PER POD
##

max_containers_per_pod = 1

deny[msg] {
	kinds = {"Pod"}
	kinds[input.kind]
	containers_per_pod = count(input.spec.containers)
	containers_per_pod > max_containers_per_pod
	msg := utilities.wrap_error([containers_per_pod, max_containers_per_pod])
}

deny[msg] {
	kinds = {"DaemonSet", "Deployment", "Job"}
	kinds[input.kind]
	containers_per_pod = count(input.spec.template.spec.containers)
	containers_per_pod > max_containers_per_pod
	msg := utilities.wrap_error([containers_per_pod, max_containers_per_pod])
}

deny[msg] {
	kinds = {"Cronjob"}
	kinds[input.kind]
	containers_per_pod = count(input.spec.jobTemplate.spec.template.spec.containers)
	containers_per_pod > max_containers_per_pod
	msg := utilities.wrap_error([containers_per_pod, max_containers_per_pod])
}

##
## CHECK LATEST TAG NOT USED
##

check_container(container) = sprintf("image %s using latest tag", [container]) {
	endswith(container, ":latest")
}

else {
	not contains(container, ":")
}

deny[msg] {
	kinds = {"DaemonSet", "Deployment", "Job", "Pod"}
	kinds[input.kind]
	msg := utilities.wrap_error(check_container(input.spec.template.spec[_][_].image))
}

deny[msg] {
	kinds = {"Cronjob"}
	kinds[input.kind]
	msg := utilities.wrap_error(check_container(input.spec.jobTemplate.spec.template.spec[_][_].image))
}

##
## CHECK SERVICE TYPES ARE ALLOWED

warn[msg] {
	input.kind = "Service"
	allowed_services = {"ClusterIP", "NodePort"}
	not allowed_services[input.spec.type]
	msg := utilities.wrap_error(sprintf("Service of type %s are not allowed, only: %v", [input.spec.type, concat(", ", allowed_services)]))
}

##
## CHECK REQUESTS AND LIMITS ARE SET
##

check_resources(resource) {
	count({x | input.spec[_][x].resources[resource].cpu; input.spec[_][x].resources[resource].memory}) == count(input.spec.containers)
}

else {
	count({x | input.spec.template.spec[_][x].resources[resource].cpu; input.spec.template.spec[_][x].resources[resource].memory}) == count(input.spec.template.spec.containers)
}

deny[msg] {
	kinds = {"DaemonSet", "Deployment", "Job", "Cronjob", "Pod"}
	kinds[input.kind]
	not check_resources("requests")
	msg := utilities.wrap_error("requests are not set")
}

warn[msg] {
	kinds = {"DaemonSet", "Deployment", "Job", "Cronjob", "Pod"}
	kinds[input.kind]
	not check_resources("limits")
	msg := utilities.wrap_error("limits are not set")
}

##
## CHECK LABELS SET
##

labels {
	input.metadata.labels["app.kubernetes.io/name"]
	input.metadata.labels["app.kubernetes.io/instance"]
	input.metadata.labels["app.kubernetes.io/version"]
	input.metadata.labels["app.kubernetes.io/component"]
	input.metadata.labels["app.kubernetes.io/part-of"]
	input.metadata.labels["app.kubernetes.io/managed-by"]
}

warn[msg] {
	not labels
	msg := utilities.wrap_error(sprintf("%s must include Kubernetes recommended labels: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels ", [input.metadata.name]))
}
