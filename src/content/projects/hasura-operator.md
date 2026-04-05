---
title: 'Hasura Operator'
description: Kubernetes Operator for declarative Hasura GraphQL deployment and management, making Hasura GitOps-ready.
publishDate: 'Jun 01 2024'
isFeatured: false
seo:
  title: 'Hasura Operator'
  description: Kubernetes Operator for declarative, GitOps-ready Hasura GraphQL deployment.
---

The Hasura Operator is a Kubernetes Operator that brings declarative, GitOps-ready management to Hasura GraphQL Engine deployments. Instead of manually configuring Hasura instances through the console or imperative API calls, teams can define their entire Hasura configuration as Kubernetes custom resources and manage it through standard GitOps workflows.

The operator handles the full lifecycle of Hasura deployments, including provisioning, configuration, metadata management, and upgrades. Changes to Hasura configuration are expressed as Kubernetes resource updates, which means they flow through the same review, approval, and audit processes as all other infrastructure changes.

By making Hasura deployments fully declarative, the operator eliminates configuration drift between environments and makes it straightforward to replicate production configurations in staging or development. Teams can version their entire GraphQL API configuration alongside their application code.

GitHub: [https://github.com/nikogura/hasura-operator](https://github.com/nikogura/hasura-operator)
