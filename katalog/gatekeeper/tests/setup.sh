#!/usr/bin/env bats
load helpers

@test "setup" {
    info
    deploy() {
    kaction ../core apply
    kubectl -n gatekeeper-system wait --timeout=60s --for=condition=Ready pod -l control-plane=controller-manager
    kaction ../rules/templates apply
    sleep 5
    kaction ../rules/constraints apply
    sleep 5
    }
    run deploy
    [ "$status" -eq 0 ]
}


@test "deployment_ns_whitelisted" {
 info
 deploy() {
   kubectl apply -f manifests/deploy_ns_whitelisted.yml
}
run deploy
[ "$status" -eq 0 ]

}


@test "deployment_trusted" {
 info
 deploy() {
   kubectl apply -f manifests/deployment_trusted.yml
}
run deploy
[ "$status" -eq 0 ]

}


@test "ingress_trusted" {
 info
 deploy() {
   kubectl apply -f manifests/ingress_trusted.yml
 }

run deploy
[ "$status" -eq 0 ]

}


@test "teardown" {
    info
 delete_resources() {
   kubectl delete -f manifests/deploy_ns_whitelisted.yml
   kubectl delete -f manifests/deployment_trusted.yml
   kubectl delete -f manifests/ingress_trusted.yml
 }
    delete_gatekeeper() {
    kaction ../core delete
    kaction ../rules/templates delete
    kaction ../rules/constraints delete
   }
run delete_resources
[ "$status" -eq 0 ]
  run delete_gatekeeper
[ "$status" -eq 0 ]
}
