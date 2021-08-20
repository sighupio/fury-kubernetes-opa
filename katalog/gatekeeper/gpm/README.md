# Gatekeeper Policy Manager (GPM)

Gatekeeper Policy Manager is a simple **read-only** web UI for viewing OPA Gatekeeper policies' status in a Kubernetes Cluster.

It can display all the defined **Constraint Templates** with their rego code, and all the **Contraints** with its current status, violations, enforcement action, matches definitions, etc.

## Requirements

You'll need OPA Gatekeeper running in your cluster and at least some constraint templates and constraints defined to take advantage of this tool.

## Deploying GPM

To deploy Gatekeeper Policy Manager to your cluster, apply the provided `kustomization` file running the following command:

```shell
kubectl apply -k .
```

By default, this will create a deployment and a service both with the name `gatekeper-policy-manager` in the `gatekeeper-system` namespace. We invite you to take a look into the `kustomization.yaml` file to do further configuration.

We recommend you to create an ingress for the application, you can find a sample [here](https://github.com/sighupio/gatekeeper-policy-manager/blob/v0.5.0/manifests/ingress.yaml)

## Configuration

GPM is a stateless application, but it can be configured using environment variables. The possible configurations are:

| Env Var Name                      | Description                                                                                                       | Default                |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ---------------------- |
| `GPM_AUTH_ENABLED`                | Enable Authentication current options: "Anonymous", "OIDC"                                                        | Anonymous              |
| `GPM_SECRET_KEY`                  | The secret key used to generate tokens. **Change this value in production**.                                      | `g8k1p3rp0l1c7m4n4g3r` |
| `GPM_PREFERRED_URL_SCHEME`        | URL scheme to be used while generating links.                                                                     | `http`                 |
| `GPM_OIDC_REDIRECT_DOMAIN`        | The server name under the app is being exposed. This is where the client will be redirected after authenticating  |                        |
| `GPM_OIDC_ISSUER`                 | OIDC Issuer hostname                                                                                              |                        |
| `GPM_OIDC_AUTHORIZATION_ENDPOINT` | OIDC Authorizatoin Endpoint                                                                                       |                        |
| `GPM_OIDC_JWKS_URI`               | OIDC JWKS URI                                                                                                     |                        |
| `GPM_OIDC_TOKEN_ENDPOINT`         | OIDC TOKEN Endpoint                                                                                               |                        |
| `GPM_OIDC_INTROSPECTION_ENDPOINT` | OIDC Introspection Enpoint                                                                                        |                        |
| `GPM_OIDC_USERINFO_ENDPOINT`      | OIDC Userinfo Endpoint                                                                                            |                        |
| `GPM_OIDC_END_SESSION_ENDPOINT`   | OIDC End Session Endpoint                                                                                         |                        |
| `GPM_OIDC_CLIENT_ID`              | The Client ID used to authenticate against the OIDC Provider                                                      |                        |
| `GPM_OIDC_CLIENT_SECRET`          | The Client Secret used to authenticate against the OIDC Provider                                                  |                        |
| `GPM_LOG_LEVEL`                   | Log level (see [python logging docs](https://docs.python.org/2/library/logging.html#levels) for available levels) | `INFO`                 |
| `KUBECONFIG`                      | Path to a [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file, if provided while running inside a cluster this configuration file will be used instead of the cluster's API. |

> ⚠️ Please notice that OIDC Authentication is in beta state. It has been tested to work with Keycloak as a provider.

You can find a sample patch for these environment variables in the upstream [`enable-oidc.yaml`](https://github.com/sighupio/gatekeeper-policy-manager/blob/v0.4.0/manifests/enable-oidc.yaml) file.

Apply it as a patch, like this:

```yaml
patchesStrategicMerge:
  - enable-oidc.yaml
```

More information on the official repository: <https://github.com/sighupio/gatekeeper-policy-manager>
