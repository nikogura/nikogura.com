---
title: "'Production Ready' Is a Hand-Off, Not a Launch"
excerpt: "The moment you hand a service to the people who run production, 'it works' stops meaning 'it works on my machine' and starts meaning 'someone who has never seen this code can keep it alive at 3 a.m.' Production readiness is that hand-off contract — and almost every item on the checklist traces back to one question: what does the on-call engineer need to survive the night?"
publishDate: 'Aug 24 2026'
tags:
  - SRE
  - Operability
  - Observability
  - Engineering
isFeatured: false
---

Ask an engineer if their service is production ready and they'll usually tell you yes. It builds, it passes tests, it does the thing in the demo. Ship it.

Then it goes to the people who actually run production — the ones who carry the pager for it — and a different set of questions start being asked. Where do its logs go? What does healthy look like? What happens when its database is slow? How do I roll it back? Who do I call, and what do I do before I call them? The answers, more often than not, live in exactly one place: the head of the person who wrote it. And that person is asleep.

That gap is the whole subject of this post. **Production ready is not a property of the code. It's a property of the hand-off.** It's the moment "it works" stops meaning "it works for me, right now, with everything I know in my head" and starts meaning "it keeps working for someone who has never seen it, at the worst possible hour, with nothing but what's written down." Almost everything on a real production-readiness checklist is downstream of that one shift in meaning.

## The Author Is the Worst Judge of Readiness

I've written before about the gap between [can and does](/blog/can-vs-does) — "it can work" is a claim about a single moment under controlled conditions; "it does work" is a property sustained over time, in reality, without you standing over it. Readiness lives on the *does* side, and the author is structurally the wrong person to assess it.

Not because they're careless — because they're *loaded*. They carry the context the system needs to be operated, and they carry it invisibly. They know the one env var that matters, the dependency that's flaky on Tuesdays, the log line that actually means something, the incantation to bring it back. None of that is in the artifact. It's in them. When they say "it's ready," what they mean is "it's ready *for me*," and they can't feel the difference, because the missing context is the water they swim in.

The only honest test of readiness is to remove that person and see whether the system is still operable. That's what a hand-off is. And the questions it has to answer aren't abstract. They're the three things on-call needs on a bad night.

## What Is It Doing?

You cannot operate what you cannot see. You cannot prove something improved without a baseline, cannot detect drift without continuous comparison, cannot diagnose an incident without correlated signals. Observability isn't one item on the list — it's the item that makes every other item checkable.

There are [three distinct signals in observability](/blog/metrics-logs-traces-events), and they answer three different questions. **Metrics** tell you *that* something is wrong and roughly where — request rates, error counts, latencies, queue depths, sampled over time and cheap to keep. **Logs** tell you *what* happened, in detail, in one component. **[Traces](/blog/distributed-tracing)** tell you *how* a single request moved across services and where the time went. During an incident you need all three, because each is blind to what the others see. A system that emits one of the three is not observable; it's partially lit.

The mechanics matter more than teams expect. Some metrics are *scraped* — a collector reaches out and pulls them from an endpoint the service exposes, the way Prometheus does; others are *pushed* — the service sends them out to a collector, as is common with OpenTelemetry. You need to know which model you're on, why you'd choose one over the other, and — just as important — what it means when they go dark. A request-serving workload should emit the four numbers that actually describe its health — traffic, errors, latency as a distribution, and a saturation signal like in-flight requests or queue depth — because those are what you page on and what you put on a wall. And the dashboard has to exist *before* the thing ships, not get built during the outage when you discovered it was needed. A dashboard built before the incident is a tool. One built during it is a distraction. ([There's more than one way to get this right](/blog/more-than-one-way-to-get-observability-right) — but there's no way to get it right without doing it.)

Exposing metrics is necessary and not sufficient. A number nobody alerts on isn't monitoring — it's decoration. The metrics need to be **monitored**.  In other words, a machine has to observe them continuously and record the observations over time. The second question people ask after "What's the current state?" is "How long has it been like this?"  If you're not continuously observing it, you can't answer. 

The rules that fire when a service is breaching its objective are what turn a dashboard into a pager, and every one of them should have a threshold the owning team can *defend*: tied to a stated objective or a measured baseline, not a number copied off another service because it felt about right. A threshold nobody can justify is one nobody trusts, and an untrusted alert gets muted — which is strictly worse than no alert at all.  The people carrying the pager also need to know that you will not wake them up without need.

## Why Did It Break?

Once you can see *that* it broke, someone who isn't the author has to figure out *why*. That's a documentation problem as much as an instrumentation one.

Logs should be structured, or at least consistently parseable, and carry enough context — a service name, an environment, a correlation id that ties a log line back to the trace it belongs to — that you can follow one request through the mess. They should never carry secrets or personal data, and they should survive contact with hostile input without letting someone inject fake lines. The log level should be a config value, not a rebuild, so you can turn the lights up during an incident and back down after.

And there has to be a runbook. Not a novel — a short, honest document that says what the thing does, how to tell if it's healthy, and the first moves for its common failure modes. The [on-call engineer is usually not the author](/blog/incident-management); the runbook is what lets them act anyway. The first version is allowed to be thin. What's not allowed is for it to stay thin: every incident you handle is supposed to fold its diagnosis and its fix back into the document, so the system gets more operable each time it hurts you, instead of teaching the same lesson to a different person at 3 a.m. next quarter.

## How Do I Get It Back?

Here's the one that separates teams. A good platform is supposed to heal itself. Manual recovery is not a heroic act to be celebrated — it's a [process failure that happened to have a hero standing nearby](/blog/stop-holding-out-for-a-hero), and heroes are [load-bearing humans](/blog/load-bearing-humans) you can't schedule, can't clone, and can't count on.

An outage is rarely caused by the failure itself. Failures are certain. Given any interesting time and scale, they **will happen**.  The outage is the minutes between the failure and the recovery — the detection lag and the by-hand rollback. So you attack that gap directly. Health checks tuned to catch a crashing, flailing service in seconds, not minutes. A rollback path that's fast and defined *before* you need it — under [GitOps](/blog/gitops), for instance, that's reverting a commit and letting the system reconcile itself back, which is quick, auditable, and doesn't involve anyone doing surgery in a live console. Ideally the rollback is automatic: the deploy is health-gated, and when the new version looks sick it backs itself out to the last known-good one with no human in the loop at all.

Every call the service makes to something else — a database, a cache, a downstream API — needs a timeout and bounded retries with exponential backoff, applied only to operations that are safe to repeat. And critically, the retry state has to be *visible*. A retry storm you can't see is a degrading dependency wearing a disguise: the whole point of retrying is to ride out a blip, and you have to be able to tell when it stops being a blip and starts being an outage you're papering over. [Betting that a dependency won't fail is gambling on failure](/blog/gambling-on-failure); the house always collects.

None of this survives a single point of failure. Two instances, on separate machines, so losing one is a non-event instead of a page. That's not gold-plating — it's the difference between a routine machine replacement and an incident.

## Can It Be Deployed Without You?

A service you can't deploy without the person who wrote it isn't handed off — it's on loan. So the deploy has to be boring and mechanical: no laptop-built artifacts, no hand-run deploy commands, no clicking through a console, no step that lives in someone's shell history.

The artifact should be immutable and versioned — one version maps to exactly one set of bits, forever, addressable by digest so a rollback gets you *precisely* what you tested rather than something close. The artifact must be independently buildable and tested without risk of deployment.  Test the ever-lovin heck out of it, and store the test reports.  Almost any amount of work spent in testing and verification is better than disappointing your customers.  You know, customers?  Nice people who give you money?

The desired state should be declared in git and [continuously reconciled](/blog/control-repositories) by an agent that corrects drift and reverts out-of-band changes. Deployment stops being a one-time push you hope took and becomes a converging loop: the declared state *is* the running state, drift gets corrected instead of discovered during an incident, and "what's deployed where" is a fact you read instead of a forensic exercise. [Most infrastructure-as-code is broken](/blog/most-infrastructure-as-code-is-broken) precisely because it describes a state once and then walks away; the reconciliation loop is what keeps the description honest.

This is the same discipline as [trunk-based development](/blog/trunk-based-development) and everything else I harp on: push the complexity to build time, where it's cheap and reviewable, so that runtime — the 3 a.m., under-pressure part — is as dumb and deterministic as you can make it.

## Will It Take Its Neighbors Down?

A workload doesn't run alone. It shares finite hardware — CPU, memory, I/O — with other workloads, and readiness includes being a good neighbor.

That mostly comes down to declaring what it needs and capping what it can take — the CPU and memory it reserves, and the ceiling it may never cross — sized from something you actually measured, not guessed. Those numbers aren't bookkeeping; they're how the platform protects every other workload from this one, and they decide who gets starved when the hardware is contended. A service with no declared bounds is a service that can take its neighbors down with it under load, and "it was fine in the demo" is not a capacity statement. 

If you didn't load test it — drive it past its expected peak, find the point where it saturates and the point where it fails — then the resource numbers you declared are a wish, and your saturation alert is a number someone invented.  You say you don't know what resources it needs?  You don't know how to simulate traffic?  Sounds like you have some more work to do.  

I have been told that Apple's Satellite Connectivity group models **virtual planets** and satellites in orbit around them.  Granted, that's Apple.  They do have more than a few resources at their command than the average company.  (**I** wanna model virtual planets!  I wouldn't have a clue how to even get started, but how cool is that?)

The same logic covers security, because [security and operability are one practice](/blog/security-is-infrastructure), not two. Least privilege — a narrowly scoped identity, no wildcard permissions — is just blast-radius control: when something is compromised, and eventually something is, least privilege decides whether it's an incident or a breach. Secrets come from a secret manager, never baked into an image or committed to git or printed in a log. An insecure service is an incident with a delay fuse on it, and trust me, that fuse is lit.

## The Data Is the One Thing Git Can't Rebuild

Everything else in this post can be reconstructed. Lose a process, a machine, the whole environment, and it rebuilds from what's declared in git and the artifacts redeploy. State is the exception. Lost data is just gone.

Which is why the bar for anything stateful is higher. Backups on a schedule, to storage independent of the workload — and, non-negotiably, a restore you have actually *performed*. A backup you've never restored is a hope, not a guarantee; the restore is the feature and the backup is only its input. A documented tolerance for how much data you can lose and how long recovery takes, with the backup cadence actually meeting it. And this holds whether the database is managed or self-run — "the provider backs it up" is not the same sentence as "we have restored it."

Schema is data's twin, and it gets the same treatment: every change is a [reviewed, versioned migration](/blog/database-design) in the repo, never a hand-typed edit against a live database. Manual DDL against production is the exact opposite of every other principle here — invisible, unreviewed, unrepeatable, untested — and it actively defeats the testing you did everywhere else by turning production into a snowflake no other environment matches. Destructive changes go through expand-migrate-contract so an app rollback never has to claw a schema back through a lossy down-migration. "We had to fix some rows" is a migration. It was always a migration.

## Why Production Readiness is a Gate

You could read all of this as a wish list — nice things to add once the real work is done. It isn't. It's a gate, and the reason it's a gate is that the pager is real and someone has to carry it.

When you skip the gate, you don't get faster delivery. You get the operational version of a thing I've said about broken hiring pipelines: you don't get *correct* operations, you get *incorrect operations, faster, forever, with confidence.* The service ships, it runs until it doesn't, and then the cost of everything you skipped comes due all at once — in production, during an incident, at the least convenient hour, paid by whoever's on call instead of by the author who had the context. The cheapest place to catch any of this is a pull request, where it's a comment. The most expensive is production, where it's an outage. The gate just moves the discovery to the cheap side.

And here's the part worth internalizing: none of these requirements are arbitrary. Every one traces back to a question on-call has to answer while the system is on fire — *what is it doing, how long has it been down, why did it break, how do I get it back* — plus the three that make the hand-off real: *can I deploy it without you, will it take its neighbors down, did the data survive.* That's the whole standard. Not bureaucracy. Just the minimum that lets a system be run by someone who didn't build it.

Production ready was never the last ten percent you rush at the end. It's the definition of done — because "done" means you can walk away, and it keeps working anyway.
