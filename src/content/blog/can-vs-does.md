---
title: "'Can' vs 'Does'"
excerpt: "The difference between a system that can fail and a system that does fail is time. Murphy's Law is not a joke. It is a design constraint. Every moving part you add is another bet against the house, and the house always wins."
publishDate: 'Apr 16 2026'
tags:
  - Philosophy
  - Engineering
  - Architecture
isFeatured: true
---

## The Bet

Every moving part in a system is a bet. You are betting that this particular piece will not fail during the window that matters to you. The odds on any single bet are usually good. The odds on all of them, simultaneously, forever, are zero.

This is not a theoretical observation. This is Murphy's Law, and Murphy's Law is not a joke. It is not a cute poster for the break room. It is a design constraint. Anything that can go wrong will go wrong, given enough time and enough opportunities. The only variable is when.

The distinction that matters is between "can" and "does." A system where something *can* go wrong is every system ever built. A system where something *does* go wrong is a system where you gave Murphy enough surface area to work with. The gap between those two states is not luck. It is complexity.

## More Parts, More Murphy

This is statistics. If a component has 99.9% uptime — three nines, which is quite good — it is down for about 8.7 hours per year. Two independent components at 99.9% each have a combined availability of 99.9% × 99.9% = 99.8%. Three components: 99.7%. Ten components: 99.0% — that is 87 hours of downtime per year, from components that are individually "highly available." Twenty components at three nines each: 98.0%. Thirty: 97.0% — over ten days of downtime from a system made of parts that are each down less than nine hours a year.

The math is unforgiving. Availability compounds multiplicatively. Every component you add multiplies the probability of *something* being broken at any given moment. Each individual bet looks safe. The compound bet is a losing proposition, and the more bets you place, the faster you lose.

A single service with a database is a small bet. You are betting on the service, the database, the network between them, and the disk under the database. Four things. The odds are good.

Add a cache layer. Now you are also betting on the cache, the network to the cache, cache invalidation logic (which is famously one of the two hard problems in computer science), and the failure mode where the cache and the database disagree. You went from four bets to eight, and one of the new ones — cache coherence — is a bet you will lose eventually by definition.

Add a message queue. Add a second service. Add a load balancer. Add a CDN. Add a sidecar proxy. Add a service mesh. Add a secrets manager. Add a certificate authority. Add an observability pipeline with three backends and a collector. Each addition is individually justifiable. Each addition is a bet. The compound probability of all bets succeeding simultaneously, continuously, forever, approaches zero — and it gets there faster than most people's intuition predicts.

This is not an argument against distributed systems. Distributed systems exist because single machines have limits. It is an argument against *unnecessary* distribution. Against adding a cache "because we might need it." Against adding a message queue "because it's the architecture." Against adding a service mesh "because everyone else has one."

Every component you add must earn its place by solving a problem you actually have. Not a problem you might have. Not a problem your last company had. Not a problem you read about in a blog post. A problem you have, right now, that is causing pain. If it is not causing pain, you do not need the solution, and the solution's failure modes are strictly additive.

## The Human Factor

Murphy does not only operate on technology. Murphy operates on people. And people are the most unreliable component in any system.

A deployment process that requires six manual steps will eventually have step four skipped. Not because the engineer is incompetent. Because it is 2 AM, the pager went off, they are tired, and the runbook is twelve pages long. The question is not whether a human will skip a step. The question is how many incidents it takes before they do.

A security policy that requires developers to rotate credentials manually every 90 days will eventually have credentials that are 18 months old. Not because the developers are negligent. Because they are busy, the rotation process is painful, the tooling is bad, and nobody is checking. The question is not whether credentials will go stale. The question is how many, and when.

A code review process that requires three approvals will eventually have three rubber stamps. Not because the reviewers do not care. Because the PR is 4,000 lines, the reviewer has their own work to do, and the third approval is a formality that adds no information. The question is not whether reviews will become perfunctory. The question is at what PR size or volume.

This is human nature. Humans optimize for the path of least resistance. They are not lazy — they are efficient in the biological sense. Evolution favors organisms that conserve energy. When you build a process that fights human nature, human nature wins. Every time. Murphy's Law for people is just as reliable as Murphy's Law for software: anything that can be skipped, shortcut, or forgotten will be, given enough repetition and enough pressure.

The implication is that your process must be designed for the human who is tired, busy, under pressure, and taking the shortest path. If the shortest path through your process produces a correct outcome, you win. If the shortest path produces an incorrect outcome, Murphy wins. Designing for the disciplined engineer who always follows every step is designing for a person who does not exist at 2 AM on a Saturday.

## The Feature Pressure

Here is where it gets political.

Companies want features. Managers want features. Product wants features. Sales wants features. Everyone wants features, and they want them faster. This is not unreasonable — features are how companies make money, and making money is how companies continue to exist.

The pressure to ship features creates a systematic bias toward complexity. Every feature is a new moving part. Every new moving part is a new bet. But nobody accounts for the bets. The feature has a clear benefit — "customers want X." The bet is invisible — "X requires a new service, a new database, a new integration, and someone to maintain all three of them permanently." The benefit is legible. The cost is illegible. So the benefit wins, every time, and the complexity ratchets upward, never down.

This is how you end up with systems that have more services than engineers. Systems where nobody understands the full architecture. Systems where adding a feature takes longer than it did two years ago, despite having twice the team. Systems where an outage in a service nobody has heard of takes down the entire platform because it turns out the authentication service depends on it through a chain of four transitive dependencies that nobody mapped.

The ratchet only turns one way. Adding complexity is easy. Any individual engineer can add a service, a database, a queue, a cache. Removing complexity requires consensus, courage, and time — none of which are abundant in an organization that is under pressure to ship features. So the complexity accumulates. Each addition is small. The cumulative effect is a system that is fragile in ways nobody fully understands, maintained by people who are afraid to change it.

This is Murphy's playground. Complex systems fail in complex ways. Simple systems fail in simple ways. Simple failures are easy to diagnose, easy to fix, and easy to prevent from recurring. Complex failures cascade, interact, and surprise. You can reason about a simple system. You cannot reason about a complex one — you can only react to it.

## "Your Day" Moves

There is a class of techniques in the martial arts I like to call "your day" moves. The techniques that work when you are fresh, focused, and in control are not the techniques that work when you are exhausted, surprised, and under pressure. Under pressure, you do not rise to the occasion. You fall to the level of your training. You fall to whatever is simple enough and practiced enough to survive the adrenaline, the tunnel vision, and the chaos.

Systems work the same way. The architecture that looks elegant in a design review is not the architecture that survives a production incident at 3 AM. Under pressure, timescales collapse. You do not have time to consult the runbook, trace the dependency graph, or remember which of twelve services handles the thing that is currently on fire. You fall to the level of whatever is simple enough to reason about when nothing is going right.

A system with three components has a small number of failure modes that a tired engineer can hold in their head. A system with thirty components has failure modes that nobody can enumerate, let alone diagnose under pressure. When the pager goes off, the simpler system is more likely to survive — not because it is less likely to fail, but because the failure is more likely to be understood, diagnosed, and fixed by someone who is not at their best.

This is not an aesthetic preference. It is a survival strategy. The plan with fewer steps is more likely to survive contact with reality. The architecture with fewer moving parts is more likely to survive an outage. The process with fewer dependencies is more likely to survive the human who is tired, stressed, and making decisions with incomplete information.

Robert Heinlein made the same observation in *Starship Troopers* (1959): "If you load a mud foot down with a lot of gadgets that he has to watch, somebody a lot more simply equipped — say with a stone ax — will sneak up and bash his head in while he is trying to read a vernier." The soldier with less gear has fewer things competing for his attention, fewer things that can break, and fewer things standing between him and the one thing that matters right now.

Complexity is a luxury of peacetime. Simplicity is a requirement of crisis. And crisis is not hypothetical — it is inevitable. Build for the day when everything goes wrong, because that day is coming. The system you can reason about under pressure is the system that survives.

## K.I.S.S.

Keep It Simple, Stupid. The acronym is crude. The principle is profound.  Its advice, but it is also a warning.

Simplicity is not the absence of capability. It is the absence of unnecessary capability. A system that does one thing well is simpler than a system that does ten things adequately. A process with three steps is simpler than a process with twelve steps, even if the twelve-step process covers more edge cases. The edge cases it covers are not free — they are bets, and each bet has a cost that compounds over time.

The question to ask about every component, every process step, every architectural decision is not "can this fail?" Everything can fail. The question is "does this earn its failure modes?" Does the value this component provides outweigh the new ways it can break, the new things you have to monitor, the new knowledge someone has to carry in their head, the new dependency in your startup sequence, the new entry in your runbook?

If the answer is yes, add it. If the answer is "maybe" or "eventually" or "in case we need it," do not. You can always add it later, when the need is real and the failure modes are justified by actual value. You cannot easily remove it later, because by then something depends on it, someone built on top of it, and removing it is a project that nobody wants to fund.

## "Can" Is Free. "Does" Costs.

A system where something can go wrong is every system. A system where something does go wrong is a system where you bet too often, or bet on things that were not worth the risk.

The discipline is straightforward: fewer moving parts, simpler processes, shorter paths, less room for Murphy to operate. Not zero parts — you need what you need. But only what you need, and nothing you do not. Every addition must justify itself against the cost of its failure, not just the benefit of its success.

Murphy is patient. Murphy is thorough. Murphy does not take days off. The only defense against Murphy is to give Murphy fewer opportunities.

Can everything fail? Yes. Will everything fail? Given enough complexity, enough time, and enough pressure — yes. The game is not to prevent failure. The game is to make failure cheap, obvious, and recoverable by keeping the system simple enough that you can reason about it when things go wrong.

Because things will go wrong. The only question is whether you built a system where "can" stays theoretical, or one where "does" was only a matter of time.
