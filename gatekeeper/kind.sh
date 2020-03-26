#!/bin/bash

set -x

K8S_VERSION="${K8S_VERSION:-v1.15.6}"
K8S_WORKERS="${KIND_NODES:-1}"
KIND_FIX_KUBECONFIG="${KIND_FIX_KUBECONFIG:-false}"
KIND_REPLACE_CNI="${KIND_REPLACE_CNI:-false}"
KIND_OPTS="${KIND_OPTS:-}"
DOCKER_HOST_ALIAS="${DOCKER_HOST_ALIAS:-docker}"

KUBECTL="kubectl"

function install_cni() {
  $KUBECTL apply -f "https://cloud.weave.works/k8s/net?k8s-version=$($KUBECTL version | base64 | tr -d '\n')"
}

function start_kind() {
  cat > /tmp/kind-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
kubeadmConfigPatches:
- |
  apiVersion: kubeadm.k8s.io/v1beta2
  kind: ClusterConfiguration
  metadata:
    name: config
  apiServer:
    extraArgs:
      "enable-admission-plugins": "NamespaceLifecycle,ServiceAccount,DefaultStorageClass,ValidatingAdmissionWebhook"
nodes:
- role: control-plane
  image: kindest/node:${K8S_VERSION}
EOF

  if [[ $K8S_WORKERS -gt 0 ]]; then
    for i in $(seq 1 "${K8S_WORKERS}");
    do
      cat >> /tmp/kind-config.yaml <<EOF
- role: worker
  image: kindest/node:${K8S_VERSION}
EOF
    done
  fi
  
  cat >> /tmp/kind-config.yaml <<EOF
networking:
  apiServerAddress: 0.0.0.0
EOF

  if [[ "$KIND_REPLACE_CNI" == "true" ]]; then
    cat >> /tmp/kind-config.yaml <<EOF
  # Disable default CNI and install Weave Net to get around DIND issues
  disableDefaultCNI: true
EOF
  fi

  export KUBECONFIG="${HOME}/.kube/kind-config"

  kind  create cluster --config /tmp/kind-config.yaml

  if [[ "$KIND_FIX_KUBECONFIG" == "true" ]]; then  
    sed -i -e "s/server: https:\/\/0\.0\.0\.0/server: https:\/\/$DOCKER_HOST_ALIAS/" "$KUBECONFIG"
  fi

  if [[ "$KIND_REPLACE_CNI" == "true" ]]; then
    install_cni
  fi

  KUBECTL="$KUBECTL --kubeconfig=$KUBECONFIG"
  $KUBECTL cluster-info

  $KUBECTL -n kube-system rollout status deployment/coredns --timeout=180s
  $KUBECTL -n kube-system rollout status daemonset/kube-proxy --timeout=180s
  $KUBECTL get pods --all-namespaces

  kind get kubeconfig > config.yml
}


start_kind
