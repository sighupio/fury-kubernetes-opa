#!/usr/bin/env bats
# Copyright (c) 2020 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

load helper

set -o pipefail

@test "Deploy Gatekeeper Core" {
  info
  deploy() {
    kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.9.0/katalog/prometheus-operator/crd-servicemonitor.yml
    force_apply katalog/gatekeeper/core
  }
  run deploy
  [[ "$status" -eq 0 ]]
}

@test "Wait for Gatekeeper Audit" {
  info
  test(){
    readyReplicas=$(kubectl get deploy gatekeeper-audit -n gatekeeper-system -o jsonpath="{.status.readyReplicas}")
    if [ "${readyReplicas}" != "1" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}


@test "Wait for Gatekeeper Core" {
  info
  test(){
    readyReplicas=$(kubectl get deploy gatekeeper-controller-manager -n gatekeeper-system -o jsonpath="{.status.readyReplicas}")
    if [ "${readyReplicas}" != "3" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Deploy Gatekeeper Rules - templates" {
  info
  deploy() {
    kaction katalog/gatekeeper/rules/templates apply
  }
  loop_it deploy 30 10
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Deploy Gatekeeper Rules - constraints" {
  info
  deploy() {
    # enabling all constraints for testing purposes
    sed -i -e 's/---//g' katalog/gatekeeper/rules/constraints/kustomization.yaml
    cd  katalog/gatekeeper/rules/constraints &&\
      kustomize edit add resource must_have_namespace_label_to_be_safely_deleted.yml;\
      cd -
    kaction katalog/gatekeeper/rules/constraints apply

  }
  loop_it deploy 30 10
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Deploy Gatekeeper Rules - config" {
  info
  deploy() {
    kaction katalog/gatekeeper/rules/config apply
  }
  loop_it deploy 30 10
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Deploy Gatekeeper Policy Manager" {
  info
  deploy() {
    kaction katalog/gatekeeper/gpm apply
  }
  loop_it deploy 30 10
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Wait for Gatekeeper Policy Manager" {
  info
  test(){
    readyReplicas=$(kubectl get deploy gatekeeper-policy-manager -n gatekeeper-system -o jsonpath="{.status.readyReplicas}")
    if [ "${readyReplicas}" != "1" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Wait to apply all rules" {
  info
  sleep 120
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


@test "[ALLOW] Delete namespace" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/ns-can-be-deleted-with-protection-disabled.yml
    kubectl delete ns my-unprotected-namespace
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
  [[ "$output" == *"using the latest tag"* ]]
}

@test "[DENY] Deployment without resources" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/deployment_rejected_missing_resources.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"enforce-deployment-and-pod-security-controls"* ]]
}

@test "[DENY] Pod without liveness/readiness probes" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/pod-rejected-without-livenessProbe.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"liveness-probe"* ]]
}

@test "[DENY] Duplicated ingress" {
  info
  deploy() {
    kubectl apply -f katalog/tests/gatekeeper-manifests/ingress_rejected_duplicated.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"unique-ingress-host"* ]]
}

@test "[DENY] Delete namespace" {
  info
  deploy() {
    kubectl apply -f katalog/tests/ns-cannot-be-deleted-without-protection-enabled.yml
    kubectl delete ns my-protected-namespace
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"namespace-protected"* ]]
}

@test "Teardown - Delete resources" {
  info
  skip
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
  skip
  gatekeeper_teardown() {
    kaction katalog/gatekeeper/rules delete
  }
  run gatekeeper_teardown
  [[ "$status" -eq 0 ]]
}

@test "Teardown - Delete Gatekeeper Core" {
  info
  skip
  gatekeeper_teardown() {
    kaction katalog/gatekeeper/core delete
  }
  run gatekeeper_teardown
  [[ "$status" -eq 0 ]]
}
