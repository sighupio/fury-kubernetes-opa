#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

load helper

set -o pipefail

@test "Deploy pod with violations" {
  info
  deploy() {
    kubectl run bad-pod --image busybox -- sleep 5000
  }
  run deploy
  [[ "$status" -eq 0 ]]
}

@test "Deploy Gatekeeper Core" {
  info
  deploy() {
    sed -i  -e '/# - DELETE/s/# //g' katalog/gatekeeper/core/vwh.yml
    kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.14.2/katalog/prometheus-operator/crd-servicemonitor.yml
    kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.14.2/katalog/prometheus-operator/crd-rule.yml
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

# We just deploy the monitoring parts to check that the apply works, but we should do some more comprehensive tests.
# Some tests we could do:
# - we could check that the serviceMonitor is actually working
# - We could check for metrics being present
# - We could check that the alerts are actually triggered
# but all these requires the monitoring module to be present.
@test "Deploy Gatekeeper Monitoring" {
  info
  deploy() {
    kaction katalog/gatekeeper/monitoring apply
  }
  loop_it deploy 30 10
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
  sleep 30
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

@test "Wait for Gatekeeper to process all the constraints to test all rules" {
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
    kubectl apply -f katalog/tests/gatekeeper-manifests/ns-cannot-be-deleted-without-protection-enabled.yml
    kubectl delete ns my-protected-namespace
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"namespace-protected"* ]]
}

@test "[AUDIT] check violations triggered by bad-pod are present" {
  info
  run kubectl get k8slivenessprobe.constraints.gatekeeper.sh liveness-probe -o go-template="{{.status.totalViolations}}"
  echo "number of violations for liveness-probe constraint is: ${output}"
  echo "command status is: ${status}"
  [[ "$status" -eq 0 ]]
  [[ "$output" -eq 3 ]]
}

@test "Teardown - Delete resources" {
  info
  skip
  resource_teardown() {
    kubectl delete -f katalog/tests/gatekeeper-manifests/deploy_ns_whitelisted.yml
    kubectl delete -f katalog/tests/gatekeeper-manifests/deployment_trusted.yml
    kubectl delete -f katalog/tests/gatekeeper-manifests/ingress_trusted.yml
    kubectl delete pod bad-pod
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
