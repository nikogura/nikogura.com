# Vault Operator Notes

* Namespace level resource that can reach other namespaces if RBAC is so configured.

* Vault Operator CRD will not create if it's rbac is not configured.  Pods won't even start.  Operator pod shows no errors.  Very confusing.

* Vault instance (by default) consists of a stateful set, a PVC (and PV of course) and a secret holding the unseal keys.  All 3 must be deleted to nuke and pave the vault instance.

## Secrets

Operator creates the following secrets:

* vault-operator-token-<random>

* vault-token-<random>     

Both are K8s service account tokens.  They appear to be independent of vault instances, though are used to connect to vault instances.

## Auth Test

Run the following.  (assumes port forwarding is set up)

    VAULT_ADDR=http://localhost:8200 vault write auth/kubernetes/login role=default jwt=$(k get secret $(k get secret | grep vault-token | awk '{print $1}')  -o json | jq -r .data.token | base64 -D)
    
## Nuke and Pave

    k delete vault <name>
    
    k delete pvc vault-file
    
    k delete secret vault-unseal-keys
    
## Cert Manager

Cert Manager has to be installed separately of course.  Then you need an issuer for it to use vault.

Example issuer:

    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: vault
      namespace: default
    spec:
      vault:
        path: pki/sign/default
        server: http://vault.default.svc.cluster.local:8200
        caBundle: (output of `curl http://localhost:8200/v1/pki/ca/pem | base64`)
        auth:
          kubernetes:
            role: default
            mountPath: /v1/auth/kubernetes
            secretRef:
              name: (output of `k get secret | grep vault-token | awk '{print $1}'`)
              key: token

The problem, of course, is that this resource cannot be created until the vault instance is up and running.  It would be amazing if we could get this included into the vault-operator.

In the meantime, I'll probably do some sort of a Job that no-ops until it gets something back from those two calls, and then creates the resource.

