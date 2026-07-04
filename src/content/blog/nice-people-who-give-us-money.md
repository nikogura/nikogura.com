---
title: 'Nice People Who Give Us Money'
excerpt: "We are not paid to solve interesting engineering problems. We are paid to make products that make customers happy, and a customer is a nice person who gives us money. Under that definition, monitoring, testing, deployment, security, and resilience are not 'non-functional requirements.' They are the function."
publishDate: 'Jul 04 2026'
tags:
  - Philosophy
  - Engineering
  - Reliability
isFeatured: true
---

## The Seduction of the Interesting Problem

Engineers love a puzzle. It is most of why we got into this. There is a specific pleasure in a hard, well-formed technical problem — a gnarly race condition, a distributed consensus edge case, a data structure that has to be exactly right — and the pleasure is real. I feel it too. Decades in, and a good problem still lights me up.

But the puzzle is not the job. It has never been the job.

We are not paid to solve interesting engineering problems. We are paid to make products. Products are things that make customers happy enough to hand us money and keep handing us money. The interesting problems are something we sometimes get to solve *on the way* to doing the actual job — they are the scenery, not the destination. Confusing the two is the single most expensive mistake a technical person can make, and almost all of us make it.

You can tell it is happening when the conversation is about the elegance of the solution and not the state of the customer. When the architecture review spends an hour on the message bus and zero minutes on whether anyone will be happier because it exists. When "this is a really cool use of X" is offered as a justification. Cool is not a business outcome. Cool has never once shown up on a P&L.

The [complexity ratchet](/blog/can-vs-does) turns partly because complexity is *interesting*. A new service is a new toy. A new database is a new toy. The service mesh is a very expensive, very interesting toy. Each one is a bet against reliability, and we place the bet because the puzzle is fun, and then we tell ourselves a story about why the customer needed it. The customer did not need it. The customer needed to be happy.

## Who the Customer Actually Is

I have a deliberately unsentimental definition of a customer: **a nice person who gives us money.**

That is the whole thing. Strip away the personas, the funnels, the segments, the TAM slides. On the other end of everything you build is a person who, if you do your job, decides you are worth paying — and, more importantly, decides you are *still* worth paying next month. They are nice. They chose you. They are, right now, giving you money, which is an act of trust most people undervalue precisely because it is quiet and continuous. Nobody sends a thank-you card for a renewal.

Everything an engineering organization exists to do collapses back to that person. Revenue is nice people giving you money. Growth is more nice people giving you money. Retention is the same nice people continuing to give you money instead of stopping. Every metric on the board is a proxy for the mood of a person you will probably never meet.

Once you hold that definition steady, a lot of arguments end quickly. "Should we spend a sprint on reliability or on features?" is not a real dilemma once you ask which one keeps more nice people giving you money. "Is security worth the friction?" answers itself the moment you remember what a breach does to a nice person's willingness to keep trusting you with their money and their data. The customer is not an abstraction to be optimized around. The customer is a person whose happiness is the only score that counts.

## "Working" Is Not a Property of Your Code

Here is where the vocabulary betrays us, the same way "[can](/blog/can-vs-does)" betrays us.

An engineer says a thing "works." What they almost always mean is: it produced the correct output, once, in an environment they controlled, at a moment they were watching. It worked on their laptop. It worked in the demo. It passed CI. The deploy went green. Every one of those is a statement about the *code* at a single instant, and not one of them is a statement about a customer being happy.

"Working" is not a property of your code. It is a property of your customer's experience, sustained over time. The code is an input. The customer's happiness is the output, and the output is the only thing anyone is paying for.

This is exactly why a `200 OK` with a broken body is a [failed deployment](/blog/continuous-acceptance-tests), not a successful one. The status code is a fact about your server. The empty catalog behind it is a fact about your customer staring at a blank screen, deciding whether you are still worth the money. The server "worked." The product did not. Those are different claims, and only one of them pays the bills. "Working" has to be measured at the customer, continuously, or it is not measuring anything that matters — because [acceptance is a condition, not an event](/blog/continuous-acceptance-tests), and so is happiness.

## The Lie Hidden in "Non-Functional Requirements"

Somewhere along the line the industry decided that reliability, performance, security, observability, and deployability were "non-functional requirements." The phrase is a catastrophe. It is three words that quietly demote everything that actually keeps customers paying you into an optional garnish on top of the "real" work.

Read it literally. *Non-functional.* As in: not the function. As in: nice to have, once the important stuff is done. The naming tells engineers, product managers, and executives alike that these are the things you cut when the deadline gets close. They are the first to be descoped precisely because we labeled them as not-the-point.

So let me relabel them, because the label is wrong.

If the system is down, the customer is not happy. That is a functional failure. The function of the product is to make the customer happy, and right now it is doing the opposite. It does not matter that the code is correct — the customer cannot reach the correct code, so from where they sit there is no product at all. Reliability is not non-functional. Reliability *is* the function, expressed as uptime.

If you cannot ship a fix quickly, the customer stays unhappy longer. A bug you can fix in an hour and a bug you can fix in three weeks are the same bug to your engineers and completely different products to your customer. Deployability — [trunk-based flow](/blog/trunk-based-development), fast safe releases, [reconciled and self-healing infrastructure](/blog/ddcri) — is not operational hygiene you get to someday. It is the speed at which you are allowed to stop disappointing people. That is about as functional as a requirement gets.

If the system is breached, you have taken the one thing the nice person trusted you with — their money, their data, their confidence — and lost it. There is no more functional failure than that. [Security is not a bolt-on](/blog/security-is-infrastructure); it is the ongoing promise that keeps the "nice" in "nice people who give us money." Break it and the money leaves with the niceness.

And if you cannot *see* what the customer is experiencing, you are flying blind over the only terrain that matters. Observability — metrics, logs, traces, and [events](/blog/metrics-logs-traces-events) — is not telemetry for its own sake. It is the only way you find out a customer is unhappy before they find out first and leave. Every one of these is functional. Every one of them is the product doing, or failing to do, its actual job. The word "non-functional" should be retired with prejudice.

## Delight Does Not Ship. It Persists.

There is a companion lie to "non-functional," and it is the word "done."

"Done" sounds like a milestone. A date. A ticket that moves to the last column and stops. But customer happiness is not a milestone — it is a live value that decays the moment you stop feeding it. The feature you shipped last quarter is not "done" delighting anyone; it is either still delighting them right now, this second, or it has quietly rotted while you were looking at the next thing. Data [rots](/blog/continuous-acceptance-tests). Dependencies drift. Latency creeps. A competitor raises the floor. The customer's happiness is not a thing you achieved. It is a thing you are either sustaining or losing, continuously, forever.

This is why I [bet on failure](/blog/gambling-on-failure) rather than success. If the definition of "working" is "the customer is happy right now, and will still be happy at 3 AM on a Sunday when an upstream I don't control ships a breaking change," then I cannot build for the happy path and call it done. I have to build for the day it breaks — because that day is coming, and on that day the customer does not care how interesting my architecture was. They care whether they are still getting what they paid for.

So there is no "done." There is only "still working," which is a claim you have to keep re-earning every minute the service is up. The moment you treat delight as a finished artifact instead of a running condition, it starts to decay, and the customer feels it long before your dashboards do — unless you built the dashboards to watch the customer instead of the server.

## The Point

We are not here to solve interesting engineering problems. We *get* to solve interesting engineering problems, sometimes, as a perk of the actual work. The actual work is nice people who give us money, and keeping them nice, and keeping them paying, by making a product that makes them measurably happier tomorrow than it did today.

Every time you are tempted to call something "done" or "working," run it through the only test that means anything: is there a nice person, right now, who is happier because of it — and will they still be happy the next time I am not watching? If you cannot answer yes, it is not done and it is not working, no matter how green the pipeline is or how elegant the code.

Reliability, security, observability, deployability — these were never non-functional. They are the difference between a product and a demo. A demo makes a person happy once, on your day, while you are standing there. A product makes nice people happy over and over, on their worst day, while you are asleep. Only one of those gets you the money. Only one of those was ever the job.
