#!/bin/bash

echo "scaling down kyverno and deleting webhooks"
kubectl apply --server-side -f kyverno-scale-to-zero.yaml
echo

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
echo "checking policies"
kubectl get clusterpolicies.kyverno.io
echo
