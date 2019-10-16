package utilities

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

wrap_error(wrapped_error) = res {
	not not_namespaced[input.kind]
	res := json.marshal({"resource": {"apiVersion": input.apiVersion, "kind": input.kind, "namespace": input.metadata.namespace, "name": input.metadata.name}, "cause": wrapped_error})
}

wrap_error(wrapped_error) = res {
	not_namespaced[input.kind]
	res := json.marshal({"resource": {"apiVersion": input.apiVersion, "kind": input.kind, "name": input.metadata.name}, "cause": wrapped_error})
}

wrap_error(wrapped_error) = res {
	not input.metadata.namespace
	res := json.marshal({"resource": {"apiVersion": input.apiVersion, "kind": input.kind, "name": input.metadata.name}, "cause": wrapped_error})
}
