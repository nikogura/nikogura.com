---
title: "Infrastructure Is Not an Application"
excerpt: "We took the software-engineering playbook — DRY, long-lived feature branches, package managers, dynamic in-cluster orchestration — and pointed it wholesale at running infrastructure. It keeps breaking, and not because the tools are bad. An application is a stateless artifact you stamp out in identical, disposable copies; infrastructure is stateful, singular, and alive in production. The patterns that make app development fast make operations fragile — and knowing which is which is most of the job."
publishDate: 'Nov 05 2026'
tags:
  - Operations
  - GitOps
  - Kubernetes
  - Culture
isFeatured: false
---

I keep noticing the same thing from different angles: a practice that is unambiguously *good* in application development turns fragile, sometimes dangerous, the moment you apply it to running infrastructure. Same engineers, same tools — git, CI, package managers, pull requests, controllers — and somehow the move that made the app codebase cleaner makes the platform worse.

For a long time I filed these as separate complaints. [Long-running branches are a bad idea](/blog/trunk-based-development). [Most infrastructure-as-code is broken](/blog/most-infrastructure-as-code-is-broken). [Argo's dynamic model drifts](/blog/flux-vs-argo). [DRY is the wrong instinct in a control repository](/blog/ddcri). They aren't separate. They're the same mistake wearing different hats: **we imported the software-engineering playbook into operations wholesale, without checking whether the thing it was written for is the thing we're now pointing it at.**

It isn't. And the gap between the two is most of why ops is hard.

## The Asymmetry Nobody Names

An application, by the time it's running, is a *stateless, transient artifact*. You compile it once and stamp out as many identical copies as you need. Any single replica is disposable — kill it, a scheduler starts another, nobody notices. It holds no durable truth; its state lives somewhere else, in a database, a queue, a cache. You version it, ship it, and when the next version is ready you replace it wholesale and throw the old one away. The entire app-dev playbook is optimized around exactly these properties: artifacts are many, identical, disposable, and stateless.

Infrastructure is the opposite on every axis. It is *stateful, persistent, and singular*. There is exactly one production. It holds the data — the data *is* the point. You cannot stamp out an identical copy of it, you cannot kill it and let a scheduler replace it, and you cannot "roll it back" the way you roll back a binary, because rolling back the schema migration does not un-write the rows. It is less like a build artifact and more like a patient under care: continuous, irreplaceable, and unforgiving of the assumption that you can simply deploy another one.

And yes — this is the old *pets versus cattle* distinction, and no, I'm not relitigating it. Cattle is the right ideal for stateless replicas: name none of them, mourn none of them, replace any of them at will. But the framing only holds for the part of the system whose state you can genuinely reproduce. Unless you can truly duplicate *all* of the state, your production environment is a pet — and calling it cattle does not change that. It just means you'll be surprised the day you reach for a replacement that was never actually interchangeable.

[I've made a version of this point about the engineer's own self-concept](/blog/running-a-system-not-writing-code) — that "I am running a system" is a different job than "I am writing code." This is the same fault line one level down, in the *tools*. A tool built for many-identical-disposable will mislead you the instant you point it at one-persistent-irreplaceable. Here are the three places it bites hardest.

## DRY Is a Codebase Virtue and an Ops Vice

In application code, indirection is leverage. You factor the shared thing into one place, and a single change propagates everywhere it's used. DRY — don't repeat yourself — is close to a moral law, and for good reason: duplicated logic drifts out of sync and rots.

Point that instinct at infrastructure and it inverts. The value of an infrastructure declaration is not that it's elegant; it's that at 3 a.m., staring at a production incident, you can know *exactly what bytes are on the iron* without running a compiler in your head. Three layers of Helm values, a shared base, and a stack of overlays is a beautiful, DRY abstraction right up until the moment you need to answer "what is actually deployed here?" — and now the answer requires you to mentally render a template whose output you can't see.

So [in a DDCRI control repository I duplicate on purpose](/blog/ddcri). `production` and `staging` are separate, flat, repeated trees, and the repetition is the feature: `diff -ruN clusters/production clusters/staging` gives me the complete, literal delta between two environments with nothing to render. This is not "I forgot about DRY." It's [the old Go proverb](/blog/golang-design-tips) — *a little copying is better than a little dependency* — taken seriously in the one domain where troubleshooting speed beats authoring convenience. Repetition you can diff beats cleverness you have to reconstruct. In a codebase the trade usually runs the other way. Both are correct, for their medium.

## A Feature Branch Assumes a World That Holds Still

The long-lived feature branch works in application development because the thing you branched from is *inert*. `main` is a commit; it does not change unless someone changes it. You can take three weeks in a branch, and the base you merge back into is the base you left — any drift is other people's commits, visible and reviewable in the merge.

Infrastructure has no inert base. The thing your branch describes — the live cluster, the cloud account — is *moving the entire time your branch is open*, and not only because of commits. It drifts because a cloud provider changed a default, because something autoscaled, because an operator did a thing out of band. The longer the branch lives, the further the world it assumed has slid out from under it, and the merge becomes a roll of the dice against a target you stopped watching. That's why [trunk-based development isn't a style preference for infrastructure](/blog/trunk-based-development); it's a correctness requirement. Small changes, merged continuously, keep the delta between git and reality small enough to reason about — which is the entire bet [the control repository](/blog/control-repositories) is making.

## App Devs Want Runtime Flexibility; Ops Wants the Diff at Review Time

This is the big one, and it's where the fashionable patterns live.

Application platforms are built to be *dynamic*: event-driven, reactive, a controller evaluating a graph of objects at runtime with a dashboard to watch it move. That flexibility is genuinely good when you're shipping and scaling stateless replicas. So when the same people build the *delivery system* for infrastructure, they reach for the same shape — a central controller with a UI that renders and reconciles a dynamic application graph (Argo's app-of-apps), or a package manager that templates manifests against live cluster state at install time (Helm, and the umbrella chart).

And it inverts again, for one reason: **ops needs to discover the diff at review time, not at run time.** When an in-cluster engine renders your manifests on the fly — Helm's `lookup` reading the live cluster, a chart version bumping one line in the PR while changing a hundred lines of RBAC you can't see — [you've moved the moment of truth from the pull request to the deploy](/blog/ddcri). You find out what changed *after* it is running. For a disposable app replica, that is a shrug. For the singular, stateful thing, it is how you restart a business-critical service you never meant to touch.

The umbrella chart is the cleanest illustration of the category error. It bundles a dozen unrelated components — an ingress controller, a cache, a database operator, your own API — into one atomic release so you can deploy "the environment" with a single command. That is packaging logic borrowed straight from app dev. The cost is that you've welded the failure domains of independent things together: change one subchart's value and you bump and re-release the whole umbrella, re-expose the entire surface area to the renderer, and tie a typo in one component to the rollback of everything. *Change one thing, you change them all.* [Argo's app-of-apps has the same shape](/blog/flux-vs-argo) with the orchestration moved to the server instead of the client — and the same central thing to stall, deadlock, or serve you a stale view of reality.

The DDCRI answer isn't a better orchestrator. It's to [remove the dynamic layer entirely](/blog/ddcri): render statically, commit the flat result, review the real diff in the PR, and let an in-cluster reconciler drive the cluster to that reviewed state and hold it there — independently per cluster, degrading to the last-known-good revision if git disappears, with no central graph to evaluate and nothing to go stale. The cluster is a dumb, deterministic executor, not a conversational participant. That is not a lack of sophistication. It's sophistication spent on the right property.

## Packaging Is Not Architecture

Underneath all three is one confusion: mistaking *packaging* for *architecture*. "I want to define an environment, so I'll package it as one thing" feels right because in app dev the artifact and the unit of deployment are the same object. In operations they are not. An environment is not a package; it's a set of independent, stateful components that each want their own lifecycle, their own failure domain, and their own blast radius. Wrapping them in an umbrella or an app-of-apps does not make them one system — it rebuilds a brittle monolith and calls it cloud-native.

None of this means the app-dev playbook is wrong. It is *right, for applications.* DRY, feature branches, dynamic orchestration, unified packaging — all of them earn their keep when the thing you're managing is many, identical, disposable, and stateless. The error is purely one of transfer: assuming that because the tools are the same, the discipline must be too.

## The Test

So before importing a practice from the application world into the platform, I run it through one question: **does the premise still hold here?** Is this thing stateless, reproducible, and many — or stateful, singular, and irreplaceable? If it's the former, bring the whole app-dev playbook; it will serve you. If it's the latter, expect the pattern to *invert*, and lean the other way — toward determinism over flexibility, toward copying you can diff over abstraction you have to render, toward discovering the change at review time instead of at run time.

Same tools. Different medium. The job is knowing which one you're holding.
