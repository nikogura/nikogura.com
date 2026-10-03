---
title: 'Manual, Automated, Autonomous'
excerpt: "There are three rungs on the operations ladder — do it by hand, run a script that does it, or build a system that keeps it done without you. Most teams climb to the middle rung, call it 'automated,' and stop — never realizing the rung above is where reliability actually lives. The Google SRE book laid this out a decade ago. It's the most-cited, least-applied book in the field."
publishDate: 'Oct 2 2026'
tags:
  - SRE
  - Automation
  - GitOps
  - Reliability
isFeatured: false
---

There are three rungs on the operations ladder, and the whole trajectory of a maturing platform is the climb up them: **manual**, **automated**, **autonomous**. Do it by hand. Run a thing that does it. Or build a system that keeps it done, continuously, without you in the loop at all.

Almost everyone climbs to the middle rung, plants a flag, and declares victory. "It's automated." And it is — the deploy is a pipeline now, the infra is in Terraform, nobody SSHes in to edit a file by hand anymore. That's real progress and worth having. But it is not the top of the ladder, and the gap between the middle rung and the top one is exactly where reliability lives. Most of the industry is parked one rung short of the thing it actually wants, congratulating itself.

## The Three Rungs

**Manual.** A human performs the task, by hand, every time. The knowledge of *how* lives in that human's head — the order of the steps, the one flag that matters, the thing you have to check first. It doesn't repeat identically, it doesn't scale past the person's hours, and the person is a [load-bearing human](/blog/load-bearing-humans): the system runs because they do a thing, and when they're asleep or gone, it doesn't. Every manual step is a bet that the right person is awake.

**Automated.** A human still decides *when*, and triggers something — a script, a pipeline, a `terraform apply` — that executes the steps for them. This is a huge step up: the knowledge moved out of the head and into code that runs the same way every time, fast, reviewable, repeatable. But look closely at what it actually is: a **one-shot**. It fires when invoked, does exactly what it was told, and walks away. It assumes the world it acted on will stay the way it left it. The moment reality drifts — a node dies, someone edits a setting in a console, a dependency changes underneath — the automation doesn't know and doesn't care, because it isn't running. It already ran. Nothing is watching. You find out at the next human-triggered run, or during the incident.

**Autonomous.** The system runs a continuous loop: observe the actual state, compare it to the declared desired state, act to close the gap, and repeat — forever, with no human starting each cycle. In Kubernetes, you kill a pod and the controller rebuilds it. Drift a config and the reconciler reverts it. Lose a node and the workload reschedules. The human is no longer in the path of the work; the human *declares intent* and the loop enforces it. This is the rung where a system heals itself, and it's the rung the other two can't reach no matter how polished they get.

## Automated Is Not Autonomous

This is the confusion that keeps teams on the middle rung, so it's worth saying flatly: **running a script is not the same as running a system.** The difference isn't effort or sophistication — a CI/CD pipeline can be enormously sophisticated and still be the middle rung. The difference is the *loop*.

It's the oldest idea in control theory. **Open-Loop** control acts once and assumes the result holds — like a toaster that runs for exactly the time you dialed, whether or not the toast is actually done. **Closed-Loop** control measures the result and keeps correcting — like a thermostat that reads the room and cycles the heat forever to hold a temperature you *declared*. Automated operations are open-loop: fire and assume. Autonomous operations are closed-loop: observe, correct, repeat. You don't dial in a deploy and hope; you declare a desired state and let a loop defend it against a world that will not hold still - and notify you if it cannot.

This is also why [most infrastructure-as-code is broken](/blog/most-infrastructure-as-code-is-broken): it's open-loop wearing closed-loop's clothes. It *describes* a desired state once, applies it, and then walks away — so the description and reality start diverging the instant the apply finishes, and the drift is invisible until someone runs `plan` again and gets a nasty surprise. A description that isn't continuously enforced isn't the truth about your system; it's a hope about your system, with a timestamp. The reconciliation loop is what turns the hope into a fact. That's the entire difference between the middle rung and the top one, and it's the difference between ["it *can* work"](/blog/can-vs-does) and "it *does* work."

## The Book Everyone Cites and Nobody Reads

None of this is new, and I want to be clear I'm not claiming to have invented a ladder. Google's [*Site Reliability Engineering* book](https://sre.google/sre-book/table-of-contents/) laid it out a decade ago — its [chapter on automation](https://sre.google/sre-book/automation-at-google/) walks through a progression of maturity that ends, explicitly, at **systems that need no human intervention to keep running.** Self-healing. Autonomous. The top rung, named and described, in the most famous operations book in the industry.

So here's the uncomfortable part. That book is on every platform engineer's shelf and in every interview's "have you read" list. It is endlessly *cited*. How many people have actually read past the chapter titles? And of those, how many *apply* it — how many have built the autonomous rung rather than a very nice pipeline they call autonomous because it has a lot of YAML? The book is, as far as I can tell, the most-cited and least-applied text in the field. Citing it is table stakes; living it is rare. The ideas aren't secret or hard to find. They're just hard to *do*, and "automated" is a comfortable place to stop because it genuinely feels like you've arrived.

## What Autonomous Actually Looks Like

The autonomous rung isn't theoretical, and it isn't exotic anymore — the tools are sitting right there, open source, in wide use:

- **Kubernetes** is a stack of reconciliation loops. You declare "three replicas," and a controller spends the rest of its life making the world say three replicas — rescheduling, restarting, replacing, without anyone telling it to. The orchestrator isn't a deploy tool; it's a closed-loop controller for your workloads.
- **[Flux](/blog/flux-vs-argo)** extends that loop to the whole system's declared state: it watches a [control repository](/blog/control-repositories) and continuously makes the cluster match it. Edit the git declaration and the change rolls out; drift the cluster out-of-band and it gets reverted. The repo is the intent; the loop is the enforcement. Under [GitOps done as an actual reconciliation loop](/blog/gitops) — not "YAML in git" — the running state *is* the declared state, continuously.
- **Crossplane** pulls your cloud resources — databases, buckets, networks, the things that used to live in one-shot Terraform — into that same continuous loop, as first-class reconciled objects. Now the autonomous rung covers not just what's *in* the cluster but the cloud the cluster sits on.

And credit where it's due: none of this started with Kubernetes. **Puppet** and **Chef** were running closed-loop convergence years before it was fashionable — an agent wakes on a schedule, compares the machine against its declared manifest or recipe, corrects whatever has drifted, and does it all again on the next interval. That is the autonomous rung, built on cron and a desired-state model, long before "reconciliation loop" was a résumé phrase. Configuration management got here first. Kubernetes' real move wasn't inventing the loop — it was putting the loop at the *center* of the system instead of running it as a background job on each box, and extending it from one machine's config to the whole cluster's state.

Put those together and you get the discipline I've named [**DDCRI** — Declarative, Deterministic, Continuously Reconciling Infrastructure](/blog/ddcri), which exists to make exactly one sentence literally true: *what's in git is what's in your infrastructure — or alarms are sounding.* Not "should be." *Is.* And when it isn't — when the loop stalls or the world drifts and won't converge — that's not a discovery you make during an outage. It's an alert that already fired. DDCRI is just this essay's top rung, built out with the parts named and the drift wired up as a pageable condition.

## The Job Changes on Every Rung

Notice that your *own role* moves as the system climbs:

- On the **manual** rung, you *do* the work. You are the mechanism.
- On the **automated** rung, you *trigger* the work and watch it run. You're the operator of the mechanism.
- On the **autonomous** rung, you *declare the intent* and you own the *loop's health*. You're not in the path of the work at all — you're the author of what "correct" means, and the person the system pages when it genuinely can't get there on its own.

That last shift changes what you even alert on. On the lower rungs you page on "the thing broke," because a human has to go fix it. On the autonomous rung the loop fixes the ordinary breakages itself, silently — a pod dies at 3 a.m. and nobody wakes up, because by 3:00:05 it's back. So you stop paging on *failure* and start paging on *the loop failing to converge*: declared ≠ actual and not closing, reconciliation stalled, error budget burning. The pager gets quieter and more meaningful at the same time, which is the whole promise of [a system handed off so it can be run by someone who didn't build it](/blog/production-ready-is-a-handoff). You [stop holding out for a hero](/blog/stop-holding-out-for-a-hero) because the system no longer needs one for the routine case — and the hero's judgment is reserved for the genuinely novel failure the loop can't handle, which is the only place it was ever worth spending.

And the climb doesn't stop at operating software — it's now moving through the act of *writing* it. AI is the latest generation of the same thing. I write less and less code by hand; I write **standards** — the lint rules, the test contracts, the interface boundaries, the definition of "done" — and I direct agents to meet them. That's the identical ladder one level up: manual (type every line yourself), automated (run a generator or a scaffold when you say go), autonomous (declare what *correct* means and set agents converging on it, continuously, while you own the result). My role drifted to exactly where it drifted on the ops ladder — author of intent, owner of the loop — except the loop closing the gap is now an agent rather than a reconciler. Which is precisely why the standards have to be *enforced*, not suggested: when something other than you is writing the code, your lint gates and test contracts stop being bureaucracy and become the **declared desired-state the agents reconcile against.** The standard is how you direct a worker that never tires, never sleeps, and never reads the wiki — the same way a manifest is how you direct a cluster. Same rung, same discipline, one abstraction higher.

## Climb the Last Rung

Each rung exists to remove a class of human failure, and they remove different ones. Manual fails because humans forget, tire, and leave. Automated fails because the world keeps moving after your script stopped running. Autonomous fails only when the loop itself breaks — and because there's exactly one thing left to watch, you can watch it well and page on it precisely.

The ladder isn't optional polish you add once the "real" work is done. It *is* the real work of operations — the steady conversion of "a person does this" into "a system maintains this," rung by rung, until the only human left in the loop is the one deciding what the system should be. Most of the field has read about that top rung, nodded, cited the book, and settled onto the rung below it. The tools to climb the rest of the way are free, proven, and in your package manager. The only thing missing is the decision to treat "automated" as the middle of the climb instead of the end of it.
