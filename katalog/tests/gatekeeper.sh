#!/usr/bin/env bats

load helper

set -o pipefail

@test "Deploy Gatekeeper Core" {
  info
  deploy() {
    kaction katalog/gatekeeper/core apply
  }
  run deploy
  [[ "$status" -eq 0 ]]
}

@test "Wait for Gatekeeper Core" {
  info
  test(){
    status=$(kubectl get pods -n gatekeeper-system -l control-plane=controller-manager -o jsonpath="{.items[*].status.phase}")
    for state in $status; do
      if [ "${state}" != "Running" ]; then return 1; fi
    done
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Deploy Gatekeeper Rules" {
  info
  deploy() {
    kaction katalog/gatekeeper/rules apply
  }
  loop_it deploy 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

# [ALLOW] Allowed by Gatekeeper Kubernetes requests

@test "[ALLOW] Deployment in a Whitelisted Namespace (kube-system)" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/deploy_ns_whitelisted.yml
  }
  run deploy
  [[ "$status" -eq 0 ]]
}

@test "[ALLOW] Deployment with every required attributes" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/deployment_trusted.yml
  }
  run deploy
  [[ "$status" -eq 0 ]]
}

@test "[ALLOW] Create not existing Ingress" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/ingress_trusted.yml
  }
  run deploy
  [[ "$status" -eq 0 ]]
}

# [DENY] Denied by Gatekeeper Kubernetes requests

@test "[DENY] Deployment using latest tag" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/deployment_reject_label_latest.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"denied by enforce-deployment-and-pod-security-controls"* ]]
}

@test "[DENY] Deployment without resources" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/deployment_rejected_missing_resources.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"denied by enforce-deployment-and-pod-security-controls"* ]]
}

@test "[DENY] Pod without liveness/readiness probes" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/pod-rejected-without-livenessProbe.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"denied by liveness-probe"* ]]
}

@test "[DENY] Duplicated ingress" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/ingress_rejected_duplicated.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"denied by unique-ingress-host"* ]]
}

@test "Teardown - Delete resources" {
  info
  resource_teardown() {
    kubectl delete -f katalog/tests/gatekeeper-manifests/deploy_ns_whitelisted.yml
    kubectl delete -f katalog/tests/gatekeeper-manifests/deployment_trusted.yml
    kubectl delete -f katalog/tests/gatekeeper-manifests/ingress_trusted.yml
  }
  run resource_teardown
  [[ "$status" -eq 0 ]]
}

@test "Teardown - Delete Gatekeeper Rules" {
  info
  gatekeeper_teardown() {
    kaction katalog/gatekeeper/rules delete
  }
  run gatekeeper_teardown
  [[ "$status" -eq 0 ]]
}

@test "Teardown - Delete Gatekeeper Core" {
  info
  gatekeeper_teardown() {
    kaction katalog/gatekeeper/core delete
  }
  run gatekeeper_teardown
  [[ "$status" -eq 0 ]]
}
