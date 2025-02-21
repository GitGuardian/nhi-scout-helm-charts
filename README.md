# GitGuardian NHI Helm Charts

## Installation

Add the repository to Helm with:

```shell
helm repo add gg-nhi https://gitguardian.github.io/nhi-scout-helm-charts
```

Then install the scout, with a values file (examples below):

```shell
helm upgrade scout gg-nhi/nhi-scout --install --values values.yml
```

An example values file that fetches from HashiCorp Vault and GitLab CI:

```yaml
inventory:
  config:
    sources:
      vault-secrets:
        type: hashicorpvault
        vault_address: "https://your-vault-address-here"
        # Token configuration can be read from environment variables like so:
        auth_token: "${HASHICORP_VAULT_TOKEN}"
        fetch_all_versions: true
        path: "secret/"
      gitlabci:
        type: gitlabci
        token: "${GITLAB_TOKEN}"
        url: "https://gitlab.gitguardian.ovh"
    # To upload, set the gitguardian URL and tokens. Ensure the endpoint path ends with /v1
    # This is optional: omit this to prevent uploading and to only test collection.
    gitguardian:
      endpoint: "https://my-gg-instance/v1"
      api_token: "${GITGUARDIAN_API_KEY}"
  jobs:
    # Job to fetch defined sources
    fetch:
        # Set to `false` to disable the job
        enabled: true
        # Run every 15 minutes
        schedule: '*/15 * * * *'
        send: true
    # Job to be able to sync/write secrets from GitGuardian into you vault
    sync:
      # Set to `false` to disable the job
      enabled: true
      # Run every minute
      schedule: '* * * * *'

# This needs to be created separately (read instructions below), and contain the following keys:
# - `HASHICORP_VAULT_TOKEN` - the hashicorp vault token to use
# - `GITGUARDIAN_API_KEY` - the GitGuardian token to send results with
envFrom:
  - secretRef:
      name: gitguardian-nhi-scout-secrets
```

To create or update the secrets, you directly use Kubernetes `secrets` API. 
Create a file name `secrets.yaml` with the following content (replacing the values by your secrets):

```
apiVersion: v1
kind: Secret
metadata:
  name: gitguardian-nhi-scout-secrets
stringData:
    HASHICORP_VAULT_TOKEN: "my_vault_token"
    GITGUARDIAN_API_KEY: "my_gitguardian_api_key"
```

To apply the secrets to your cluster/namespace, run the following command: `kubectl apply -f secrets.yaml`

If you want to only fetch the identities without sending them, please see this [example](charts/nhi-scout/examples/fetch_only)

Other examples can be found in [charts/nhi-scout/examples](charts/nhi-scout/examples).

## Development

Install [mise](https://mise.jdx.dev/), then run the following command to run tests:

```shell
$ mise run test
```
