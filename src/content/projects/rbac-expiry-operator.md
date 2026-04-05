---
title: 'RBAC Expiry Operator'
description: Kubernetes operator for time-limited RBAC grants with automatic expiration, drift correction, and Prometheus metrics.
publishDate: 'Jan 01 2026'
isFeatured: true
seo:
  title: 'RBAC Expiry Operator'
  description: Kubernetes operator providing time-limited RBAC with automatic expiration and compliance monitoring.
---

The RBAC Expiry Operator solves a compliance gap that Kubernetes does not address natively: time-limited RBAC grants. Kubernetes RBAC bindings are permanent by default, which means temporary access grants require manual cleanup. This operator automates that process, ensuring that elevated permissions expire on schedule without human intervention.

The operator introduces custom resources for defining RBAC bindings with expiration timestamps. When a binding expires, the operator automatically removes it. It also includes drift correction, so if someone manually recreates an expired binding, the operator detects the drift and removes it again, maintaining the intended security posture.

Built-in Prometheus metrics provide visibility into active grants, upcoming expirations, and drift correction events. This gives security and compliance teams the audit trail they need to demonstrate that temporary access controls are being enforced consistently.

The project also includes a kubectl plugin for convenient management of expiring RBAC grants from the command line. Operators can create, inspect, and revoke time-limited bindings without writing YAML manifests directly.

GitHub: [https://github.com/nikogura/rbac-expiry-operator](https://github.com/nikogura/rbac-expiry-operator)
