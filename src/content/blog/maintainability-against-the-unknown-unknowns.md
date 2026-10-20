---
title: 'Maintainability Against the Unknown Unknowns'
excerpt: "You can harden a system against the failures you can imagine. You cannot harden it against the ones you can't — and those are the ones that take you down. The only defense against a failure you never predicted is a system you can understand, change, and recover fast enough to survive the surprise. That capacity has a name: maintainability. It's the most undervalued property in engineering, because its payoff is invisible until the day it's everything."
publishDate: 'Oct 6 2026'
tags:
  - Maintainability
  - Reliability
  - SRE
  - Architecture
isFeatured: false
---

There's a taxonomy of risk that's worn out from overuse but still exactly right. **Known knowns** — the things you know you know. **Known unknowns** — the things you know you don't know. And **unknown unknowns** — the things you don't know you don't know. The failures that never crossed your mind until they were already happening.

Most of engineering reliability is about the first two quadrants, and that work is good and necessary. You handle known knowns by building for them. You handle known unknowns by planning around them — a dependency *will* fail eventually, so you add retries, backoff, failover, and capacity headroom, even though you don't know exactly when. That's [gambling on failure correctly](/blog/gambling-on-failure): you don't know the day, but you know the category, so you armor against the category.

The third quadrant is the one that actually takes companies down, and it is the one almost nobody has a real answer for. You cannot build a specific control against a failure you cannot name. By definition, the unknown unknown is the one you didn't model — the interaction nobody saw, the emergent behavior under a load you never tested, the dependency you forgot was a dependency, the thing that was fine ten thousand times and then wasn't. So what do you actually *do* about a category of risk you can't enumerate?

You stop trying to predict it, and you make the system cheap to change when it surprises you. That capacity has a name, and it's the most undervalued property in engineering: **maintainability.**

## You Can Only Armor What You Imagined

Fortification is bounded. Every specific defense you build — a retry here, a circuit breaker there, a validation rule, a rate limit — is a response to a failure mode someone pictured in advance. That's real value, and I'm not waving it off. But notice the ceiling: the sum of your defenses can never exceed the sum of your imagination. You are armored exactly as far as you thought ahead, and not one inch further.

And the failures that hurt most are, with almost perfect reliability, the ones outside that perimeter. If you'd imagined them, you'd have built for them; you're not sitting there knowingly leaving a hole. The outage comes through the gap you didn't know was a gap. So a strategy that consists *only* of enumerating threats and hardening against each one has a built-in failure mode: it is perfectly prepared for the past and blind to the novel. Given any interesting amount of time and scale, the novel is not a maybe. It's a certainty with an unknown arrival date — which is just a known unknown wearing the clothes of an unknown unknown.

You can't out-predict this. Prediction has a ceiling and the world doesn't. So the game can't be *foresee more*. The game has to be *respond faster than the failures arrive.*

## Maintainability Is the General Defense

Here's the move. Since you can't build a defense against the specific failure, you build up the system's capacity to absorb and respond to *any* failure — including the ones you'll never see coming. You trade specific armor, which only works against what you imagined, for general adaptability, which works against whatever shows up.

That's what maintainability actually is, and it's worth rescuing the word from the way it usually gets used. Maintainability is not tidiness. It is not "clean code" as an aesthetic. It is the **measured ease and speed with which a system can be understood, changed, and recovered by someone operating under pressure who did not build it.** It is adaptive capacity, quantified in minutes-to-understand and minutes-to-safely-change. And it is precisely the thing that decides whether an unknown unknown is a bad afternoon or a company-ending week.

The distinction is fortification versus adaptability. Fortification is a wall at a fixed height — it stops exactly the attacks shorter than the wall. Adaptability is the ability to see what's coming and build the wall taller before it arrives. Against a known threat, you want the wall. Against an unknown one, the wall is useless and the ability to adapt is everything. You need both, but the industry massively over-invests in walls it can see and under-invests in the adaptability it can't put on a slide.

## What Maintainability Actually Buys You

"Be adaptable" is a greeting card unless you can say what it's made of. Maintainability decomposes into a handful of concrete capacities, and every one of them is a lever you pull against a failure you didn't foresee:

- **Comprehensibility — can someone understand it, fast, who didn't write it?** The unknown unknown always seems to arrive at 3 a.m. while the author is asleep, on vacation, or at a different company. Whoever's holding the pager has to build a correct mental model of the system *right now*, from what's written down and what the system shows them. This is the dividend of [simplicity — fewer moving parts](/blog/can-vs-does), [clear interfaces and style that reads straight through](/blog/c-style-vs-go-style), and [documentation that is the org's memory rather than one person's](/blog/documentation). A system only its author can understand has already decided that the novel failure will be handled slowly, badly, or not at all.

- **Observability — can you see a failure you never anticipated?** You can't pre-build a dashboard for an unknown unknown; the whole point is you didn't know to build it. What you *can* do is make sure the raw signal exists to investigate *anything* — [metrics, logs, traces, and events](/blog/metrics-logs-traces-events) rich enough to reconstruct a story you didn't write in advance. Observability is the one form of preparation that pays off against the unforeseen specifically, because it's general by construction: it doesn't assume what the question will be.

- **Changeability — once you understand it, can you safely change it in minutes, not days?** The fix for a novel failure is, by definition, a change you did not plan to make. Maintainability is how fast and how safely you can make it. [Reproducible, continuously-reconciled infrastructure](/blog/most-infrastructure-as-code-is-broken) under [GitOps](/blog/gitops), [trunk-based development with the discipline to ship small](/blog/trunk-based-development), a [control repository that is the release artifact](/blog/control-repositories) — these exist so that "I now know what to do" and "it is done, safely, in production" are separated by a short, auditable, reversible step instead of a terrifying one.

- **Recoverability — can you get back to known-good?** Often the fastest response to a failure you don't yet understand isn't to fix it forward — it's to undo it and buy time to think. A fast, defined rollback; backups you have [actually restored](/blog/production-ready-is-a-handoff); a reconciliation loop that converges the system back to its declared state no matter what knocked it off. [DDCRI](/blog/ddcri) earns its keep here precisely because it defends against drift *without naming the cause of the drift* — it just notices that reality diverged from intent and pulls it back, which is about as close to a general-purpose defense against the unforeseen as infrastructure gets.

- **Containability — when it breaks, how much breaks?** You can't stop the unknown unknown from happening, but you can decide in advance how far it's allowed to spread. Modularity, least privilege, isolation, bounded blast radius — these don't prevent the surprise, they shrink it. The difference between "one service degraded" and "the whole platform is down" is usually not whether the triggering failure was foreseen. It's whether the architecture contained it.

Notice that none of these is a defense against a *specific* threat. Each is a defense against the *category* of "something I didn't plan for." That's the whole trick: you can't prepare for the unknown unknown directly, but you can prepare, in general, to respond well to anything.

## Why It Always Gets Cut First

If maintainability is this valuable, why is it the first thing sacrificed under deadline pressure? Because its return on investment is invisible right up until the moment it's the only thing that matters.

Every other investment has a legible payoff. A feature has users who want it. A performance fix has a graph that goes down and to the right. Maintainability has... nothing to show, most days. It's an insurance premium: you pay it continuously, you see no benefit the vast majority of the time, and it feels like pure cost — until the one day the claim pays out and it's the difference between an incident and an obituary. This is why it hides behind the weasel-word "non-functional," the same vocabulary trick that lets orgs quietly demote reliability and security. Anything labeled "non-functional" is being set up to be cut, and maintainability wears that label more than almost anything.

The mistake is treating it as polish — something you add once the "real" work is done. It isn't polish. It's the premium on the only insurance policy that covers the one category of risk you cannot otherwise insure at all. You can't buy a specific control against unknown unknowns; there's no product for it. The only thing on the market is adaptive capacity, and you buy it one maintainable decision at a time, long before you know which one will save you.

## Adaptability Beats Prediction

The deepest version of this is almost philosophical, so let me say it plainly. You will be surprised. Not might — *will*. Any system that runs long enough, at any interesting scale, will do something its builders did not anticipate. That is not a knock on the builders; it's a property of complex systems meeting the real world. The only live question is whether, when the surprise comes, your system lets you understand it, change it, and recover from it faster than it can hurt you.

A system can't survive by anticipating everything, because nothing anticipates everything. It survives by being *adaptable* — by lowering, everywhere, the cost of the response you didn't know you'd need to make. Some of that adaptability you can even automate: [the autonomous rung — a reconciliation loop that converges back to declared state](/blog/manual-automated-autonomous) — absorbs a whole class of unforeseen drift with no human in the loop at all, which is maintainability's reflexes operating at machine speed. The rest of it is human, and it runs on comprehensibility, observability, and the ability to change the system without fear. Either way the principle is identical: [you don't hold out for a hero who happened to foresee this exact failure](/blog/stop-holding-out-for-a-hero), because no such hero exists. You build a system that an ordinary competent person can save in real time, and you [don't paint yourself into a corner that forecloses the fix you'll turn out to need](/blog/dont-paint-yourself-into-a-corner).

I [write code as though I'm writing for a generation ship](/blog/generation-ships) — for the person who will operate it long after I'm gone, who can't ask me anything, and who will face a situation I never imagined. That's not sentiment. It's the only posture that's honest about how little of the future I can see. I can't predict the failure that engineer will face. I can hand them a system they can actually fight it in.

## Build for the Surprise You Can't Name

Harden against the known threats — of course. Enumerate your failure modes, build your retries and your circuit breakers, close the holes you can see. That's necessary, and it's the easy, legible, fundable part.

But understand its ceiling, and spend accordingly on the part that has no ceiling. The failures that end companies come from outside the perimeter of anyone's imagination, and the only thing that has ever reliably defended against them is a system you can understand, change, and recover faster than the surprise can compound. Maintainability is not the chore you do after the real work. For the one category of risk you can never predict, it *is* the real work — the premium on the only policy that pays out when the thing you didn't see coming finally arrives. And it always, eventually, arrives.
