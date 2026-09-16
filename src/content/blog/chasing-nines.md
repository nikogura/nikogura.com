---
title: 'Chasing Nines'
excerpt: "Your availability target — how many nines you promise — isn't a line in a contract, it's an architecture decision. Get it wrong in one direction and you fail the SLA you sold. Get it wrong in the other and you burn money buying nines you never promised. I once looked at a stack paying $10,000 a month for high availability it did not actually have."
publishDate: 'Sep 16 2026'
tags:
  - SRE
  - Reliability
  - Architecture
  - Engineering
isFeatured: false
---

Everyone wants their system to be "highly available." Almost nobody stops to say what that means in numbers, and fewer still design as though the number were real. But the number *is* real, and it is a decision — the single most consequential architecture decision you will make about a system's shape and its bill. The number is your nines.

An availability target is not marketing. Each nine is a budget of allowed downtime, and your architecture is how you spend that budget. Promise a number, and you have promised to build something that can hold it. There are exactly two ways to get this wrong, and I see both constantly: you can build for more nines than you promised — and light money on fire — or you can promise more nines than you built for, and quietly breach the SLA you sold. The interesting part is that the same discipline avoids both, and most teams practice neither.

## "HA" Is Not A Number

Before any of the architecture, there's a failure of language that causes most of the waste: treating "high availability" as a goal instead of a number. I watched a client do exactly this. They had promised their customers three nines. When I showed them that their architecture didn't deliver it — and that the one place they'd spent lavishly on redundancy was buying them nothing — the answer wasn't a question about the design. It was the letters "H-A," repeated, almost as a mantra. They wanted HA. They were paying for HA. Surely, then, they *had* HA.

"HA" is not an architecture. It's an adjective, and on its own it means nothing. There is no such thing as "highly available" in the abstract — there is only *this many nines*, which is *this many minutes of downtime a month*, which demands *this specific architecture at this specific cost*. The instant you can't say the number, you have stopped engineering and started chanting. Every real decision downstream — how many zones, hot standby or cold, human recovery or automatic — hangs off that number, and if the number isn't pinned, none of those decisions can be made correctly. They get made anyway, by reflex and by whoever is loudest, which is precisely how you end up with a five-nines cache in front of a two-nines everything-else.

And the number is not optional in the other direction either. Once you've *sold* three nines, "HA" is no longer an aspiration you gesture at — it's a spec you owe, and you have to actually design and engineer the system to hold it. The SLA is the specification; the architecture is the implementation; and like any spec, building above it wastes money and building below it ships a defect. So the first move is always the same, and it isn't technical: replace the mantra with a target. Write down the nines you sell, and the support commitment behind them, because everything after this sentence is engineering to meet that written number.

## What A Nine Actually Costs You

Start with what the promise means, because the intuition is bad. "Three nines" sounds close to "four nines" — one more nine, how different can it be? It's a factor of ten each time, and here is the budget it buys, on a 730-hour month:

| Nines | Availability | Downtime / month | What It Takes To Hold It |
|---|---|---|---|
| two | 99% | ~7.3 hours | Standard single setup. Manual fixes and overnight maintenance windows. |
| three | 99.9% | ~44 minutes | Automated alerting, humans on call 24×7 — but with time to log in and fix it. |
| four | 99.99% | ~4.4 minutes | Automated recovery. Systems auto-heal, auto-scale, and fail over without a human. |
| five | 99.999% | ~26 seconds | Multi-region, active/active. Insanely expensive. |

The right-hand column is the whole argument in miniature. Two nines is *seven hours a month* — a leisurely outage, a long lunch, a full night's sleep before you fix it, and an overnight maintenance window whenever you need one. Three nines is forty-four minutes for the *entire month*, across every incident combined; you can still be a human being about it — an alert fires, you log in, you fix it — but you have to be reachable around the clock, because there is no room to sleep through one. Four minutes is not a human number: nobody reads a runbook, let alone wakes up and logs in, inside four minutes, so at four nines the system has to heal, scale, and fail over on its own. Twenty-six seconds means no human is in the loop at all, and you're paying for two of everything in two regions to make failures invisible.

That's the point the table hammers: each nine doesn't just cost ten times less downtime, it costs a categorically different architecture and a categorically different bill. Somewhere between three and four nines, the budget crosses below "a person can respond in time," and the whole system has to change character — from *humans recover it* to *it recovers itself*. That threshold is the real decision, and it should be made on purpose, not backed into by a salesperson's promise.

## Availability Is A Chain

Here is the mistake that costs the most money, and it belongs to the same client from a moment ago — the ones chanting "HA." Their stack: an active/active cache replicated across two availability zones — the configuration you'd design if you needed four or five nines out of that cache. Genuinely resilient. Genuinely expensive: on the order of **$10,000 a month** in cross-AZ data-transfer charges alone, before the doubled infrastructure.

The rest of the stack was single-AZ, single-instance per component. One box each. No redundancy anywhere else.

So what was the system's availability? Not five nines. Availability composes in series: when a request has to pass through a chain of components that each must be up, the system's availability is the *product* of theirs. A five-nines cache (0.99999) behind a single-instance app tier that's realistically around two nines (0.99) gives you `0.99999 × 0.99 ≈ 0.99` — two nines. The system is exactly as available as its weakest link, and the five-nines cache contributes essentially nothing to the number the customer actually experiences.

They were paying $10,000 a month to reinforce one link of a chain whose next link was tissue paper. The "HA" they were buying did not exist at the system level, and no amount of spend on that one component could create it. That is the purest form of waste I know: money spent on a nine that the architecture cannot deliver. It's the flip side of [betting a dependency won't fail](/blog/gambling-on-failure) — here they'd bet, correctly, that the cache *would* fail, and then spent a fortune protecting against it while leaving nine other single points of failure completely exposed.

And it isn't only the weakest link — it's the *number* of links. Because availability multiplies, every component in the request path drags the system number down, even the healthy ones. Ten components each at a respectable three nines (0.999) compound to `0.999¹⁰ ≈ 0.990` — the whole system lands at *two* nines, purely from stacking ten solid parts in series. That's the multiplicative tax I've written about before: [every moving part is a bet, and compound bets lose](/blog/can-vs-does). Each part looks safe on its own; the product of all of them, up at once, forever, is a losing proposition, and the more parts you add the faster the number falls.

So raising a system's nines has exactly two honest levers, and buying a fancier version of one component is neither. You **raise the floor** — find the least-available thing in the request path and fix *that*, because it sets your number no matter what you do to everything else. And you **reduce the count** — take links out of the path, because fewer moving parts isn't just cleaner, it's arithmetically more available. A five-nines component bolted onto a long chain of two-nines components is decoration on a system that is only as strong as its worst link and only as long as you let it get.

## Redundancy Is Not The Only Way To Buy A Nine

Now the part teams reach for by reflex and shouldn't. There are two ways to buy a nine, not one.

The first is **hot redundancy** — active/active, remove the single point of failure so that a component failure isn't an outage at all. It's the expensive way: you run everything at least twice, you pay to keep the copies in sync, and across zones you pay for every byte that crosses between them. It's the right tool when your downtime budget is too small for a human — at four and five nines you have no choice, because there is no time to recover, so failures simply must not become outages.

The second is **fast recovery** — accept that the component will fail, and make restoring it fit inside your budget. And your budget at three nines is *forty-four minutes a month*. That is a lot of room. If a component fails rarely, and you can detect it and stand it back up — in another AZ, from scratch — comfortably inside that budget, you meet three nines without paying to run everything twice. That's why a single-AZ, single-instance stack with a real recovery path can honestly promise three nines, while the active/active cache bolted to it was solving a problem the SLA didn't have.

But be precise about the budget, because this is where the argument gets hand-waved and then breaks:

- **It's a monthly total, not a per-incident allowance.** Forty-four minutes covers *every* incident that month, summed. Recover from one failure in forty minutes and you've spent nearly the whole budget on a single event.
- **Detection is on the clock.** The budget starts when you're down, not when you notice. Twenty minutes of "is it just me?" is twenty minutes gone.
- **So the real test is `MTTR × failures-per-month + detection lag < budget`, with margin.** If you fail once a quarter and recover in half an hour, three nines is comfortable. If you fail twice a month, a thirty-minute recovery already blows it. Know your failure rate; don't assume one.
- **The recovery has to actually work.** A failover you've never executed is not a recovery plan, it's a hope — the difference between [*can* and *does*](/blog/can-vs-does). Rehearse it, on a schedule, or it will fail the one time you need it.
- **And a human doing it by hand at 2 a.m. is a [load-bearing human](/blog/load-bearing-humans)** — the recovery is only as reliable as that one person being awake, reachable, and calm. That's fine at two or three nines with a tested runbook; it is not fine as your only plan, and it doesn't scale down to four.

Fast recovery has a hard prerequisite most people skip: you can only stand up in another AZ *fast* if standing up is a command, not an archaeology project. That means the whole environment is reproducible from code and you can [redeploy it on demand](/blog/gitops) — which, if [your infrastructure-as-code is the usual broken kind](/blog/most-infrastructure-as-code-is-broken) that describes a state once and drifts from it forever, you cannot. The cheap path to a nine is paved with reproducibility. Buy that first.

## Start Where Terrace Started

We ran Terrace in a single availability zone at first, on purpose. It was pre-launch. There were no customers, no signed SLA, and therefore no availability we owed anyone. Paying for cross-AZ redundancy in that state would have been paying real money — cross-AZ data transfer is not free — to protect a promise that didn't exist yet. The correct number of nines before launch is low, and the architecture matched it. Single AZ, move fast, spend nothing on redundancy nobody is owed.

The same cost-awareness ran on another axis. Data *into* AWS is free; data *out* of it is metered, and at volume that egress bill is not a rounding error. So we didn't treat "the cloud" as one undifferentiated place to run everything — we placed workloads deliberately across cloud and bare metal to stay on the cheap side of that asymmetry. Elastic, ingest-heavy work sat where cloud economics and free inbound transfer paid off; steady, egress-heavy work sat on bare metal, where bandwidth is a flat monthly commitment instead of a per-gigabyte toll. Same instinct as the nines: don't pay a premium where you don't owe one, and put each piece of the system where its costs are lowest.

That is the whole discipline: match the spend to the reality — the availability you owe and the data you move — and change either only on purpose. As you approach a real SLA and [real customers who give you money](/blog/nice-people-who-give-us-money), you add nines — and the trick is to design from day one so that you *can* add them without a rewrite. Single-AZ today, but structured so multi-AZ is a configuration change and a bigger bill, not a re-architecture. [Don't paint yourself into a corner](/blog/dont-paint-yourself-into-a-corner): the goal isn't to build five nines on day one, it's to never make a choice that forecloses the next nine when you finally owe it.

## The Two Failure Modes

So it cuts both ways, and both ways are expensive.

**Overspending:** five nines of infrastructure standing behind a three-nine promise. Money lit on fire every month, and worse than the money, false confidence — you *think* you have five nines because you paid for the fancy component, and you've never noticed that the single-instance thing next to it caps you at two. The $10,000-a-month cache is this failure mode exactly.

**Underspending:** selling three nines on a stack that struggles to hold two. This is the one that ends up in the incident review and the churned-customer report. You promised forty-four minutes and you're delivering seven hours.

And there's a special circle for doing both at once, which is more common than it should be: paying for five-nines redundancy on one component *while failing your actual SLA elsewhere*. That's the worst outcome available — you spent the money and you're still in breach. All the cost, none of the availability, plus the false confidence that told you not to look at the thing that was actually down.

## Decide, Then Design

Chasing nines for their own sake is how you end up with enormous bills for availability you don't have. The nines are not a virtue you accumulate; they're a promise you fund.

So decide the SLA first — what you actually owe, to whom, backed by what support commitment — and write the number down, because "HA" with no number attached is a mantra, not a plan. Then build the *cheapest* architecture that meets it with margin, and not one nine more. Find your weakest link and let it set your honest number; take out every link you don't need. Buy nines with fast, rehearsed, reproducible recovery until the budget drops below what a human can do, and only then start paying to run everything twice. And revisit the whole calculation every time the promise changes, because it will.

A nine is a budget. Don't buy budget you'll never spend, don't promise budget you can't fund, and don't mistake a word you like for a system you've actually built. Everything else is just arithmetic — and now you have the table.
