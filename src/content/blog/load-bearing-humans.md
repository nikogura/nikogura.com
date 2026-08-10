---
title: 'Load-Bearing Humans'
excerpt: "A system that only keeps running because a person is continuously holding it up is not working. The person is working. The system is on life support. 'Working' is one more overloaded word, and most of the time it quietly means 'works as long as the right human is standing there.'"
publishDate: 'Aug 10 2026'
tags:
  - Philosophy
  - Engineering
  - Operations
  - Reliability
isFeatured: true
---

## The Word Is Doing Too Much Work

I have [written before](/blog/can-vs-does) that "[can](/blog/can-vs-does)" and "done" are overloaded words that smuggle in assumptions and then let us skip the part where we check them. "Working" is another one. Maybe the worst one.

Someone says the system is "working," and it sounds like a property of the system. It usually isn't. Pull on it and most of the time "working" turns out to mean *works as long as the right person is standing there.* Works as long as Dave runs the morning script. Works as long as somebody remembers to restart the thing on Tuesdays. Works as long as the one person who understands the deploy is not on vacation. That is not a working system. That is a person, working, in a costume shaped like a system.

This is the companion to the point I made about [nice people who give us money](/blog/nice-people-who-give-us-money): a thing is not "done" or "working" just because it produced the right answer once while you watched. That post measured "working" at the customer. This one measures it somewhere else — at *you*. Because there is a second definition of "working" that we dodge just as hard, and it is this: a system is working when it runs without a human holding it up. If it needs you, it isn't working. It's on life support, and you are the machine breathing for it.

## The Load-Bearing Human

A load-bearing wall holds the building up. Remove it and the building comes down. That is fine, because it is on the blueprint. Everyone knows it is structural. Nobody hangs a whiteboard on it and nobody schedules it a vacation.

A load-bearing human is the same thing, with three differences that make it far worse: they are not on the blueprint, you usually cannot see that they are structural until they are gone, and — unlike a wall — they get tired, they take PTO, and eventually they leave. The system stays up because they are, quietly and continuously, holding it up. Cron never fired reliably, so they check it by hand every morning. The alerting is noisy, so they mentally filter it. The deploy has an undocumented step, so they just *know* to do it. None of this is written down, because to them it is not a procedure. It is a habit. It is Tuesday.

From a distance the system looks like it is working. It produces outputs. Customers are served. The dashboards are green. And the entire time, a person is standing inside the wall being structural, and no one has noticed, because the wall has always been there and the wall has always been fine.

Then the wall gets a better offer.

## Toil Is Not Operation

The SRE discipline has a precise word for the labor a load-bearing human performs: **toil.** Work that is manual, repetitive, automatable, devoid of enduring value, and — the killer — it scales linearly with the size of the thing it supports. Twice the traffic, twice the hand-cranking. It is not the *design* of the system and it is not the *improvement* of the system. It is the continuous manual effort required just to keep the system in the state it is supposed to hold on its own.

Here is the distinction people miss. A generator you have to hand-crank is not powering the house. *You* are powering the house, through a generator. The generator is a very expensive handle. When you stop cranking, the lights go out — which tells you exactly where the power was actually coming from. A system that requires continuous toil to stay in its correct state is that generator. It is not running. It is being *run*, by hand, by a person who cannot stop.

This is a different failure from the one I wrote about in [Stop Holding Out for a Hero](/blog/stop-holding-out-for-a-hero). That was about the *emergency* — the 3 AM page, the incident where response capability lives in one person's head. This is the quieter, more constant cousin: not the emergency, the *Tuesday.* Not "who saves us when it breaks," but "who is keeping it from breaking, all day, every day, by doing the same manual thing over and over." The hero problem is about the night everything goes wrong. The toil problem is about every ordinary morning, when nothing is wrong and a human is still required for the system to simply *be what it already claims to be.*

Both come from the same root, and it is the same one I keep circling back to: the human is a [load-bearing component of the runtime](/blog/gambling-on-failure), and the human is the least reliable component you have. Tired, busy, distracted, mortal, and — critically — *elsewhere*, eventually.

## Shadow IT Is a System Pretending to Be a Habit

The purest, most concentrated form of the load-bearing human is Shadow IT.

The spreadsheet that actually runs payroll. The personal script on someone's laptop that the whole release secretly depends on. The Slack message you have to send in the right channel in the right format or the downstream job never fires. The undocumented DNS entry that one person set up and only that person remembers exists. Every one of these is a real, production, business-critical system — with no owner, no documentation, no monitoring, no backup, no review, and no redundancy. It is [invisible infrastructure](/blog/documentation), and it is holding up things that matter.

It "works." Of course it works — that is exactly why it is dangerous. It works right up until the laptop dies, the person leaves, the spreadsheet gets a stray edit, or the one human who knew the ritual is on a plane. Shadow IT is not a shortcut that saves you effort. It is a system that has disguised itself as a person's private habit specifically so that nobody has to treat it like the critical infrastructure it actually is. The disguise is the whole problem. You cannot monitor, back up, harden, or replace a thing you have all agreed to pretend is not really there.

And it does not stay small. Shadow IT breeds, because every load-bearing habit that works becomes the load-bearing habit the *next* workaround is built on top of. You end up with a real architecture — a critical one — that exists nowhere except in the muscle memory of a handful of people and the cells of a spreadsheet nobody dares touch.

## Convention Is Not Enforcement

There is a softer version of this that even good teams fall into, and it hides behind a respectable word: *convention.*

"We always name the branches this way." "We always run the migration before the deploy." "We always tag the release before we cut it." A convention is a rule enforced by human memory, and human memory is the [component that fails first under load](/blog/can-vs-does). A convention that must be remembered is a convention that will, eventually, be forgotten — not because your people are careless, but because it is 2 AM, the pager is loud, the runbook is twelve pages, and they are taking the shortest path like every tired human always has. If correctness depends on everyone remembering the convention every single time, then the humans are the enforcement mechanism, continuously, forever. The system does not guarantee correctness. It *hopes* for it, and delegates the hoping to people.

A convention that matters should not be a folk custom the team performs. It should be a constraint the machine enforces — a check that fails the build, a hook that refuses the merge, a [reconciler that will not let the state drift](/blog/ddcri). Move the rule out of human memory and into the system, and you have removed a load-bearing human. Leave it as a convention, and you have hired everyone on the team, in perpetuity, to be that human on rotation.

And watch for the tell: *frustration.* When people are constantly, grindingly annoyed by the same manual dance — the same fiddly steps, the same "oh, you have to remember to…," the same convoluted process everyone privately hates — that frustration is not a personality trait or a fact of life. It is a signal. It is the system telling you, through the mouths of the people trapped inside it, that a human is doing a job the machine should be doing. Frustration is toil with a voice. Listen to it.

## "Working" Means It Runs Without You

So here is the definition I actually use, the one that survives contact with a vacation.

A system is working when it runs, heals, and stays correct through normal operation with no human in the loop. Humans should *design* the system, *change* the system, and *improve* the system. Humans should not *be* the system. The moment a person is a required, continuous, load-bearing part of steady-state operation, you do not have a working system — you have a job that has learned to impersonate one.

The test is simple, and slightly terrifying the first time you run it honestly: go on vacation. Turn off your phone. If the system keeps making [nice people happy](/blog/nice-people-who-give-us-money) while you are unreachable on a beach — reconciling itself, healing itself, refusing to drift, holding its own correctness without you — then it is working. If it needs you back within a day, it was never working. You were. A car that only starts when you are under the hood with a screwdriver is not a working car. It is a project that occasionally moves.

This is the same discipline as [betting on failure](/blog/gambling-on-failure), pointed inward. You assume you will be tired, distracted, asleep, or gone — because you will be — and you build so the system does not need the version of you that is fresh, present, and paying attention. You make the machine hold itself up, so the human is free to go do the thing only a human can do: build the next one.

## The Point

"Working" is one more overloaded word, and most of the time it quietly means "works as long as the right human is standing there." That is not a system. That is a performance, and someone has to keep giving it, forever, or the lights go out.

Load-bearing humans, toil, Shadow IT, correctness that depends on everybody remembering the convention — these are all the same thing wearing different clothes: a person doing a job the system should be doing, mistaken for the system doing its job. It looks like it is working right up until the person stops, and then you find out where the "working" was actually coming from.

Build systems that do not need you. Not because you are lazy — because a system that does not need you is the only kind that is actually finished, actually reliable, and actually yours instead of a hostage situation with your own weekends. If you cannot walk away from it, it is not working. It is holding *you*, and calling it a system.
