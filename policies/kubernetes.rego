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
	kinds = {"DaemonSet", "Deployment", "Job", "Pod"}
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
	allowed_services = {"ClusterIp", "NodePort"}
	not allowed_services[input.spec.type]
	msg := utilities.wrap_error(sprintf("Service of type %s are not allowed, only: %v", [input.spec.type, concat(", ", allowed_services)]))
}

##
## CHECK REQUESTS AND LIMITS ARE SET
##

check_resources(resource) {
	some i, j
	input.spec.template.spec[i][j].resources[resource]
}

else {
	some i, j
	input.spec.jobTemplate.spec.template.spec[i][j].resources[resource]
}

deny[msg] {
	kinds = {"Cronjob"}
	kinds[input.kind]
	not check_resources("requests")
	msg := utilities.wrap_error("requests are not set")
}

warn[msg] {
	kinds = {"Cronjob"}
	kinds[input.kind]
	not check_resources("limits")
	msg := utilities.wrap_error("limits are not set")
}

deny[msg] {
	kinds = {"DaemonSet", "Deployment", "Job", "Pod"}
	kinds[input.kind]
	not check_resources("requests")
	msg := utilities.wrap_error("requests are not set")
}

warn[msg] {
	kinds = {"DaemonSet", "Deployment", "Job", "Pod"}
	kinds[input.kind]
	not check_resources("limits")
	msg := utilities.wrap_error("limits are not set")
}
