package kubernetes.corp

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

test_allow_deployment {
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

test_deny_latest_tag {
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

test_deny_no_tag {
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

test_deny_deployment_two_containers_same_pod {
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

test_allow_pod_with_resources {
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
  initContainers:
    - name: wget
      image: busybox:1.1
      command: ['wget']
      args:  ['release-name-spring-resteasy:80/{artifactId}/hello?name=test']
      resources:
        limits:
          cpu: 100m
          memory: 128Mi
        requests:
          cpu: 100m
          memory: 128Mi
  containers:
    - name: wget
      image: busybox:1.1
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

test_deny_pod_without_resources {
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
  initContainers:
    - name: wget
      image: busybox:1.1
      command: ['wget']
      args:  ['release-name-spring-resteasy:80/{artifactId}/hello?name=test']
      resources:
        limits:
          cpu: 100m
          memory: 128Mi
        requests:
          cpu: 100m
          memory: 128Mi
  containers:
    - name: wget
      image: busybox:1.1
      command: ['wget']
      args:  ['release-name-spring-resteasy:80/{artifactId}/hello?name=test']
  restartPolicy: Never

  `)
}

# test_deny_initcontainers_without_resources {
# 	denied with input as yaml.unmarshal(`
# apiVersion: v1
# kind: Pod
# metadata:
#   name: "release-name-spring-resteasy-test-connection"
#   namespace: lab-devops-space
#   labels:
#     app.kubernetes.io/name: spring-resteasy
#     helm.sh/chart: spring-resteasy-0.1.0
#     app.kubernetes.io/instance: release-name
#     app.kubernetes.io/version: "1.0"
#     app.kubernetes.io/managed-by: Tiller
#   annotations:
#     "helm.sh/hook": test-success
# spec:
#   initContainers:
#     - name: wget
#       image: busybox:1.1
#       command: ['wget']
#       args:  ['release-name-spring-resteasy:80/{artifactId}/hello?name=test']
#   containers:
#     - name: wget
#       image: busybox:1.1
#       command: ['wget']
#       args:  ['release-name-spring-resteasy:80/{artifactId}/hello?name=test']
#       resources:
#         limits:
#           cpu: 100m
#           memory: 128Mi
#         requests:
#           cpu: 100m
#           memory: 128Mi
#   restartPolicy: Never

#   `)
# }

test_deny_pod_no_requests {
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

test_deny_pod_two_containers_admission {
  denied with input as 
{
    "apiVersion": "admission.k8s.io/v1beta1",
    "kind": "AdmissionReview",
    "request": {
      "dryRun": false,
      "kind": {
        "group": "",
        "kind": "Pod",
        "version": "v1"
      },
      "namespace": "default",
      "object": {
        "metadata": {
          "annotations": {
            "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Pod\",\"metadata\":{\"annotations\":{},\"name\":\"two-containers\",\"namespace\":\"default\"},\"spec\":{\"containers\":[{\"image\":\"nginx\",\"name\":\"nginx-container\",\"volumeMounts\":[{\"mountPath\":\"/usr/share/nginx/html\",\"name\":\"shared-data\"}]},{\"args\":[\"-c\",\"echo Hello from the debian container \\u003e /pod-data/index.html\"],\"command\":[\"/bin/sh\"],\"image\":\"debian\",\"name\":\"debian-container\",\"volumeMounts\":[{\"mountPath\":\"/pod-data\",\"name\":\"shared-data\"}]}],\"restartPolicy\":\"Never\",\"volumes\":[{\"emptyDir\":{},\"name\":\"shared-data\"}]}}\n"
          },
          "creationTimestamp": "2019-11-25T09:01:02Z",
          "name": "two-containers",
          "namespace": "default",
          "uid": "1b5cbe25-0f62-11ea-9cd0-26baf04710c6"
        },
        "spec": {
          "containers": [
            {
              "image": "nginx",
              "imagePullPolicy": "Always",
              "name": "nginx-container",
              "resources": {},
              "terminationMessagePath": "/dev/termination-log",
              "terminationMessagePolicy": "File",
              "volumeMounts": [
                {
                  "mountPath": "/usr/share/nginx/html",
                  "name": "shared-data"
                },
                {
                  "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                  "name": "default-token-657q2",
                  "readOnly": true
                }
              ]
            },
            {
              "args": [
                "-c",
                "echo Hello from the debian container \u003e /pod-data/index.html"
              ],
              "command": [
                "/bin/sh"
              ],
              "image": "debian",
              "imagePullPolicy": "Always",
              "name": "debian-container",
              "resources": {},
              "terminationMessagePath": "/dev/termination-log",
              "terminationMessagePolicy": "File",
              "volumeMounts": [
                {
                  "mountPath": "/pod-data",
                  "name": "shared-data"
                },
                {
                  "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                  "name": "default-token-657q2",
                  "readOnly": true
                }
              ]
            }
          ],
          "dnsPolicy": "ClusterFirst",
          "priority": 0,
          "restartPolicy": "Never",
          "schedulerName": "default-scheduler",
          "securityContext": {},
          "serviceAccount": "default",
          "serviceAccountName": "default",
          "terminationGracePeriodSeconds": 30,
          "tolerations": [
            {
              "effect": "NoExecute",
              "key": "node.kubernetes.io/not-ready",
              "operator": "Exists",
              "tolerationSeconds": 300
            },
            {
              "effect": "NoExecute",
              "key": "node.kubernetes.io/unreachable",
              "operator": "Exists",
              "tolerationSeconds": 300
            }
          ],
          "volumes": [
            {
              "emptyDir": {},
              "name": "shared-data"
            },
            {
              "name": "default-token-657q2",
              "secret": {
                "secretName": "default-token-657q2"
              }
            }
          ]
        },
        "status": {
          "phase": "Pending",
          "qosClass": "BestEffort"
        }
      },
      "oldObject": null,
      "operation": "CREATE",
      "resource": {
        "group": "",
        "resource": "pods",
        "version": "v1"
      },
      "uid": "1b5cc30a-0f62-11ea-9cd0-26baf04710c6",
      "userInfo": {
        "groups": [
          "system:masters",
          "system:authenticated"
        ],
        "username": "minikube-user"
      }
    }
  }
}