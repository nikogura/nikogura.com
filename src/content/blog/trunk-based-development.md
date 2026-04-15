---
title: 'Trunk-Based Development'
excerpt: Long-running branches are an anti-pattern. The longer a branch is open, the more expensive the integration becomes, the less informative the diff, and the further the branch drifts from whatever is actually shipping. Trunk-based development is the alternative the continuous delivery community converged on two decades ago, and the evidence for it is overwhelming.
publishDate: 'Apr 15 2026'
tags:
  - Continuous Delivery
  - Git
isFeatured: true
---

## The Claim

Every change goes directly to `main`, in small increments, reviewed and merged as quickly as it is written. Branches exist — for code review, for CI to attach to, for preserving individual authorship — but they are measured in hours, not days. No `develop` branch. No `release/*` branches held open for weeks. No feature branches that survive a sprint. The trunk is where the work is.

This is trunk-based development. It is older than git, older than GitHub, older than most of the teams I talk to who are skeptical of it. It is the practice the continuous delivery community converged on, and the evidence for it is overwhelming. It is also, in my experience, the single biggest workflow change most teams can make to improve their shipping velocity and their quality simultaneously.

## Why Long Branches Are an Anti-Pattern

Every week a branch exists, three things get worse:

**Integration cost compounds.** Changes land on `main` that are not in the branch. Changes land on the branch that are not in `main`. The longer both sides accumulate independent changes, the more expensive the eventual merge becomes — not linearly, but roughly exponentially. A branch open for a week is five times harder to merge than a branch open for a day. A branch open for a month is an archaeology project.

**The diff stops being informative.** A PR from a week-old branch does not show the changes the author made. It shows the changes the author made *plus* every change that happened on main while the branch was open. Reviewers cannot focus on what actually changed. They either approve without reading — which defeats the point of review — or refuse to merge until the branch is rebased, which restarts the clock and often introduces new conflicts. Either outcome is worse than if the work had landed in small, continuous increments.

**Design incompatibilities surface late.** Two branches can be individually correct and mutually incompatible. The incompatibility only becomes visible at merge. If both branches are a day old, that merge is a fifteen-minute problem. If both branches are a month old, it is a fundamental redesign — after both teams have built on top of their respective assumptions. The longer integration is deferred, the more expensive the eventual reconciliation.

Those three costs are not hypothetical. They are the lived experience of every team that tries to run Git Flow, GitFlow-lite, "develop branch, release branches," or any other long-lived-branch model. The costs are real. The question is why teams keep paying them.

## The Usual Objections

**"We need a release branch so we can stabilize."** You do not. A stable release comes from a commit on `main` that passed your CI gates. Tag it. Cut a release artifact from it. Keep `main` moving. If you discover a bug in the released version, fix it on `main` and cherry-pick — or, better, reproduce it on `main` first so the fix ships forward. A separate release branch held open for weeks is a parallel universe that nobody is testing.

**"We need a develop branch so main stays clean."** `main` is only as clean as your CI makes it. A develop branch doesn't make anything cleaner; it just moves the filth one step upstream. Work harder on the CI gates between branch and `main`. Write more tests. Automate more checks. Shorten the feedback loop. The branch isn't the problem; the absence of confidence in the merge is.

**"My feature is too big to merge in small increments."** Your feature is too big. Break it down. Or use a feature flag: ship the code on `main` behind a toggle that defaults to off, merge continuously, flip the flag when the feature is ready. This is what [Martin Fowler's *Feature Toggles* article](https://martinfowler.com/articles/feature-toggles.html) documents in depth. The pattern is well-established, has been in production at every large engineering org you admire, and is strictly better than the alternative of holding a branch open for weeks.

**"Our review process requires complete features."** Then your review process is the bottleneck, not the branching model. Review partial implementations. Review the scaffolding before the logic. Review the interface before the implementation. Reviewers who understand the code will pick up a half-finished feature and engage with it productively; reviewers who don't will approve a finished feature with a thumbs-up emoji and change nothing. Review quality is not a function of branch age.

**"We tried trunk-based development and it broke main."** CI isn't catching what it needs to catch. That is a solvable problem, and it is the only problem trunk-based development requires you to solve. Every other workflow carries the same problem, just hidden further from where the work happens.

## The Supporting Techniques

Trunk-based development is not just a branching policy. It is a cluster of practices that together make continuous merge cheap and safe:

**Feature toggles.** Ship code before it is ready to be used. A config flag, an environment variable, a runtime switch — something that lets the work land on `main` without exposing it to production traffic. Toggles are retired as features mature; they are not a permanent part of the system.

**Branch by abstraction.** When a refactor is too large to ship in one commit, introduce an abstraction, migrate callers to the abstraction one at a time on `main`, then remove the old implementation. No long-running branch required. The refactor happens in public, incrementally, with every intermediate state tested.

**Expand and contract** (sometimes called parallel change). For database or API migrations: add the new thing alongside the old thing, migrate readers, migrate writers, remove the old thing. Each step is a merge to `main`. Nothing blocks; nothing coordinates across teams; nothing requires a cutover weekend.

**Small, focused commits.** A change that takes hours instead of days fits in a reviewer's head. Reviewers catch more, discuss less, approve faster. The cycle time between "I have an idea" and "it is running in production" collapses.

**Strong CI gates.** If `main` must always be shippable, CI must prove it. Tests run on every merge. Integration tests catch cross-team breakage. Linters, type checkers, security scanners run automatically. Anything that was previously "we'll catch it in review" becomes "we'll catch it in CI." The developer who breaks `main` finds out in minutes, not days.

These practices reinforce each other. Feature toggles make small commits possible when the feature is big. Branch-by-abstraction makes small commits possible when the refactor is sweeping. Strong CI makes small commits safe. And small commits make everything else easier.

## The Evidence

**Jez Humble and Dave Farley, [*Continuous Delivery*](https://continuousdelivery.com/) (2010).** The book's central argument: software should always be in a releasable state, and the way to get there is by integrating continuously rather than accumulating changes on branches. Every chapter comes back to the same observation — the cost of deferred integration dominates every other inefficiency in the software delivery pipeline. Short branches keep integration cheap. Long branches guarantee it gets expensive.

**Martin Fowler on feature branching and feature toggles.** Fowler has been making the case against long-lived feature branches for over a decade. See [FeatureBranch](https://martinfowler.com/bliki/FeatureBranch.html) — the essay that named the pattern and the reasons it fails — and [Feature Toggles (aka Feature Flags)](https://martinfowler.com/articles/feature-toggles.html), which catalogs the alternative techniques that let teams keep work on trunk without exposing unfinished features.

**Paul Hammant's [trunkbaseddevelopment.com](https://trunkbaseddevelopment.com/).** The canonical reference. Defines trunk-based development, explains the variants (TBD with short-lived branches vs. commit-to-trunk), catalogs the supporting practices, and documents the organizations that use it — Google, Meta, Microsoft, and most large-scale engineering orgs you've heard of. Read it end-to-end. It is not long.

**[Thoughtworks Technology Radar](https://www.thoughtworks.com/radar).** Trunk-based development has been in the "Adopt" ring for years. Long-lived feature branches repeatedly appear in "Hold." The Radar's editors are not given to contrarian takes; when they put a practice in "Adopt," they mean their recommendation is to use it without further evaluation. When they put the opposite in "Hold," they mean their recommendation is to stop.

**[DORA research](https://dora.dev/).** The DORA team (now at Google, authors of *Accelerate* and the annual State of DevOps reports) has repeatedly found that trunk-based development correlates strongly with their four key performance metrics: deployment frequency, lead time for changes, change failure rate, and time to restore service. Teams that merge to trunk at least daily outperform teams that don't across all four metrics. See DORA's [capability page on trunk-based development](https://dora.dev/capabilities/trunk-based-development/) for the summary; see the annual reports for the underlying data. The correlation is not mild. It is one of the strongest signals in their dataset.

The common thread: integration is not something to defer. The longer you wait, the worse it gets.

## The Shift

The hard part of adopting trunk-based development is not the branching policy. The branching policy is the easy part. The hard part is the practices that make the policy safe — feature toggles instead of feature branches, branch-by-abstraction instead of long-running refactors, strong CI instead of "we'll catch it in review," small commits instead of "let me finish this first."

Most teams that resist trunk-based development are not really resisting the branching model. They are resisting the adjacent practices, because the adjacent practices are genuinely more work than not having them. Feature toggles require discipline to retire. Branch-by-abstraction requires designing the abstraction up front. Strong CI requires investing in tests.

But those practices are good regardless of the branching model. Trunk-based development forces a team to adopt them, because without them the model is miserable. A team that refuses to adopt those practices is a team that was going to ship slowly and break things regardless. They will blame the branching model, but the branching model is not the problem.

## The Discipline

Simple, even if practice is required to get it right:

- Keep branches short — hours, not days
- Merge continuously, not in batches
- Use feature flags, branch-by-abstraction, or expand-and-contract instead of long-running branches
- Invest in CI until `main` is always shippable
- Break big work down until it fits in small commits

The payoff is not just faster delivery. It is less time spent on merge conflicts, fewer integration surprises, a more informative git history, easier rollbacks, and a team that ships with confidence instead of crossing its fingers before every release. The practices reinforce each other, and the reinforcement compounds.

Every credible study of engineering effectiveness points in the same direction. The teams that ship the fastest and break the least are the teams that merge to trunk continuously. The workflow is not a matter of taste. It is a matter of evidence.
