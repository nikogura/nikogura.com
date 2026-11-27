---
title: "Argo Is Not GitOps"
excerpt: "The industry calls ArgoCD a GitOps tool. It isn't one — it's an excellent imperative deployment dashboard that can be configured to behave like a reconciler if you know which flags to set and which buttons not to press. GitOps has a definition: a controller continuously reconciling the cluster to git, with git as the only way in. Argo ships a sync button, UI overrides, and runtime templating that renders your real diff inside the cluster after you merge — every one of them an imperative escape hatch. A tool whose easy path is a button is not GitOps. It's ClickOps with good branding."
publishDate: 'Nov 27 2026'
tags:
  - GitOps
  - Kubernetes
  - ArgoCD
  - Culture
isFeatured: false
---

Let me say the quiet part at full volume: **ArgoCD is not a GitOps tool.** It is a very good imperative deployment dashboard that the industry has agreed, by sheer repetition, to call GitOps. It can be *configured* to behave like a reconciler — if you know exactly which flags to set and which buttons you're not allowed to press — but its entire grammar pulls the other way, and a tool you have to fight to make declarative is not a declarative tool.

Here's the whole argument in one line: mashing a button in Argo's UI is imperative. Flux's UI is git.

I write this as someone who will cheerfully concede, up front, that Argo is well-built, popular for real reasons, and genuinely better than Argo's detractors admit at the thing it actually is. [I've written the fair, architectural comparison elsewhere](/blog/flux-vs-argo) — caches, controllers, failure modes, where each tool honestly wins. This is not that post. This is the category argument, and the category matters, because the word is being used to launder imperative habits into a badge of modern practice.

## GitOps Has a Definition, and It Isn't "YAML in Git"

[GitOps is a specific thing](/blog/gitops), not a vibe. Git + Ops - Operations performed through Git.  In Kubernetes, that means a  controller runs *inside* the cluster and continuously reconciles the cluster's actual state against desired state declared in git. Git is the only way in. If someone changes the cluster out of band, the controller puts it back. Three properties fall out of that loop and only that loop: an audit trail that is the git log, reproducibility that is "point a fresh controller at the repo and walk away," and drift correction you never have to remember to run.

The industry stretched the word until it meant "any tool that deploys from a repository." That's not a smaller version of GitOps — it's a different thing with different properties, and most of the properties people think they're buying evaporate the moment the reconciliation loop becomes optional. "We store manifests in git and a tool applies them" describes a CI pipeline. It also describes Argo in its most common configuration. Neither is GitOps just because git is in the sentence.

## The Sync Button Is the Tell

The single most damning fact about Argo as a *GitOps* tool is that it has a sync button.

Think about what that button *is*. It is a control that lets a human, from a web UI, outside of git, decide that *now* is the moment the cluster should change. That is the definition of an imperative action — an operator performing a verb against a system — and it is precisely the thing GitOps exists to abolish. The entire point of a reconciliation loop is that there is nothing to press. The cluster is already, continuously, becoming what git says. A button that triggers a sync is an admission that, by default, the cluster *isn't* doing that on its own.

And a button that exists gets pressed. This is not a hypothetical; it's [designing for the tired engineer at 3 a.m.](/blog/running-a-system-not-writing-code) in reverse. Under pressure, during an incident, with the UI right there, someone will click sync, or override a parameter, or hit refresh and then refresh again — because the tool put the escape hatch on the dashboard and made it the easy path. In a real GitOps system that incident-time instinct has nowhere to go but a commit, which is reviewable, revertible, and visible to everyone. In Argo it has a button.

## "You Can Configure It Into GitOps" Is the Problem, Not the Defense

The standard rebuttal is immediate and correct as far as it goes: set `syncPolicy.automated` with `prune: true` and `selfHeal: true`, lock down manual sync with RBAC, and Argo *does* reconcile continuously and *does* correct drift. The sync button goes decorative. At that point, the defenders say, it's real GitOps.

Sit with the shape of that sentence, though. The tool is GitOps *if* you opt into a non-default policy, *and* remember to prune, *and* enable self-heal, *and* use RBAC to disable the imperative features the product ships enabled and foregrounds in its own UI. That is not a GitOps tool. That is an imperative tool wearing a reconciler as a costume, and the costume comes off the instant anyone forgets one of the flags or decides the button is faster tonight.

A tool's defaults and affordances *are* its philosophy. [The right path has to be the easy path](/blog/running-a-system-not-writing-code), because any step you make optional under pressure will eventually be skipped. Flux's safe mode is the only mode — there is no button to press, so there is no discipline to maintain, because the architecture maintains it for you. Argo's safe mode is a configuration you have to know to reach for, defended against a default posture of *visibility and control* that invites exactly the imperative behavior the loop is supposed to make impossible. "You can turn off the dangerous parts" is not a property of a safe tool. It's a property of a dangerous one with a settings page.

## You Discover the Diff After You Apply It

The deeper sin is where Argo computes your change.

GitOps's quiet superpower is that the diff lives in the pull request. You look at the review, you see exactly which resources move, and you approve or reject with full knowledge *before* anything happens. That property is only real if what's in git is what gets applied. Argo's `ApplicationSet` generates Applications from templates at runtime, inside the cluster, and its repo-server renders your manifests — Helm, Kustomize, plugins — after the merge, not before it. So the PR shows one line changing a chart version or a generator path, and a hundred lines of RBAC, a new privileged container, a changed service account move at apply time, where no reviewer ever saw them.

That is the same [transparency hole as a bare `HelmRelease` version bump](/blog/gitops), promoted to the architecture. The moment of truth has moved from review time to run time, which is the one trade [a deterministic control plane must never make](/blog/ddcri). Declarative isn't "I wrote the desired state in a file." It's "what I reviewed is what runs, deterministically, every time." A system that renders your real change inside the cluster after you've already approved a summary of it is not reconciling a reviewed state. It's reconciling a promise, and you find out what you actually promised when it's already running.

## The Thing You Watch Is a Cache That Lies

And then there's the source of truth. In GitOps, the truth is git, and the cluster's actual state is one `kubectl` away — no layer in between. Argo's primary differentiator, the UI, is [the far end of an eight-stage chain of caches](/blog/flux-vs-argo): git, a revision cache, a manifest cache, the controller's in-memory working set, a cluster-state cache, the API server, the browser's poll. A stale value at any stage propagates downstream, and Argo will show "Synced" when it isn't or "OutOfSync" when it's fine. The documented workaround for half of its operational bugs is to drop to the CLI and hard-refresh.

So the organization that adopted Argo *for* the dashboard ends up making operational decisions — click sync, delete, restart — against a snapshot that is some interval behind reality, which is imperative action layered on top of a lie. The dashboard didn't give them a window into the truth. It gave them a plausible-looking surface to act on, which is worse than no window at all, because it feels authoritative.

## It Was Never About the Tool. It's the Grammar.

Underneath all of this is [the difference in thinking I keep coming back to](/blog/accomplishments-not-actions): verbs versus nouns. Flux's grammar centers the *state* — there's no actor, no button, no dashboard to perform against; you change the noun in git and a controller holds it true, and the only sentence you can speak is a commit. Argo's grammar centers the *operator* — the Application, the dashboard, the sync, the "I pushed it out through the UI." It makes verb-thinking *feel* like GitOps, and that is exactly why it's dangerous. It lets an imperative-to-the-core team believe they've gone declarative because there's a repo in the loop and a green checkmark on a screen, while every reflex they have is still "I perform an action and walk away."

None of this makes Argo bad software. It makes it *mislabeled* software. As a deployment platform with a reconciler available underneath — a UI for non-CLI users, ApplicationSet for fanning out many apps, a commercial ecosystem — it's a legitimate, often reasonable choice. The sin isn't the product. It's the word stapled to it, and the thousand teams who adopted "GitOps" and got a dashboard with a button, and never learned the difference because the label told them there wasn't one.

## Call It What It Is

Argo is a deployment platform. Parts of it reconcile. The UI, the sync button, the app-of-apps, the runtime templating, the cache you make decisions against — those are imperative to the core, and no amount of pointing at `selfHeal: true` changes what the tool is shaped to make you *do*.

GitOps means the loop is the only way in and there is no button. If there's a button, it's not GitOps — it's ClickOps with good branding. The word means something. The meaning was the whole point.
