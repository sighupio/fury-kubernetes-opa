#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

load helper

set -o pipefail

@test "Deploy Kyverno" {
  info
  deploy() {
    kubectl apply -f 'https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v2.1.0/katalog/prometheus-operator/crds/0servicemonitorCustomResourceDefinition.yaml'
    kubectl apply -f 'https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v2.1.0/katalog/prometheus-operator/crds/0prometheusruleCustomResourceDefinition.yaml'
    kubectl apply -f katalog/kyverno/crds.yaml --server-side
    sleep 30
    force_apply katalog/kyverno
  }
  loop_it deploy 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Wait for Kyverno Admission controller" {
  info
  test(){
    readyReplicas=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath="{.status.readyReplicas}")
    if [ "${readyReplicas}" != "3" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

# [ALLOW] Allowed by Gatekeeper Kubernetes requests

@test "[ALLOW] Deployment in a Whitelisted Namespace (kube-system)" {
  info
  deploy() {
    kubectl apply -f katalog/tests/kyverno-manifests/deploy_ns_whitelisted.yml
  }
  run deploy
  [[ "$status" -eq 0 ]]
}

@test "[ALLOW] Deployment with every required attributes" {
  info
  deploy() {
    kubectl apply -f katalog/tests/kyverno-manifests/deployment_trusted.yml
  }
  run deploy
  [[ "$status" -eq 0 ]]
}


@test "[ALLOW] Create not existing Ingress" {
  info
  deploy() {
    kubectl apply -f katalog/tests/kyverno-manifests/ingress_trusted.yml
  }
  run deploy
  [[ "$status" -eq 0 ]]
}

# [DENY] Denied by Gatekeeper Kubernetes requests

@test "[DENY] Deployment using latest tag" {
  info
  deploy() {
    kubectl apply -f katalog/tests/kyverno-manifests/deployment_reject_label_latest.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Using a mutable image tag"* ]]
}

@test "[DENY] Pod without liveness/readiness probes" {
  info
  deploy() {
    kubectl apply -f katalog/tests/kyverno-manifests/pod-rejected-without-livenessProbe.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"validate-probes"* ]]
}

@test "[DENY] Duplicated ingress" {
  info
  deploy() {
    kubectl apply -f katalog/tests/kyverno-manifests/ingress_rejected_duplicated.yml
  }
  run deploy
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"unique-ingress-host-and-path"* ]]
}
