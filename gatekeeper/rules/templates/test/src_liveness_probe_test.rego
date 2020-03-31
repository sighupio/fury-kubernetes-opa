package k8slivenessprobe

test_liveness {
    input := {"request": review}
    results:= violation with input as input
    count(results) == 0
}

review = output {
  output = {
    "kind": {
      "kind": "Deployment",
      "version": "v1",
      "group": "apps",
    },
    "namespace": "test",
    "name": "deployment-without-liveness",
    "object": {
        "spec": {
           "replicas": 1,
           "selector": {
              "matchLabels": {
                 "run": "deployment-allowed"
              }
           },
           "strategy": {},
           "template": {
              "metadata": {
                 "creationTimestamp": null,
                 "labels": {
                    "run": "deployment-allowed"
                 }
              },
              "spec": {
                 "containers": [
                    {
                       "image": "redis:5.0.8",
                       "name": "deployment-allowed",
                                                                 "livenessProbe": {
                         "exec": null,
                         "command": [
                            "cat",
                            "/tmp/healthy"
                         ],
                       },
                       "securityContext": {
                          "runAsNonRoot": true,
                          "runAsUser": 1001
                       },
                       "resources": {
                          "requests": {
                             "memory": "60Mi",
                             "cpu": "30m"
                          },
                          "limits": {
                             "memory": "80Mi",
                             "cpu": "50m"
                          }
                       }
                    }
                 ]
              }
           }
        }
    }
}
}


#{
#   "apiVersion": "apps/v1",
#   "kind": "Deployment",
#   "metadata": {
#      "creationTimestamp": null,
#      "labels": {
#         "run": "deployment-allowed"
#      },
#      "name": "deployment-allowed",
#      "namespace": "default"
#   },
#   "spec": {
#      "replicas": 1,
#      "selector": {
#         "matchLabels": {
#            "run": "deployment-allowed"
#         }
#      },
#      "strategy": {},
#      "template": {
#         "metadata": {
#            "creationTimestamp": null,
#            "labels": {
#               "run": "deployment-allowed"
#            }
#         },
#         "spec": {
#            "containers": [
#               {
#                  "image": "redis:5.0.8",
#                  "name": "deployment-allowed",
#                  "securityContext": {
#                     "runAsNonRoot": true,
#                     "runAsUser": 1001
#                  },
#                  "resources": {
#                     "requests": {
#                        "memory": "60Mi",
#                        "cpu": "30m"
#                     },
#                     "limits": {
#                        "memory": "80Mi",
#                        "cpu": "50m"
#                     }
#                  }
#               }
#            ]
#         }
#      }
#   }
#}
