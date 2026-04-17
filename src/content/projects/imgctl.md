---
title: 'imgctl'
description: Secure gRPC-based artifact promotion tool for container images (ECR) and static content (S3) with OIDC authentication, group-based authorization, and full audit logging.
publishDate: 'Mar 01 2026'
isFeatured: false
seo:
  title: 'imgctl - Artifact Promotion Tool'
  description: Secure artifact promotion for container images and static content with OIDC authentication and group-based authorization.
---

**imgctl** is a secure, gRPC-based tool for promoting artifacts between environments (dev → staging → production) with proper authentication, authorization, and audit logging. It handles both container images (ECR via crane) and static content/SPAs (S3 via cross-account sync).

## The Problem

Artifact promotion between environments typically relies on CI pipeline credentials or manual processes with inadequate audit trails. You need to know who promoted what, when, and to which environment — and you need to enforce that only authorized teams can promote to production. This applies equally to container images and static website/SPA deployments.

## How It Works

imgctl uses the same SSH-key-based authentication chain as [kubectl-ssh-oidc](https://github.com/nikogura/kubectl-ssh-oidc) and the [Dex SSH Connector](https://github.com/nikogura/dex):

1. Client creates an SSH-signed JWT using the user's SSH key (via ssh-agent)
2. JWT is exchanged with Dex for an OIDC token
3. OIDC token is sent to the imgctl gRPC server
4. Server validates the token and checks group membership
5. On success, the server dispatches to the appropriate promotion handler:
   - **Container images** → copied between ECR registries via crane
   - **Static content/SPAs** → synced between S3 buckets via cross-account copy

Every operation is logged with full user attribution. Optional Slack notifications alert teams when artifacts are promoted.

## Features

- **gRPC API** with protobuf — fast, type-safe, with generated client/server code
- **Dual promotion** — container images (ECR) and static content (S3)
- **OIDC Authentication** via SSH-signed JWTs exchanged through Dex
- **Group-Based Authorization** — control who can promote to which environments
- **Audit Logging** — comprehensive logging of all operations with user attribution
- **Slack Integration** — optional notifications for promotions
- **Cross-Platform** — darwin/linux, amd64/arm64 releases via GitHub Actions

[View on GitHub →](https://github.com/nikogura/imgctl)
