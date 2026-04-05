---
title: 'Dex SSH Connector'
description: Fork of Dex OIDC identity provider adding an SSH connector for SSH-key-based authentication to Kubernetes clusters.
publishDate: 'Jan 01 2026'
isFeatured: true
seo:
  title: 'Dex SSH Connector'
  description: Dex OIDC fork with SSH connector for key-based Kubernetes authentication.
---

The Dex SSH Connector is a fork of the [Dex](https://dexidp.io/) OIDC identity provider that adds a new SSH connector type. This connector enables SSH-key-based authentication to Kubernetes clusters, bridging the gap between traditional SSH infrastructure and modern OIDC-based access control.

The connector supports two authentication modes: JWT token exchange, where a signed JWT is exchanged for an OIDC token, and challenge/response, where the server issues a cryptographic challenge that the client signs with their SSH private key. Both modes produce standard OIDC tokens that Kubernetes can consume natively for RBAC decisions.

This project is the server-side companion to [kubectl-ssh-oidc](https://github.com/nikogura/kubectl-ssh-oidc). Together, they provide a complete passwordless authentication flow for Kubernetes that leverages existing SSH key infrastructure. Organizations that already manage SSH keys can extend that investment to Kubernetes access without deploying additional credential management systems.

The fork maintains compatibility with upstream Dex, so all existing connectors (LDAP, SAML, GitHub, etc.) continue to work alongside the new SSH connector. This makes it straightforward to adopt incrementally in environments that already use Dex for identity federation.

GitHub: [https://github.com/nikogura/dex](https://github.com/nikogura/dex)
