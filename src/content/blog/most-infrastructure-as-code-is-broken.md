---
title: "Most Infrastructure as Code Is Broken — and Reconciliation Is Only Half the Reason"
excerpt: "Run terraform plan against infrastructure nobody has touched in a month and watch it propose changes. That drift is the absence of a reconciliation loop. But the missing loop is only half of why most Infrastructure as Code is broken — and bolting a loop onto the other half just gets you to broken faster."
publishDate: 'June 2 2026'
tags:
  - Infrastructure as Code
  - GitOps
  - Kubernetes
  - Engineering
isFeatured: true
---

Run `terraform plan` against a system nobody has touched in a month. I'll wait.

You got changes back, didn't you? A tag that drifted. A security-group rule someone added by hand during an incident. A resource that exists in the cloud but not in state, or in state but not in the cloud. The plan is never empty. It is never *just* the change you intended.

We call this Infrastructure as Code and treat it as a solved problem. It isn't. Most IaC implementations — Terraform, CDK, CloudFormation — are broken, and they're broken for two separate reasons that get collapsed into one. The first is structural, and almost nobody fixes it. The second is human, and almost nobody admits it.

## The structural half: there is no loop

These tools are one-shot. You declare a desired state, you run apply, and the tool makes the world match — *once*. Then it walks away. Nothing is watching after that.

And between applies, the world drifts. Someone makes a manual change during an incident. A console edit here, an out-of-band script there, another team touching shared infrastructure, a cloud provider quietly mutating a default. The declared state and the actual state diverge, continuously, and nothing converges them back. The drift accumulates until the next plan, which is why the next plan is never clean.

This is the difference between describing a state and maintaining one. Terraform, CDK, and CloudFormation describe. They are very good at taking a blank account to a fully-built one. They have nothing to say about minute 2 through the heat death of the universe.

I've written before about "can" versus "does." Here it is again, wearing a different hat. At apply time the infrastructure *can* be correct — you just watched it converge. Whether it *stays* correct is a question these tools do not ask, because they are not running. Correctness, for a one-shot tool, is a deploy-time property. It expires the moment apply finishes, and from then on it decays.

Now look at the other model. A Kubernetes controller does not apply once and leave. It runs forever, comparing declared state to observed state and reconciling the difference on a loop. Drift gets corrected because something is *always watching*. Flux does this for what runs in your cluster. Crossplane does it for the cloud resources around the cluster. Same reconciliation model, pointed at different layers. That is not a snapshot. That is a control system.

So the structural flaw is real: the popular IaC tools give you a snapshot when what you need is a control system. Reconciliation closes that gap. If the post stopped here, it would be just another "adopt GitOps" take, and it would be half wrong.

## But reconciliation is only half the reason

Here is where the GitOps evangelists stop, and they shouldn't, because a reconciliation loop bolted onto a broken implementation does not give you correct infrastructure. It gives you *incorrect infrastructure, faster, forever, with confidence*.

The second reason most IaC is broken has nothing to do with loops. It's that the implementations themselves are a disaster. I've inherited a lot of these, and the pattern rhymes every time:

- Long-running branches that forked months ago, each one its own private version of reality.
- State files nobody understands, that don't match the cloud, that two different engineers have hand-edited under pressure.
- Copy-pasted modules three generations deep, where no one alive knows which variables actually do anything.
- An `apply` run from somebody's laptop at 2am during an incident and never committed — so the repo and the world disagree, and the repo loses.
- Plans that surface surprising, unrelated changes on *every single run* — so the team has learned to skim past the diff, which means the one genuinely dangerous change is hidden in the noise of ten harmless ones.

None of that is fixed by reconciliation. Point a control loop at a non-deterministic, half-understood, drifted specification and it will converge the world to that specification — relentlessly, automatically, faster than any human could. Garbage in, garbage reconciled. You haven't fixed the mess; you've *automated* it.

The thing that makes Infrastructure as Code trustworthy was never the tool. It's discipline. Determinism: the same inputs produce the same plan, every time, so a clean diff means something. A single source of truth: git, not a laptop, not the console, not tribal memory. Trunk-based change: small, reviewed commits, no branch permitted to become its own universe. Most shops have bought the tool and skipped the discipline, and then they blame the tool.

## Why the two halves get confused

People who have been burned by drift discover reconciliation, feel the relief, and declare the problem solved. They're half right.

People who have been burned by a broken Terraform codebase conclude "Terraform is bad," switch to CDK or Pulumi or CloudFormation, and faithfully rebuild the exact same mess in new syntax — because they changed the tool and kept the habits. They're also half right.

The drift crowd is correct that you need a loop. The tool-switchers are correct that the implementations are broken. Neither group, alone, ends up with infrastructure you can trust, because the two problems are independent and you have to solve both.

## What actually works

The combination, and only the combination.

A reconciliation loop that continuously converges actual state to declared state — Flux for the workloads, Crossplane for the cloud resources, the same Kubernetes control-loop model underneath both, so "I described it once" becomes "it stays that way without me."

Git as the *only* source of truth. No laptop applies. If it isn't in the repo, it doesn't exist; if it is in the repo, the loop makes it real and keeps it real.

Determinism. The same commit produces the same result, so there are no surprising changes on a diff — because there is nothing out of band left to surprise you with. A clean plan is information again instead of noise.

Trunk-based change, small and reviewed. No branch gets to spend three months becoming a parallel reality you'll have to reconcile by hand later.

And the honest caveat, because there's always one: the loop raises the stakes on the spec. When a control system continuously enforces your declared state, it enforces your *mistakes* just as continuously — and faster than you can undo them by hand. Reconciliation is a force multiplier, and a force multiplier multiplies errors as eagerly as it multiplies correctness. That is precisely why the discipline half is not optional. A reconciliation loop without determinism behind it is a loaded gun with the safety filed off.

## Determinism is a tooling choice, not just a discipline

Discipline gets you most of the way, but your tools either preserve determinism or they leak it — and inside the Kubernetes world, the popular defaults leak.

Determinism, concretely, is the absence of indirection and the absence of surprise: what you read in the source is exactly what happens, with no hidden layer in between that is free to decide otherwise. Every layer of indirection you add — a templating language, a render-time function, a UI that can act on its own — is another place a surprise can hide. The whole game is removing those places.

Start with the renderer. Kustomize is a pure overlay system: it takes base manifests and applies declarative patches and transformations, with no templating language, no logic, no functions. `kustomize build` is referentially transparent — the same inputs produce the same YAML, every time, on any machine, forever. There is nowhere for non-determinism to get in.

Helm is a templating engine masquerading as a package manager. It renders Go templates over your YAML, and those templates can do whatever templates can do: conditionals, loops, `randAlphaNum`, `uuidv4`, `now`, and `lookup` calls against the live cluster. A chart can render differently depending on the wall clock, a freshly generated secret, or the current state of the cluster it happens to be pointed at. On top of that, Helm stores release state *in the cluster*, so `helm upgrade` behavior depends on history that doesn't live in git. "The same chart" is not a promise of the same result — which is the exact property determinism requires.

The reconciler splits the same way. Flux has no UI and no sync button. The only way to change the cluster is to change git; every actuator is a Kubernetes custom resource that itself comes from git. The cluster is a pure function of the repository, and there is no console escape hatch through which a human can quietly diverge it — the same way out-of-band console access wrecks an audit trail, it wrecks determinism.

Argo CD is excellent software, and on ergonomics it wins — the UI is genuinely useful. But that UI is also an imperative escape hatch: you can click sync, override a resource, or roll back by hand, and now the cluster reflects an action that was never in git. Add the app-of-apps pattern and you inherit ordering fragility on top of it. None of that is fatal, and disciplined teams do run Argo deterministically — but you're holding the tool against its grain, where Flux makes the deterministic path the *only* path.

None of this is a knock on Helm's ecosystem or Argo's UX; both earned their popularity honestly. The claim is narrower than that: on the single axis of *determinism*, Kustomize and Flux are deterministic by construction, while Helm and Argo make you opt into determinism and trust that nobody opts back out. If determinism is the half of the problem nobody respects, pick the tools that don't make you fight for it.

## The actual job

Most Infrastructure as Code is broken. Half the reason is that the popular tools describe state instead of maintaining it — there's no loop, so it drifts, guaranteed, given time. The other half is that we aim those tools at undisciplined, non-deterministic, laptop-applied messes and act betrayed when the output is a mess.

Add the loop. You need it. But understand exactly what you've built: a machine that makes your declarations true, relentlessly, whether or not they deserve to be. So make very sure they deserve it.

Infrastructure as Code was always the easy part. Infrastructure as a *control system* — declared once, converged forever, and disciplined enough that you can trust the convergence — is the actual job.
