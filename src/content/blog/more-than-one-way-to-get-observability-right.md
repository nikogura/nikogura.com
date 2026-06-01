---
title: "There's More Than One Way to Get Observability Right"
excerpt: "The specialize-versus-unify argument feels like a religious war. It isn't. Both sides are right — they're answering different questions. There are several ways to get observability right. The way to get it wrong is to never ask which one you're building for."
publishDate: 'June 1 2026'
tags:
  - Observability
  - Architecture
  - Engineering
isFeatured: true
---

I once ran into a customer's observability stack that did three things. It put logs in OpenSearch. It put metrics in OpenSearch. And it had no traces at all.

That's it. That's the whole stack.

It's worth being precise about why this is bad, because each piece is bad in a different way. Logs in a full-text search engine is the one defensible decision in the pile — that's what a search engine is *for* — and it's also the one that required no thought. Metrics in the same engine is the expensive mistake: you're running numeric aggregation through a Lucene inverted index, paying full-text indexing cost on data that never needs full-text search, and waiting for the day a label's cardinality blows the whole thing over — usually mid-incident, when you wanted a fast aggregate and got a query timeout. And no traces means that when something breaks across a dozen services, reconstructing *where* it broke is a manual archaeology project: grep by request ID, sort by timestamp, and pray the clocks agree — assuming a correlation ID was ever propagated, which, in a shop that skipped tracing, it wasn't.

I've taken to calling this "Observability 0.4." It isn't even a complete Observability 1.0. One pillar that works, one that's broken, one that's missing.

Here's the interesting part. Observability is a field full of real disagreement — people will argue for hours about cardinality, sampling, schema, where aggregation should happen. Almost nothing gets unanimous agreement. But *everyone* — every camp, every vendor, every philosophy — looks at logs-plus-broken-metrics-and-no-traces and agrees it's wrong. That unanimity is rare, and it's a clue. What they agree is wrong isn't a particular architecture. It's the *absence* of one.

## There is a real argument, and it isn't a war

Step past the 0.4 customer and there's a genuine, interesting disagreement happening among people who know exactly what they're doing.

On one side: the three pillars. Metrics, Logs, and Traces. [Metrics, logs, and traces are different data types](/blog/metrics-logs-traces-events/), so you store each in a system built for it — a time-series database for metrics, a log store for logs, a trace store for traces. Specialize, and let each engine be excellent at one access pattern.

On the other side: one source of truth. Don't scatter the same request across three systems in three formats — capture one arbitrarily-wide, structured event per request, store it in a columnar engine, and *derive* metrics, logs, and traces from it at query time. This is the "observability 2.0" position, and the idea underneath it is genuinely good and worth saying plainly: **schema-on-read.** Metrics make you decide up front what matters and throw the rest away — once a measurement is a counter, you can't go back and ask a question you didn't anticipate. Wide events keep the raw detail and let you ask the question *later*, when you finally know what it is. That's not marketing. That's a real advance.

It's tempting to read this as a war with a winner. It isn't. Both positions are correct. They're built for different jobs — and the jobs only look like one job because we gave them one word.

## Two Observability Loops

Observability does two fundamentally different things, and we call them by the same name.

**The fast observability loop** runs at machine speed. Alert, autoscale, restart, fail over. It runs continuously, it acts in seconds, and no human is in it. Its defining requirement is not analytical power — it's **autonomy**. It has to keep working when things are on fire, which is exactly when the network is flaky, the central systems are saturated, and the thing that's down might *be* your central system. A Prometheus in each cluster, evaluating its own rules, firing its own alerts, and driving its own scaling and recovery with HPA's (Horizontal Pod Autoscalers), VPA's (Vertical Pod Autoscalers), [KEDA](https://keda.sh) (Kubernetes Event Driven Autoscaling) from inside its own blast radius, and and controllers like [CNPG](https://cloudnative-pg.io/) are the canonical shape of this loop. They embody the oldest rule in monitoring: the watcher must fail independently of the watched.

**The slow observability loop** runs at human speed. Something already broke, or someone has a question, and you sit down — minutes, hours, sometimes days later — and interrogate the system to find out what actually happened. The defining fact of this loop is that *you don't know the question in advance*. So it wants the opposite of the fast loop: not many simple independent signals, but one rich, wide, queryable record you can slice any direction the investigation turns. This is where schema-on-read and wide columnar events win outright.

| | Fast loop | Slow loop |
|---|---|---|
| Job | Alert, scale, heal | Investigate, explain |
| Speed | Seconds, no human | Hours, human-driven |
| Defining virtue | Autonomy under partition | Arbitrary query depth |
| Wants | Simple, local, independent signals | One wide, rich, queryable record |
| Built for it | Prometheus / specialized stores | Columnar wide events / "Observability 2.0" |

Look at the two camps again with this in hand. The specialized-stores people are describing the fast loop. The wide-events people are describing the slow loop. The argument feels irreconcilable because each side is *right* — about a different loop. They're not fighting over territory. They're standing in different rooms.

## Why the conversation leans one way

If both loops matter, why does so much of the writing lately lean toward unification and wide events?

Mostly because the loudest voices in any technical conversation tend to be the ones with a product to sell, and the products in this conversation are slow-loop products — a place to send everything and query it later. People write most about what they build and what they're good at. The slow loop is also simply more *interesting* to write about: ad-hoc queries, high cardinality, clever columnar storage. The fast loop is plumbing. It's a Prometheus quietly paging you at 3 a.m. and an autoscaler you never think about. Nobody writes a manifesto about plumbing.

This isn't anyone being dishonest, and products need to be sold so that engineers can afford to keep working. It's just worth knowing that the volume of discourse is not a measure of importance. The loop nobody is writing about is the one keeping the lights on.

## So which is right? Wrong question.

The useful questions are: *which loop are you building for*, and *what is your deployment reality?*

If you run one application in one cloud and you buy your observability as a service, then the slow loop is most of your pain, the fast loop can lean on your vendor, and pouring everything into one queryable store is a perfectly good answer. Send it all to the warehouse.

If you *operate* your own observability across a mix of cloud, on-prem, bare metal, and hybrid, then independent local stores with object-storage durability — a Prometheus per cluster, Thanos or Loki or Tempo backed by S3 — buy you autonomy and portability that nothing centralized can match. The same stack runs on a laptop, in your garage, in a colocation facility, or in a public cloud.

If you *ship* observability into other people's environments — bake it into a product — then it has to survive on infrastructure you don't control, scale across footprints you can't predict, and never assume a central plane exists at all. That pushes you hard toward independent, self-contained, locally-autonomous components.

And most mature shops run *both* loops: local Prometheus for the loop that pages you, wide events for the loop where you figure out why it paged you. That's not indecision. That's matching the tool to the job.

None of these are wrong. They're different answers to "what am I optimizing, and on whose hardware." That is a context decision, not a correctness one.

## One way to get it wrong

Which brings us back to the Observability 0.4 customer — because their mistake was *not* picking the wrong camp.

Metrics in a full-text index is bad at the fast loop: slow, expensive, cardinality-fragile, exactly the wrong thing to lean on during an incident. No traces at all is blind on the slow loop: when you finally sit down to investigate a multi-service failure, the one signal that reconstructs causality simply isn't there. They optimized for *neither* loop. They didn't choose a tool for a job. They found a search engine that was already running and poured everything into it because it was there.

That's the actual error — and it has a name, and the name isn't "specializing" or "unifying." It's **cargo-culting.** Reaching for the familiar tool instead of asking what job you're doing.

## There's more than one way

You can specialize. You can unify. You can — and most should — do both, one loop each. The camps will keep arguing, and they're entitled to, because each is right about the thing it's describing.

The way to tell a right answer from a wrong one was never which camp it came from. It's whether someone, at some point, asked which loop they were building for and chose a tool to fit it.

The Observability 0.4 customer's mistake wasn't taste. It was never asking the question.
