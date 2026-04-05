---
title: 'kubectl-ssh-oidc'
description: Kubernetes CLI plugin for passwordless, SSH-key-based cluster authentication via OIDC.
publishDate: 'Jan 01 2026'
isFeatured: true
seo:
  title: 'kubectl-ssh-oidc'
  description: Kubernetes CLI plugin enabling SSH-key-based OIDC authentication for K8s clusters.
---

kubectl-ssh-oidc is a Kubernetes CLI plugin that enables passwordless, SSH-key-based authentication to Kubernetes clusters via OIDC. Instead of dealing with browser-based OAuth flows or password prompts, users authenticate using their existing SSH keys, making cluster access seamless and scriptable.

The plugin works by exchanging SSH key signatures for OIDC tokens, which are then used for standard Kubernetes RBAC authorization. This approach brings the familiar SSH authentication model into the Kubernetes ecosystem without sacrificing security or auditability.

kubectl-ssh-oidc is designed to work alongside the companion [Dex SSH Connector](https://github.com/nikogura/dex), which adds SSH-based authentication to the Dex OIDC identity provider. Together, they provide a complete solution for SSH-key-based Kubernetes authentication that integrates cleanly with existing infrastructure.

The plugin supports both JWT token exchange and challenge/response authentication modes, giving operators flexibility in how they deploy and manage cluster access. It is particularly well-suited for environments where browser-based OAuth is impractical, such as CI/CD pipelines, headless servers, or air-gapped networks.

GitHub: [https://github.com/nikogura/kubectl-ssh-oidc](https://github.com/nikogura/kubectl-ssh-oidc)
