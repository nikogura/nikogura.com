---
title: 'DDCRI: Declarative, Deterministic, Continuously Reconciling Infrastructure'
excerpt: What's in git is what's in your infrastructure — or alarms are sounding. DDCRI is the discipline that makes that sentence literally true — FluxCD, Kustomize, Crossplane, and Upjet reconciling a control repository continuously, with drift wired up as a pageable condition. A canonical, example-driven walkthrough.
publishDate: 'Jun 18 2026'
tags:
  - GitOps
  - Kubernetes
  - Crossplane
  - FluxCD
isFeatured: true
---

I've written, in pieces, about most of the ideas here: [most Infrastructure as Code is broken](/blog/most-infrastructure-as-code-is-broken) because it describes state instead of maintaining it, [GitOps](/blog/gitops) is a reconciliation loop and not "YAML in git," a [control repository](/blog/control-repositories) is the release artifact, and [trunk-based development](/blog/trunk-based-development) is how you change it safely. This is the post that puts them together into one named discipline, with a worked example you can copy.

Call it **DDCRI** — Declarative, Deterministic, Continuously Reconciling Infrastructure. The whole thing exists to make one sentence literally true:

> What's in git is what's in your infrastructure — or alarms are sounding.

Not "should be." *Is.* And when it isn't — when the live system has drifted from the declaration, or the loop that's supposed to converge them has stalled — that is not a surprise you discover during an incident. It's an alert that already fired.

## The Four Properties, and Why All Four Are Load-Bearing

DDCRI is four claims at once. Drop any one and the sentence above stops being true.

- **Declarative** — you write the desired end state, not the steps to reach it. The system figures out the diff. Imperative tooling (`kubectl apply` from a laptop, a `terraform apply` someone ran by hand) describes a *transition*, and a transition is only correct relative to a starting state you're assuming and can't prove.
- **Deterministic** — the same inputs produce the same output, every time, on any machine, forever. This is the property nobody respects, and it's the one Helm's templating and Argo's UI quietly leak. If `render` can return different YAML depending on the wall clock, a freshly generated secret, or the current state of the cluster, then "what's in git" no longer has a single meaning, and the whole guarantee collapses into "what's in git, probably, today."
- **Continuously Reconciling** — a controller runs inside the cluster, forever, comparing actual state to declared state and correcting the difference. Not once, on commit — *continuously*, on an interval. This is the difference between a photograph and a thermostat. One-shot tools (Terraform, CDK, CloudFormation) take a photograph at apply time; the moment someone touches the system out-of-band, the photo is a lie and nothing corrects it. A reconciler is a thermostat: it doesn't care how the room got cold, it just keeps making it warm — and stops when it's warm enough.
- **Infrastructure** — and this is the word that makes DDCRI more than "GitOps for Kubernetes." Not just your in-cluster manifests. Your *cloud* resources — the S3 buckets, the RDS instances, the IAM roles, the VPCs — managed by the same reconciler, under the same loop, with the same guarantee. Crossplane is what extends the thermostat out past the cluster boundary into your cloud account.

Here is the same idea as a table — each property maps to a tool, and to a specific failure you're buying out of:

| Property | Delivered by | Without it you get |
| --- | --- | --- |
| Declarative | Kustomize, Crossplane CRDs | transitions that assume a starting state you can't prove |
| Deterministic | Kustomize (`kustomize build` is referentially transparent) | "what's in git, probably, today" |
| Continuously Reconciling | FluxCD controllers | a photograph that silently becomes a lie |
| Infrastructure (cloud included) | Crossplane (alone, or via Upjet providers) | a reconciled cluster sitting on un-reconciled cloud |

## The Stack

The canonical DDCRI stack is deliberately small. Every piece is here either to satisfy one of the four properties or to be the practice that keeps them honest; nothing is here for fashion.

- **[FluxCD](/blog/flux-vs-argo)** is the reconciler — the *Continuously Reconciling* half. Its source-controller watches the control repository; its kustomize-controller renders and applies, prunes what you've deleted, and corrects drift on an interval. It has no UI and no sync button, which is a feature: the only way to change the cluster is to change git. And it lives *inside each cluster* — the controllers run next to the workloads they manage, so every cluster reconciles itself independently against git rather than waiting on a central server to push to it. That decentralization is a resilience property, not a detail. There is no central control plane every cluster leans on the way an ArgoCD server is leaned upon, so there is none to take down: your critical infrastructure keeps converging even when the rest of your tooling is on fire. And if git itself becomes unreachable, nothing drifts or disappears — source-controller keeps serving the last revision it successfully fetched, and the cluster goes right on reconciling to that last-known-good state until git returns. A control-plane or git outage degrades you to "can't ship new changes," never to "running infrastructure falls apart."
- **[Kustomize](https://kustomize.io/)** is the renderer — the *Deterministic* half. It's a pure overlay system: bases plus declarative patches, no templating language, no functions, no logic. `kustomize build` is referentially transparent — same inputs, same YAML, forever. There is nowhere for non-determinism, or "Mr. Murphy" to get in.
- **[Crossplane](https://www.crossplane.io/)** is the cloud control plane — the *Infrastructure* half. It turns cloud resources into Kubernetes custom resources, so an S3 bucket is just an object with a `status.conditions` block that a controller reconciles exactly like a Deployment. Your cloud account becomes a set of CRDs under continuous reconciliation.
- **[Upjet](https://github.com/crossplane/upjet)** is part of Crossplane, not a separate tool — it's the Crossplane project's own code-generation framework (it lives in the Crossplane org as `crossplane/upjet`, the renamed successor to Terrajet). It's how Crossplane gets its *breadth*: Upjet generates Crossplane providers straight from existing Terraform providers — `provider-upjet-aws`, `provider-upjet-gcp`, `provider-upjet-azure` — so you inherit the full surface area of the Terraform provider ecosystem (thousands of resource types, maintained by the cloud vendors) without Terraform's one-shot, drift-blind apply model. It's the bridge that lets you leave Terraform behind without leaving its coverage behind.
- **The [Control Repository](/blog/control-repositories)** is the release artifact. Its `main` branch is the declaration of what should be running, everywhere, right now. A merge to main *is* the deployment; a tag is just a pointer.
- **[Trunk-Based Development](/blog/trunk-based-development)** is how you change it. Short-lived branches, render and validate in CI, review the rendered diff, merge to main, and the reconciler converges. No long-running branches, because the head of main is the state of the platform and the system of record — you don't want two of those.

## Why Not Helm

You'll notice Helm and `HelmRelease` are absent. That's deliberate, and it's about the *Deterministic* 'D' in 'DDCRI'.

Helm is a templating engine. Its templates can call `now`, `randAlphaNum`, `uuidv4`, and — worst of all — `lookup`, which reads the live cluster at render time. A chart can render differently depending on the clock, a freshly generated secret, or the current state of the cluster it happens to be pointed at. On top of that, `HelmRelease` stores release state *in the cluster*, so the reconciler's behavior now depends on history that doesn't live in git. The diff is opaque: when you bump a chart from `1.2.3` to `1.2.4`, the PR shows one line changed, and you have no idea what resources, RBAC grants, or containers that actually adds or removes until it's running. Every one of those is a determinism leak and opportunity for "Murphy's Law" to bite you.

So by default, DDCRI excludes it. But there are two honest positions short of "never":

- **Helm as a build-time renderer, not a runtime.** You can still use the vast Helm ecosystem.  Run `helm template` (or Kustomize's `helmCharts` inflation generator) at build time, render the chart to plain YAML, feed *that* through Kustomize, and commit it to git. You keep the chart ecosystem and you keep determinism, because the templating happens once, under review, with no in-cluster `lookup` and no release state. This is the compromise I reach for: Helm as a *renderer*, the same role Kustomize plays, not a *reconciler*.  `git diff` is your answer to "what is the effect of this change?".
- **`HelmRelease` if you knowingly trade determinism away.** Flux's helm-controller will reconcile a `HelmRelease` continuously — you keep the loop, you keep drift correction, you keep the audit trail. You give up full determinism and the reviewable diff. Some shops will want to make that trade on purpose, usually for a sprawling third-party chart they don't want to vendor, or teams that like that kind of flexibility in their product. That's a legitimate choice *as long as you name the cost out loud*: you've dropped one of the four letters, and "what's in git is what's in your infra" weakens to "what's in git plus whatever that chart decided to render this time."

The right answer isn't "Helm or no Helm" across the whole platform — it's matching the *degree of determinism to the blast radius*. Determinism is most valuable exactly where a surprise is most expensive. The foundational layers — the cluster itself, networking, identity, cloud resources, the shared platform services everything else depends on — have enormous blast radius, and those should be fully deterministic: reviewable diffs, referential transparency, no render-time surprises, full stop. A wrong apply there takes down everyone.

A single product or component is a different calculation. Its blast radius is contained, its team owns its own failure, and it may genuinely move faster by living off a Helm chart and the ecosystem around it. That's a legitimate choice, and `HelmRelease` is built for it — Flux's helm-controller gives you as much flexibility as you want or can tolerate, while still keeping the resource inside the reconcile loop with drift correction and a git audit trail. You're trading the reviewable diff for iteration speed, on a system where that trade is cheap.

So choosing Helm is a real, defensible decision — driven by the team, the product, and how much determinism you actually need. The only wrong version is the accidental one: Helm in the reconcile path of a high-blast-radius foundation because nobody made the call on purpose. Decide where each component sits on the blast-radius axis, then decide how deterministic it has to be. Determinism where it's load-bearing; flexibility where it's affordable.

## A Canonical Example

Here's a control repository that brings cloud resources — an S3 bucket, an RDS database — under the same reconciler that manages the cluster, with the same guarantee.  This is a monorepo, for simplicity's sake. The same concept works however you slice the repositories — one repo for everything, or one per environment or cluster; on disk it's just a file tree either way.

### Repository Layout

```
control-repo/
└── clusters/                              # one dir per cluster — everything it runs lives here
    ├── production/
    │   ├── flux-system/                   # Flux bootstrap + the per-area Kustomization CRs
    │   │   ├── gotk-components.yaml        #   the Flux controllers
    │   │   ├── gotk-sync.yaml              #   entry Kustomization → reconciles clusters/production
    │   │   ├── infrastructure.yaml         #   Kustomization CRs: crossplane → cloud (dependsOn) → addons
    │   │   ├── monitoring.yaml             #   Kustomization → ../monitoring
    │   │   └── apps.yaml                   #   Kustomization → ../apps
    │   ├── infrastructure/
    │   │   ├── crossplane/                 # provider packages + provider configs
    │   │   │   ├── providers.yaml
    │   │   │   ├── provider-config.yaml
    │   │   │   └── kustomization.yaml
    │   │   ├── cloud/                      # Crossplane managed resources (S3, RDS, IAM, ...)
    │   │   │   ├── buckets.yaml
    │   │   │   ├── databases.yaml
    │   │   │   └── kustomization.yaml
    │   │   └── addons/                     # ingress, cert-manager, CNI extras, ...
    │   │       └── kustomization.yaml
    │   ├── monitoring/                     # kube-prometheus-stack + the DDCRI rules/routing
    │   │   ├── kube-prometheus-stack.yaml
    │   │   ├── prometheus-rules.yaml
    │   │   ├── alertmanager-config.yaml
    │   │   └── kustomization.yaml
    │   └── apps/                           # the cluster's workloads
    │       └── kustomization.yaml
    └── staging/                            # the staging cluster — its own full tree
        └── ...
```

Everything a cluster runs lives under that cluster's directory — there is nothing to reconcile that sits outside one. `clusters/production/flux-system/` is the bootstrap: the Flux controllers, the entry Kustomization that reconciles the rest of `clusters/production/`, and the per-area Flux `Kustomization` CRs that give each slice its own interval, pruning, and ordering — `cloud` `dependsOn` `crossplane`, so managed resources never reconcile before their providers exist. The directories beside it — `infrastructure/`, `monitoring/`, `apps/` — are the actual manifests for *this* cluster, not references to a shared base. Add another cluster and it's a sibling under `clusters/` with its own complete tree.

The duplication between `production` and `staging` is deliberate, not a smell — DRY is the wrong instinct here. The flat, repeated trees make the two questions you actually care about answerable with one plain command each:

- **How does staging differ from production?** `diff -ruN clusters/production clusters/staging` — the complete, literal delta between two environments, with no overlay indirection to mentally render. (`-N` so a resource present in only one environment still shows as a full diff, not a terse "only in" line.)
- **What just changed in staging?** `git diff -- clusters/staging` — the exact effect of a proposed or recent change, scoped to that one cluster.
- **What changed historically in production?** `git log -- clusters/production` — the audit trail of that cluster.  Who did what, and when.  Git gives you this for free.

Each cluster's full desired state is right there to read; repetition you can diff beats cleverness you have to render in your head. A shared-base, overlay-heavy layout hides both of those answers — you can't diff two environments when half of each is assembled at build time from files they share.

And none of this depends on how you slice repositories. One monorepo or a repo per environment — `diff` and `git diff` operate on directories on disk, not on repo boundaries. Check the trees out wherever they live and compare them; the repo split is a packaging decision, while the diffability is an intrinsic property of the trees. That's the same point as the monorepo note above: on disk, it's all just a file tree.

The cloud resources are no exception: the Crossplane objects under `clusters/production/infrastructure/cloud/` are applied into this cluster, which runs Crossplane and projects them onto your cloud account. The cluster is always the point of application.

### The Reconciler

Flux watches the repo, and `clusters/production/flux-system/` holds the per-area Flux `Kustomization` CRs that reconcile each slice of the production cluster. Here's the one for the cloud layer — it `dependsOn` the Crossplane providers, so the managed resources never try to reconcile before the providers that own them are installed. Note `prune: true`: this is what makes it *reconciliation* and not merely *additive apply*. Delete a file from git and the reconciler prunes the object it created — and what that does to the underlying cloud resource is the `deletionPolicy` question we reach below.

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: control-repo
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/acme/control-repo
  ref:
    branch: main
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: cloud
  namespace: flux-system
spec:
  interval: 10m
  dependsOn:
    - name: crossplane          # providers installed before their resources reconcile
  sourceRef:
    kind: GitRepository
    name: control-repo
  path: ./clusters/production/infrastructure/cloud
  prune: true        # remove from git → prune the object; deletionPolicy decides the cloud resource
  wait: true
  timeout: 5m
```

### The Cloud, as Declarative Objects

First the Upjet-based provider and its config:

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-s3
spec:
  package: xpkg.upbound.io/upbound/provider-aws-s3:v1
---
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: IRSA          # workload identity, not a long-lived key
```

Then the bucket itself — an S3 bucket is now just a Kubernetes object with conditions:

```yaml
apiVersion: s3.aws.upbound.io/v1beta1
kind: Bucket
metadata:
  name: acme-prod-artifacts
spec:
  forProvider:
    region: us-west-2
  providerConfigRef:
    name: default
  deletionPolicy: Delete   # git is the source of truth, all the way to the cloud
---
apiVersion: s3.aws.upbound.io/v1beta1
kind: BucketVersioning
metadata:
  name: acme-prod-artifacts
spec:
  forProvider:
    region: us-west-2
    bucketRef:
      name: acme-prod-artifacts
    versioningConfiguration:
      - status: Enabled
  providerConfigRef:
    name: default
```

Crossplane now reconciles those objects against AWS on its poll interval, the same way Flux reconciles the manifests against the cluster. Someone disables versioning in the console? Crossplane turns it back on. Someone deletes the `BucketVersioning` file from git? Flux prunes the object, Crossplane removes the configuration from the bucket. The cloud is a pure function of the repository — and, with `deletionPolicy: Delete`, that includes deletion.

That last part should make you nervous about stateful resources, and it should — which is exactly why Crossplane lets you decouple "remove from git" from "destroy in the cloud." The `deletionPolicy` field controls what happens to the *external* resource when its managed resource is removed: `Delete` tears it down, `Orphan` leaves it standing. Set your databases to `Orphan` and an "oops" in the control repository — a bad rebase, an accidental `git rm`, an overzealous prune — deletes the *Kubernetes object*, not your production data:

```yaml
apiVersion: rds.aws.upbound.io/v1beta2
kind: Instance
metadata:
  name: acme-prod-db
spec:
  deletionPolicy: Orphan      # remove from git → Crossplane stops managing it, but the RDS instance lives on
  forProvider:
    region: us-west-2
    instanceClass: db.r6g.xlarge
    engine: postgres
    allocatedStorage: 200
  providerConfigRef:
    name: default
```

This is the right default for anything you can't recreate from code alone — databases, stateful stores, anything holding data. The configuration is still fully declarative and reconciled (Crossplane keeps the live instance matching the spec while the object exists); you've only told it that *un-declaring* a database is not the same as *deleting* one. Reserve `deletionPolicy: Delete` for the resources where a `git rm` genuinely should mean "make it gone" — the stateless, reproducible ones. The determinism is identical either way; you're only choosing the teardown semantics, per resource, deliberately.

### Keeping It Deterministic in CI

Trunk-based development is what makes this safe to change. A short-lived branch opens a PR; CI renders the *actual* output and validates it, so the reviewer reads what will run, not what was typed:

```bash
# Deterministic render → schema validation. Same output on every machine.
kustomize build clusters/production/infrastructure/cloud | kubeconform -strict -summary

# If you use Crossplane composition functions, render them too — and keep them
# deterministic (no clocks, no randomness), exactly like the no-Helm-templating rule.
crossplane render xr.yaml composition.yaml functions.yaml
```

The diff in the PR is the rendered diff. There's no `lookup`, no `now()`, no chart version hiding a hundred changed lines behind one. Review, merge to main, and within the reconcile interval the platform converges. That's the whole change-management story.

## Making the Guarantee Observable — "Or Alarms Are Sounding"

Everything above gives you the first half of the sentence: *what's in git is what's in your infrastructure.* This section is the second half — *or alarms are sounding* — and it's the part most GitOps writeups skip. A reconciliation loop that fails silently is worse than no loop, because it *looks* like it's working. The discipline is incomplete until **drift and reconciliation failure are pageable conditions**.

Both halves of the stack expose exactly what you need.

### What Flux Tells You

The Flux controllers export Prometheus metrics for every object they manage:

- `gotk_reconcile_condition{kind, name, exported_namespace, type, status}` — a gauge that is `1` for the condition currently held. `type="Ready", status="False"` means the object will not converge: git and the cluster have diverged and the reconciler can't close the gap.
- `gotk_suspend_status` — `1` when reconciliation is *suspended*. This one is DDCRI-specific and easy to overlook: a suspended Kustomization means the guarantee is **switched off** for that object. Git is no longer being enforced. That should never be silent.
- `gotk_reconcile_duration_seconds` — histogram of how long reconciliation takes, for the saturation signal.

### What Crossplane Tells You

Every Crossplane managed resource carries two conditions: `Synced` (can Crossplane reconcile your spec to the provider?) and `Ready` (is the external resource healthy?). `Synced="False"` is precisely "the cloud has drifted from git and Crossplane *cannot* correct it" — a permissions problem, an immutable-field conflict, an API rejection. That is the cloud-side drift alarm.

Surface those conditions to Prometheus with kube-state-metrics' Custom Resource State Metrics — wire in every managed-resource kind you care about:

```yaml
# kube-state-metrics custom resource state config
spec:
  resources:
    - groupVersionKind:
        group: s3.aws.upbound.io
        version: v1beta1
        kind: Bucket
      metricNamePrefix: crossplane_managed_resource
      metrics:
        - name: status_condition
          help: "Crossplane managed resource conditions"
          each:
            type: StateSet
            stateSet:
              labelName: status
              path: [status, conditions]
              list: ["True", "False", "Unknown"]
              valueFrom: [status]
              labelsFromPath:
                type: [type]
                name: [metadata, name]
```

That emits `crossplane_managed_resource_status_condition{type="Synced", status="False", name="acme-prod-artifacts"} 1` whenever the bucket can't be reconciled.

### The Alerts

Now the rules. This `PrometheusRule` is the heart of the second half of the sentence — every one of these firing means "git and reality have diverged, or the thing that's supposed to keep them together has stopped."

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: ddcri-reconciliation
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  groups:
    - name: ddcri.flux
      rules:
        - alert: FluxReconciliationFailing
          expr: |
            max by (exported_namespace, name, kind) (
              gotk_reconcile_condition{type="Ready", status="False"}
            ) == 1
          for: 10m
          labels:
            severity: page
          annotations:
            summary: "Flux {{ $labels.kind }} {{ $labels.exported_namespace }}/{{ $labels.name }} has not reconciled for 10m"
            description: "Git and the cluster have diverged and the reconciler cannot converge. What is in git is NOT what is running."

        - alert: FluxReconciliationSuspended
          expr: gotk_suspend_status == 1
          for: 15m
          labels:
            severity: warning
          annotations:
            summary: "Flux {{ $labels.kind }} {{ $labels.exported_namespace }}/{{ $labels.name }} is SUSPENDED"
            description: "The DDCRI guarantee is OFF for this object — git is no longer being enforced. Resume it, or document the exception."

    - name: ddcri.crossplane
      rules:
        - alert: CloudResourceDesynced
          expr: crossplane_managed_resource_status_condition{type="Synced", status="False"} == 1
          for: 10m
          labels:
            severity: page
          annotations:
            summary: "Crossplane {{ $labels.name }} is NOT synced to git"
            description: "Crossplane cannot reconcile the declared spec to the provider. Live cloud infrastructure has drifted from git and is not being corrected."

        - alert: CloudResourceNotReady
          expr: crossplane_managed_resource_status_condition{type="Ready", status="False"} == 1
          for: 15m
          labels:
            severity: warning
          annotations:
            summary: "Crossplane {{ $labels.name }} external resource is not Ready"
            description: "The managed resource is synced from git but the underlying cloud resource is unhealthy."
```

### Routing

Finally, route them. `page`-severity alerts (the cluster or cloud has actually diverged) go to the pager; `warning` (suspended, or healthy-but-not-ready) goes to chat. Here it is as a Prometheus-Operator `AlertmanagerConfig`, so the routing lives in the control repo like everything else:

```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: ddcri
  namespace: monitoring
spec:
  route:
    receiver: ddcri-chat
    groupBy: ["alertname", "kind", "name"]
    routes:
      - matchers:
          - name: severity
            value: page
        receiver: ddcri-pager
  receivers:
    - name: ddcri-chat
      slackConfigs:
        - apiURL:
            name: alertmanager-slack
            key: url
          channel: "#infra-reconciliation"
          title: '{{ .CommonAnnotations.summary }}'
          text: '{{ .CommonAnnotations.description }}'
    - name: ddcri-pager
      # any pager works here — PagerDuty, Opsgenie, or a plain webhook to your on-call
      webhookConfigs:
        - url: http://oncall-gateway.monitoring.svc/alert
```

## The Payoff

String the four properties together and you get a system with a property most infrastructure never has: the gap between intention and reality is *closed continuously and observably*.

- **Declarative** means git holds the end state, not a fragile sequence of steps.
- **Deterministic** means the diff in a pull request is the change that will happen — reviewable, honest, the same on every machine.
- **Continuously Reconciling** means drift gets corrected on a loop instead of discovered during an outage.
- **Infrastructure** means that guarantee reaches all the way into your cloud account, not just your cluster.

And the monitoring layer means the one failure mode left — the reconciler itself stalling, or hitting a divergence it can't close — is not something you find out about from a customer. It's a page.

That's the whole thesis, and now it's enforceable rather than aspirational: **what's in git is what's in your infrastructure — or alarms are sounding.** 

Build the loop, then instrument the loop. A reconciler you don't monitor is just a more confident way to be wrong.
