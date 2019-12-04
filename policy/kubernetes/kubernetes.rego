package kubernetes.corp

import data.kubernetes.namespaces

not_namespaced = {
	"ComponentStatus",
	"Namespace",
	"Node",
	"PersistentVolume",
	"InitializerConfiguration",
	"MutatingWebhookConfiguration",
	"ValidatingWebhookConfiguration",
	"CustomResourceDefinition",
	"APIService",
	"TokenReview",
	"SelfSubjectAccessReview",
	"SelfSubjectRulesReview",
	"SubjectAccessReview",
	"CertificateSigningRequest",
	"PodSecurityPolicy",
	"NodeMetrics",
	"ClusterRoleBinding",
	"ClusterRole",
	"PriorityClass",
	"StorageClass",
	"VolumeAttachment",
}

object_path() = op {
    op = input.request.object
} else  = op {
	op = input
}

kind_path() = p {
	input.kind != "AdmissionReview"
    p = input.kind
}

kind_path() = p {
    input.kind == "AdmissionReview"
    p = input.request.kind.kind
}


wrap_error(wrapped_error) = res {
	not not_namespaced[kind_path]
	res := json.marshal({"resource": {"apiVersion": input.apiVersion, "kind": kind_path, "namespace": object_path.metadata.namespace, "name": object_path.metadata.name}, "cause": wrapped_error})
}

wrap_error(wrapped_error) = res {
	not_namespaced[kind_path]
	res := json.marshal({"resource": {"apiVersion": input.apiVersion, "kind": kind_path, "name": object_path.metadata.name}, "cause": wrapped_error})
}

wrap_error(wrapped_error) = res {
	not object_path.metadata.namespace
	res := json.marshal({"resource": {"apiVersion": input.apiVersion, "kind": kind_path, "name": object_path.metadata.name}, "cause": wrapped_error})
}

## 
## CHECK NAMESPACE IS DEFINED
## 

deny[msg] {
	not not_namespaced[kind_path]
	not object_path.metadata.namespace
	msg := wrap_error("namespace must be defined")
}

##
## CHECK MAX CONTAINERS PER POD
##

max_containers_per_pod = 1

deny[msg] {
	kinds = {"Pod"}
	kinds[kind_path]
	containers_per_pod = count(object_path.spec.containers)
	containers_per_pod > max_containers_per_pod
	msg := wrap_error(sprintf("only %v container per POD is allowed", [max_containers_per_pod]))
}

deny[msg] {
	kinds = {"DaemonSet", "Deployment", "Job"}
	kinds[kind_path]
	containers_per_pod = count(object_path.spec.template.spec.containers)
	containers_per_pod > max_containers_per_pod
	msg := wrap_error([containers_per_pod, max_containers_per_pod])
}

deny[msg] {
	kinds = {"Cronjob"}
	kinds[kind_path]
	containers_per_pod = count(object_path.spec.jobTemplate.spec.template.spec.containers)
	containers_per_pod > max_containers_per_pod
	msg := wrap_error([containers_per_pod, max_containers_per_pod])
}

##
## CHECK LATEST TAG NOT USED
##

check_image_tag(container, image) = sprintf("container %s is using %s image (latest tag is not allowed)", [container, image]) {
	endswith(image, ":latest")
} else = sprintf("container %s is using the untagged image %s. Please use a tag", [container, image]) {
	not contains(image, ":")
}

deny[msg] {
	kinds = {"Pod"}
	kinds[kind_path]
    err = check_image_tag(object_path.spec.containers[x].name, object_path.spec.containers[x].image)
	msg := wrap_error(err)
}

deny[msg] {
	kinds = {"DaemonSet", "Deployment", "Job"}
	kinds[kind_path]
    err = check_image_tag(object_path.spec.template.spec.containers[x].name, object_path.spec.template.spec.containers[x].image)
	msg := wrap_error(err)
}

deny[msg] {
	kinds = {"Cronjob"}
	kinds[kind_path]
	msg := wrap_error(check_image_tag(object_path.spec.jobTemplate.spec.template.spec[x][y].name, object_path.spec.jobTemplate.spec.template.spec[x][y].image))
}

##
## CHECK SERVICE TYPES ARE ALLOWED
##

deny[msg] {
	kind_path = "Service"
	allowed_services = {"ClusterIP", "NodePort"}
	not allowed_services[object_path.spec.type]
	msg := wrap_error(sprintf("Service of type %s are not allowed, only: %v", [object_path.spec.type, concat(", ", allowed_services)]))
}

##
## CHECK REQUESTS AND LIMITS ARE SET
##

check_containers_resources(resource) {
	count({x | object_path.spec.containers[x].resources[resource].cpu; object_path.spec.containers[x].resources[resource].memory}) == count(object_path.spec.containers)
} else {
	count({x | object_path.spec.template.spec.containers[x].resources[resource].cpu; object_path.spec.template.spec.containers[x].resources[resource].memory}) == count(object_path.spec.template.spec.containers)
}

check_initcontainers_resources(resource) {
	count({y | object_path.spec.initContainers[y].resources[resource].cpu; object_path.spec.initContainers[y].resources[resource].memory}) == count(object_path.spec.initContainers)
} else {
	count({y | object_path.spec.template.spec.initContainers[y].resources[resource].cpu; object_path.spec.template.spec.initContainers[y].resources[resource].memory}) == count(object_path.spec.template.spec.initContainers)
	# not object_path.spec.template.spec.initContainers
	# not object_path.spec.initContainers
}

deny[msg] {
	kinds = {"DaemonSet", "Deployment", "Job", "Cronjob", "Pod"}
	kinds[kind_path]
	# not check_initcontainers_resources("requests")
	not check_containers_resources("requests")
	msg := wrap_error("container requests must be set")
}

warn[msg] {
	kinds = {"DaemonSet", "Deployment", "Job", "Cronjob", "Pod"}
	kinds[kind_path]
	not check_containers_resources("limits")
	# not check_initcontainers_resources("limits")
	msg := wrap_error("container limits must be set")
}

##
## CHECK LABELS SET
##

labels {
	object_path.metadata.labels["app.kubernetes.io/name"]
	object_path.metadata.labels["app.kubernetes.io/instance"]
	object_path.metadata.labels["app.kubernetes.io/version"]
	object_path.metadata.labels["app.kubernetes.io/component"]
	object_path.metadata.labels["app.kubernetes.io/part-of"]
	object_path.metadata.labels["app.kubernetes.io/managed-by"]
}

warn[msg] {
	not labels
	msg := wrap_error(sprintf("%s must include Kubernetes recommended labels: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels ", [object_path.metadata.name]))
}
