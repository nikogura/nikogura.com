---
title: 'Managed Secrets'
description: A YAML interface on Hashicorp Vault for declarative secret generation, rotation, and access control.
publishDate: 'May 01 2020'
isFeatured: false
seo:
  title: 'Managed Secrets'
  description: Declarative YAML interface for managing secrets in Hashicorp Vault.
---

Managed Secrets provides a declarative YAML interface on top of Hashicorp Vault. Instead of interacting with Vault's API directly or writing custom automation for each secret, teams define their secrets in YAML and the system handles generation, rotation, and access control automatically.

The tool abstracts away Vault's operational complexity while preserving its security model. Secret definitions specify what type of secret is needed, who should have access, and how often it should rotate. Managed Secrets translates these declarations into the appropriate Vault API calls, policies, and authentication configurations.

This approach makes secrets management accessible to teams that need Vault's security guarantees but do not want to become Vault experts. It also brings secrets management into the GitOps workflow: secret definitions can be version-controlled, reviewed, and audited through standard git processes, with the actual secret values never leaving Vault.

Managed Secrets is particularly useful in environments with many services that each need their own credentials. Rather than writing bespoke provisioning scripts for each service, operators define the desired state in YAML and let the system converge.

GitHub: [https://github.com/nikogura/managed-secrets](https://github.com/nikogura/managed-secrets)
