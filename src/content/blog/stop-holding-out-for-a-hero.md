---
title: 'Stop Holding Out for a Hero'
excerpt: Incident response is either an engineering discipline — measured, quantified, repeatable, owned, evaluated — or it is a craft a few heroes practice and nobody else can see. Heroes are great. You shouldn't need them, and you shouldn't bet the company on still having them.
publishDate: 'Jun 17 2026'
tags:
  - Incident Management
  - Operations
  - Engineering
isFeatured: true
---

Every organization has a hero. The person who, when the page goes off at 3 AM, somehow already knows it's the connection pool, already knows which dashboard to open, already knows who to call. They've been there since the beginning. They hold the whole system in their head. When something breaks, everyone exhales a little, because *they're* on it.

Heroes are real, and they are genuinely valuable. This is not an essay against them.

It is an essay against *depending* on them.

> Incident response is either an engineering discipline — measured, quantified, repeatable, owned, evaluated — or it is a craft a few heroes practice and nobody else can see.

The first is an asset of the organization that survives any individual leaving. The second is a liability disguised as a strength, available only on the nights the right person happens to be awake.

## Heroes Are Single Points of Failure

You would never knowingly run production on a single database with no replica, no backup, and no failover. If someone proposed it, you'd reject it on sight — one bad day and the business is gone, and you'd have no way to see it coming.

A hero is that architecture, pointed at your *response capability* instead of your data. The knowledge lives in one head. There is no replica, because it was never written down. There is no failover, because no one else has run the play. And there is no monitoring, because the thing that's fragile — "can we actually respond when this person isn't here?" — is invisible until the night you find out you can't.

"But we have more than one hero." That feels like redundancy. It isn't. Redundancy requires *interchangeable* units — a replica is a replica because it holds the same data and can stand in without anyone noticing. Heroes are not interchangeable; that's precisely what makes them heroes. Each one holds a different corner of the system in a different head, so a team of five heroes isn't one resilient system — it's five single points of failure standing next to each other. Lose any one and you lose a domain nobody else can cover. Five undocumented heads is five bus factors, not one divided by five. They're *people*, not *processes or systems*, and people are exactly the dependency you can't schedule, replicate, or monitor.

Heroes leave. They always do, eventually — they retire, they burn out, they take the offer, they're simply asleep when it matters. The day one walks out the door, an enormous amount of operational capability walks out with them, and nobody can quantify how much because none of it was ever an artifact. It lived in a head.

You shouldn't need heroes. And you shouldn't bet the company on still having the ones you've got.

## The Process Is the Uncontrolled Variable

Here's the trap, and it's a subtle one: hero-dependent response *works* — until it doesn't. That's why it survives. Good people repeatedly produce good outcomes, the incidents get resolved, and everyone concludes the process is fine — right up until the night the right person isn't there, and then there is no process at all, just an empty channel and a clock running.

But the outcome depended on the people, not on the process — because the process was the part you never controlled. When the response is undocumented and ad-hoc, a good result tells you that you had a good person available, and nothing more. You cannot distinguish "the process worked" from "we got lucky and the right person was awake." Those are different claims, and only one of them is something you can rely on next time.

The findings that matter here are structural, not personal. The point is never that the responders did poorly — usually they acted heroically. The point is that the outcome is a function of *who was staffed and their goodwill*, and that is not a property you can plan around, schedule, hand off across a timezone, or improve.

## A Neutral Way to Measure It

It helps to measure yourself against something that isn't your own opinion. The book [*Incident Management for Operations*](https://www.oreilly.com/library/view/incident-management-for/9781491917619/) (Schnepp, Vidal, Hawley; O'Reilly) lays out a maturity rubric that does exactly this — and it carries a foreword by [Jesse Robbins](https://jesserobbins.com/), the volunteer firefighter and former Amazon "Master of Disaster" who brought the fire service's Incident Command System into web operations in the first place. A mature incident-response process is:

- **Predictable** — you can anticipate how a response unfolds: who is in charge, how severity is set, who decides what, in what order.
- **Repeatable** — the same kind of incident produces the same kind of response, regardless of who is available.
- **Optimized** — minimal time-to-mitigate; no duplicated work, no idle waiting on decisions.
- **Clear** — everyone knows their role, the state, and the next step without asking; it is written and communicated.
- **Evaluated** — measured, reviewed, *and practiced*; post-mortems with owned action items; adherence is observable; metrics feed back into improving the process. You cannot evaluate a process you never run, so a mature one is rehearsed deliberately — at low severity, on a schedule — not merely invoked when something is on fire.
- **Scalable** — the same framework runs a one-person minor event and a company-wide outage; the posture scales, the playbook doesn't change.
- **Sustainable** — runs around the clock without burning people out or depending on heroics; coverage is defined and load is shared.

**Clear** and **Evaluated** are not peers of the other five. They're preconditions. A process that is not written down and not measurable can never become any of the others — you can't make a process repeatable if it only exists in someone's memory, and you can't optimize what you don't measure. Get those two, and the rest become reachable. Skip them, and the rest are impossible by construction.

The operative word in **Evaluated** is *practiced*. A written, measured process that nobody ever exercises is still just a document. You build the muscle the same way the fire service does — with planned, low-stakes drills, what web operations calls Game Days: you break something on purpose, run the full response as if it were real, and grade the response rather than the fix. Rehearsal is what turns the artifact into a reflex, and it's the only thing that makes the rare, severe event survivable — which is the next problem.

A hero-driven process fails the first six of these and quietly passes the seventh only by accident — most teams have decent post-mortems even when they have no command process, because writing down what happened *after* is a different muscle than running the thing *during*. Hold the honest mirror up, and you'll usually find the recording end of the discipline already exists. It's the command middle that's still a craft.

## "We Barely Have Incidents" Is the Argument *For* This, Not Against It

The most common objection sounds reasonable: "We've had a handful of serious incidents in a decade. The current approach has been fine. Why formalize something we rarely use?"

The rarity is the argument, not the excuse.

An event that occurs once every couple of years is *precisely* the event for which no one builds muscle memory. The only way the response to it is competent is if the process is written down and rehearsed at low severity, so that when the rare big one finally arrives, everyone already knows the play. A process you exercise only every two years, undocumented, is a process you are re-inventing under maximum pressure every single time — which is the worst possible condition under which to be improvising structure.

And beware the incident that "proves" you're fine because there was nothing to do. The upstream-provider outage (AWS is down, GitHub is down) where all you can do is track the heartbeat and manage external comms is not evidence your command process works — nothing was ever demanded of it. You don't get to count a case where the structure was irrelevant as proof the structure is sound.

## What It Actually Costs

Hero-dependent response has a price even on the days the hero shows up, and it's usually paid in coordination, not in difficulty.

The classic pattern is serial escalation: ping the component owner, wait, and if they don't answer, start walking up the management chain. Each hop is unbounded latency. I have watched incidents stay open for *days* where the actual remediation, once someone was finally empowered to decide, took minutes. The system wasn't hard to fix. It was hard to *coordinate* — nobody knew who could make the call, so the clock ran while the fix sat there waiting on a decision nobody owned.

The other hidden cost is the emergency-contact bus factor. In a lot of these shops, the escalation path lives in a line manager's private contacts. That's not a process — it's a single point of failure that's also *invisible*. When that manager is on a plane, no responder can even find the path to escalate, and nobody discovers this until 3 AM on the night it matters.

## Write It Down First — Then, Separately, Build the Coverage

Here's the part teams get wrong, and the reason this conversation so often stalls: they conflate "formalize incident response" with "commit everyone to a 24/7 on-call rotation with pagers and SLAs." Those are two very different asks, and bundling them kills both.

Split them.

**Documentation is cheap and imposes no new obligations on anyone.** Write the command process down. One canonical, version-controlled document: response roles, a graded severity scale, declaration criteria, communication cadence, and decision authority. That's it. It does not add on-call duty, pagers, or SLAs to a single person's job. It just makes how a response is *run* into an artifact instead of a memory. Once it exists, it can be followed, taught, handed off across a shift, executed by someone who doesn't already hold it in their head — and *measured*. This is the move that converts the craft into a discipline, and it's nearly free.

**On-call duty is where the real cost lives, and it deserves its own negotiation.** Paging, rotations, and severity-graded SLAs for responders outside the core ops team — that's a genuine cross-functional commitment involving engineering, support, and product, and it should be chartered as its own workstream *after* the command process exists to hang it on.

Separating them is the whole point. Documentation is cheap, safe, and usually overdue — and it's what makes the process measurable in the first place. The expensive part is standing coverage: on-call rotations and the response-time SLAs you commit to meet. That's what needs real organizational buy-in, because it obligates people's time, not just an afternoon of writing. Conflating the cheap artifact with the expensive commitment is what has stalled both in every org I've watched try and fail to "fix incident response" in one heroic motion.

## The One Move

The choice in front of most teams is not between two processes. It's between two definitions of what incident response even *is*: an engineering discipline, or a craft. The only thing separating them is whether the play exists anywhere outside a single person's head.

Writing it down is that one move — the cheap precondition the whole rubric stands on, and the one most teams skip. Not because it's hard, but because the heroes keep making its absence survivable, right up until they don't.

Keep your heroes. Celebrate them. Just make sure that the day one of them leaves, the play they were running is still on the field — because you wrote it down, and now anyone can run it.

If you want the actual playbook — the role-based command model itself, the Incident Commander who doesn't touch the keyboard, the Scribe, the CAN format, severity scales, and the discipline that makes it survive 3 AM — I've written that up separately in [Incident Management](/blog/incident-management). This piece is the argument for *why* you write it down at all. That one is *how*.
