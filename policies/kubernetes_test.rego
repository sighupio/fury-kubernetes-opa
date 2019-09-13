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
            memory: 50Mi
      - name: cert-manager
        image: "nginx:1.17"
        resources:
          requests:
            cpu: 50m
            memory: 50Mi
  `)
}
