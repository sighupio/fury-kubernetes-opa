#!/usr/bin/env bats

load helpers

set -o pipefail

@test "setup" {
    deploy() {
    kaction ../core apply
    kubectl -n gatekeeper-system wait --timeout=60s --for=condition=Ready pod -l control-plane=controller-manager
    kaction ../rules/config apply
    kaction ../rules/templates apply
    }
    deploy_constraints() {
    sleep 5
    kaction ../rules/constraints apply
    sleep 5
    }
    run deploy
    [ "$status" -eq 0 ]
    run deploy_constraints 
    [ "$status" -eq 0 ]
}


# list of test that must pass if exit status == 0


@test "deployment_trusted_on_excluded_ns" {
 deploy() {
   kubectl apply -f manifests/deploy_ns_whitelisted.yml
}
run deploy
[ "$status" -eq 0 ]
}

@test "deployment_trusted_with_needed_setup" {
 deploy() {
   kubectl apply -f manifests/deployment_trusted.yml
}
run deploy
[ "$status" -eq 0 ]

}

@test "ingress_trusted" {
 deploy() {
   kubectl apply -f manifests/ingress_trusted.yml
 }

run deploy
[ "$status" -eq 0 ]

}

# list of test that pass if exit status != 0

@test "deployment_rejected_image_with_latest_tag" {
 deploy() {
   kubectl apply -f manifests/deployment_reject_label_latest.yml
 }

run deploy
[ "$status" -ne 0 ]
[[ "$output" == *"denied by enforce-deployment-and-pod-security-controls"* ]]
  #echo "# --- The Deployment has been rejected because of latest tag" >&3
}

@test "deployment_rejected_missing_resources" {
 deploy() {
   kubectl apply -f manifests/deployment_rejected_missing_resources.yml
 }

run deploy
[ "$status" -ne 0 ]
[[ "$output" == *"denied by enforce-deployment-and-pod-security-controls"* ]]
}

@test "ingress_rejected_duplicated" {
 deploy() {
   kubectl apply -f manifests/ingress_rejected_duplicated.yml
 }

run deploy
[ "$status" -ne 0 ]
[[ "$output" == *"denied by unique-ingress-host"* ]]
}

@test "teardown" {
 delete_resources() {
   kubectl delete -f manifests/deploy_ns_whitelisted.yml
   kubectl delete -f manifests/deployment_trusted.yml
   kubectl delete -f manifests/ingress_trusted.yml
 }
    delete_gatekeeper() {
    kaction ../rules/constraints delete
    kaction ../rules/templates delete
    kaction ../core delete
   }
run delete_resources
[ "$status" -eq 0 ]
  run delete_gatekeeper
[ "$status" -eq 0 ]
}
