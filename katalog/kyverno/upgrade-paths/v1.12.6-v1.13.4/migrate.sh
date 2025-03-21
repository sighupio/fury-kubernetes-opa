#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

wait_for_job() {
  local namespace="$1"
  local jobname="$2"
  local timeout="$3"
  local retries="$4"
  local retries_count=0
  
  while [ $retries_count -lt "$retries" ]; do
    if kubectl wait --for=condition=complete job/"$jobname" -n "$namespace" --timeout="${timeout}s"; then
      echo "job completed"
      return 0
    fi
    
    echo "timeout"
    
    retries_count=$((retries_count+1))
    
    if [ $retries_count -lt "$retries" ]; then
      echo "retry"
    else
      kubectl logs -n "$namespace" job/"$jobname"
      echo "exit"
      exit 1
    fi
  done
}

echo "scaling down kyverno and deleting webhooks"
kubectl apply --server-side -f kyverno-scale-to-zero.yaml

wait_for_job kyverno kyverno-scale-to-zero 60 5

echo "applying Kyverno v1.13.4 manifests"
kustomize build ../../ | kubectl apply -f - --server-side
sleep 10
kustomize build ../../ | kubectl apply -f - --server-side
echo

echo "migration resources"
kubectl apply --server-side -f kyverno-migrate-resources-sa.yaml
kubectl apply --server-side -f kyverno-migrate-resources-role.yaml
kubectl apply --server-side -f kyverno-migrate-resources-binding.yaml
kubectl apply --server-side -f kyverno-migrate-resources-job.yaml
echo

echo "cleaning policy reports"
kubectl apply --server-side -f kyverno-clean-reports.yaml
echo "waiting for clean-reports job to complete"
echo

echo "checking pods"
kubectl get pods -n kyverno
echo
echo "checking clusterpolicies"
kubectl get clusterpolicies.kyverno.io
echo

echo "cleaning up"
kubectl delete -f kyverno-scale-to-zero.yaml
kubectl delete -f kyverno-migrate-resources-binding.yaml
kubectl delete -f kyverno-migrate-resources-role.yaml
kubectl delete -f kyverno-migrate-resources-sa.yaml
kubectl delete -f kyverno-migrate-resources-job.yaml
echo
