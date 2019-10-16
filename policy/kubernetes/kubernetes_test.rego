package main

denied {
	deny[_]
}

test_deployment_denied_missing_namespace {
	denied with input as yaml.unmarshal(`
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager
spec:
  template:
    spec:
      containers:
      - name: cert-manager
        image: "quay.io/jetstack/cert-manager-controller:v0.9.0"
        resources:
          requests:
            cpu: 50m
            memory: 50Mi
  `)
}

test_deployment_allowed {
	not denied with input as yaml.unmarshal(`
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager
  namespace: ns
spec:
  template:
    spec:
      containers:
      - name: cert-manager
        image: "quay.io/jetstack/cert-manager-controller:v0.9.0"
        resources:
          requests:
            cpu: 50m
            memory: 50Mi
  `)
}

test_denied_latest_tag {
	denied with input as yaml.unmarshal(`
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager
  namespace: ns
spec:
  template:
    spec:
      containers:
      - name: cert-manager
        image: "quay.io/jetstack/cert-manager-controller:latest"
        resources:
          requests:
            cpu: 50m
            memory: 50Mi
  `)
}

test_denied_no_tag {
	denied with input as yaml.unmarshal(`
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager
  namespace: ns
spec:
  template:
    spec:
      containers:
      - name: cert-manager
        image: "quay.io/jetstack/cert-manager-controller"
        resources:
          requests:
            cpu: 50m
            memory: 50Mi
  `)
}

test_deployment_denied_two_containers_same_pod {
	denied with input as yaml.unmarshal(`
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager
  namespace: ns
spec:
  template:
    spec:
      containers:
      - name: cert-manager
        image: "quay.io/jetstack/cert-manager-controller:v0.9.0"
        resources:
          requests:
            cpu: 50m
            memory: 50mi
      - name: proxy
        image: "nginx:1.17"
        resources:
          requests:
            cpu: 50m
            memory: 50mi
  `)
}

test_pod_with_resources {
	not denied with input as yaml.unmarshal(`
apiVersion: v1
kind: Pod
metadata:
  name: "release-name-spring-resteasy-test-connection"
  namespace: lab-devops-space
  labels:
    app.kubernetes.io/name: spring-resteasy
    helm.sh/chart: spring-resteasy-0.1.0
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "1.0"
    app.kubernetes.io/managed-by: Tiller
  annotations:
    "helm.sh/hook": test-success
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args:  ['release-name-spring-resteasy:80/{artifactId}/hello?name=test']
      resources:
        limits:
          cpu: 100m
          memory: 128Mi
        requests:
          cpu: 100m
          memory: 128Mi
  restartPolicy: Never

  `)
}

test_pod_no_requests {
	denied with input as yaml.unmarshal(`
apiVersion: v1
kind: Pod
metadata:
  name: "release-name-spring-resteasy-test-connection"
  namespace: lab-devops-space
  labels:
    app.kubernetes.io/name: spring-resteasy
    helm.sh/chart: spring-resteasy-0.1.0
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "1.0"
    app.kubernetes.io/managed-by: Tiller
  annotations:
    "helm.sh/hook": test-success
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args:  ['release-name-spring-resteasy:80/{artifactId}/hello?name=test']
      resources:
        limits:
          cpu: 100m
          memory: 128Mi
  restartPolicy: Never

  `)
}
