package k8slivenessprobe

violation[{"msg": msg}] {
    input.request.kind.kind == "Deployment"
    servicetype = input.request.kind.kind
    name = input.request.object.metadata.name
    containers := input.request.object.spec.template.spec.containers[_]
    not containers.livenessProbe
    msg = sprintf("Rejecting \"%v/%v\" for not specifying a livenessProbe", [servicetype, name])
}
