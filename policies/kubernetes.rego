package main

import data.utilities

deny[msg]{
  not utilities.not_namespaced[input.kind]
  not input.metadata.namespace
  msg := utilities.wrap_error("namespace must be defined")
}

check_container(container) = sprintf("image %s using latest tag", [container]) {
  endswith(container,":latest")
}

deny[msg]{
  kinds = {"DaemonSet", "Deployment", "Job", "Pod"}
  kinds[input.kind]
  msg := utilities.wrap_error(check_container(input.spec.template.spec[_][_].image))
}

deny[msg]{
  kinds = {"Cronjob"}
  kinds[input.kind]
  msg := utilities.wrap_error(check_container(input.spec.jobTemplate.spec.template.spec[_][_].image))
}

warn[msg]{
  input.kind = "Service"
  allowed_services = {"ClusterIp", "NodePort"}
  not allowed_services[input.spec.type]
  msg := utilities.wrap_error(sprintf("Service of type %s are not allowed, only: %v", [input.spec.type, concat(", ",allowed_services)]))
}

check_resources(resource){
  some i, j
  input.spec.template.spec[i][j].resources[resource]
} else {

  some i,j
  input.spec.jobTemplate.spec.template.spec[i][j].resources[resource]
}

deny[msg]{
  kinds = {"Cronjob"}
  kinds[input.kind]
  not check_resources("requests")
  msg := utilities.wrap_error("requests are not set")
}

warn[msg]{
  kinds = {"Cronjob"}
  kinds[input.kind]
  not check_resources("limits")
  msg := utilities.wrap_error("limits are not set")
}

deny[msg]{
  kinds = {"DaemonSet", "Deployment", "Job", "Pod"}
  kinds[input.kind]
  not check_resources("requests")
  msg := utilities.wrap_error("requests are not set")
}

warn[msg]{
  kinds = {"DaemonSet", "Deployment", "Job", "Pod"}
  kinds[input.kind]
  not check_resources("limits")
  msg := utilities.wrap_error("limits are not set")
}

