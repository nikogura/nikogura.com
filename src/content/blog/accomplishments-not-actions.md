---
title: "You Are Your Accomplishments, Not Your Actions"
excerpt: "Imperative engineers narrate their work as a string of verbs they perform — I push, I deploy, I run the migration — and when the verb finishes, the sentence is over and they walk away. A declarative system has no such sentence. It has a noun: a desired state a controller holds true forever. The verb feels like control because it makes you the subject, but it's an illusion — your visibility ends the instant the verb exits, and the running system carries on in whatever state it's actually in. Real control isn't starting the action; it's guaranteeing the noun stays true while you sleep — and proving it does. You are your accomplishments, not your actions."
publishDate: 'Nov 21 2026'
tags:
  - Operations
  - GitOps
  - Culture
  - SRE
isFeatured: false
---

I've been training a team out of a habit, and it took me a while to name the habit precisely. They are imperative to the core. They think in pipelines: do this, then do that, print a green checkmark, walk away. Point them at a pull-based reconciler — Flux holding a cluster to what's in git, a Kubernetes Job that *converges* a schema instead of a script that *mutates* one — and the whole model feels wrong to them, because it doesn't match the sentence they say in their heads about their own work.

The sentence is the problem. And the cleanest way I've found to name it is grammatical: they think in **verbs**, and the system runs on **nouns**. Your actions are verbs. Your accomplishments — the only part anyone downstream ever sees — are nouns. Confuse the two, and everything downstream breaks.

An imperative engineer narrates the job as a string of verbs they perform. *I push the image. I run the pipeline. I apply the manifest. I execute the migration.* Each verb is a thing they do, and when the verb completes — exit code 0, green text — the sentence is over. A declarative system has no such sentence. It has a **noun**: a desired state, declared once, that a controller holds true forever. Nobody *does* anything to the cluster. The cluster simply *is* what git says, continuously, whether or not anyone is at the keyboard.

My engineers hear "declarative" and think it means "I described the state in a file." It means far more than that: [a system is continuously ensuring reality matches the declaration](/blog/gitops). The declaration is the noun. The enforcement is not your verb — it belongs to the reconciler, and it never stops.

And none of this is really about the tooling. That's the part I keep having to say out loud. You can hand a verb-thinker Flux and they will build something imperative and fragile with it anyway — reach for the sync button, bolt retries onto a reconciler that already retries, wrap the whole thing in a push pipeline so it feels like something they *did*. The tool is downstream of the mind. This is a difference in **thinking** before it is a difference in anything you can install, and no tool converts a mind that is still narrating its work as a verb. You have to change the sentence first.

## Verbs Feel Like Control

Here is why the verb is so hard to give up: **it feels like control.**

When you think in verbs — *I am pushing this, I am running that* — you get a hit of agency. You are the subject of the sentence. You pulled the lever, you pressed the button, you watched the console spit fire, and you did a thing. That feeling is real, and it is almost entirely a lie. In a distributed system, your "control" lasts exactly as long as the verb does. The instant your pipeline exits, your visibility ends and the running system carries on without you, in whatever state it's actually in — which you no longer know, because the verb that gave you the feeling of control also told you the job was done.

You can diagnose verb-thinking by the tell that comes right after the green checkmark: someone opens a dashboard, runs `kubectl get pods`, pings a channel — *did it actually work?* If the verb had delivered control, nobody would need to go check. The check is the confession. The sentence said "I deployed it"; reality hadn't agreed yet.

## There Are Two Verbs

Now, a reader of [my other writing](/blog/running-a-system-not-writing-code) should be squinting, because I've spent a lot of words insisting the right mindset is a verb — *running* a system, not *writing* the code. So which is it? Is the verb the trap or the goal?

Both — because there are two different verbs, and the whole mistake is confusing them.

The first is the human's verb: transitive, terminating, past tense. *I pushed. I deployed. I ran the migration.* It takes an object, it completes, and the moment it completes it is finished — you walk away from it the way you walk away from a sentence you've finished saying. This is the verb of the imperative thinker, and it is the trap, because a distributed system has no past tense. It does not care what you *did*. It has only a present-tense state, right now, that is either converging on what you declared or drifting away from it.

The second is the system's verb: intransitive, continuous, present tense, forever. *It reconciles. It converges. It holds.* No object, no completion, no walking away. This is the verb in "I am running a system" — not an action I perform and finish, but an ongoing relationship I maintain with a living thing. It is the verb a reconciler speaks, and the only tense it knows is *now*.

So the rule isn't "nouns good, verbs bad." It's this: **declare the noun, and let the continuous verb belong to the system, not to you.** You change the map of what should be true. The reconciler does the tireless present-tense work of making reality match the map — the work you were never actually doing when you thought your push was control. You were doing a terminating verb and calling it stewardship.

## Nothing Holds Still Between Your Verbs

There's a deeper bug under the verb, and it's grammatical too: the imperative sentence puts **you** in the subject slot and treats the running system as, at most, the object of your action — the thing you push *to*, deploy *at*, apply *against*. The system is a direct object, acted upon and then dropped.

But the running system is not the object of your sentence. It's the subject of its own. It is doing things — serving, failing, drifting, filling its disks with logs — the entire time, on its own schedule, narrated by nobody. When you think only in verbs you perform, you are quietly assuming the system holds still between your actions, inert, waiting for the next thing you do to it. It doesn't. [Infrastructure is stateful, singular, and alive](/blog/infrastructure-is-not-an-application); it moves whether or not you're touching it. The verb-thinker is perpetually blindsided by this — someone hand-patches a replica count during an incident, a push three weeks later silently wipes the patch, the app falls over, and the team treats it as a supernatural event rather than the obvious consequence of narrating a living system as if it only moved when they spoke.

This is what the old Schlock Mercenary maxim is really about. *Fire and forget is fine, provided you don't actually forget.* The verb-thinker always forgets, because the grammar tells them to: the sentence ended at the green checkmark, so attention ends there too. The only way to *not* forget, in a system too big and too fast to babysit, is to stop being the one who has to remember — to [delegate the remembering to a controller](/blog/gitops) that never finishes its sentence, never closes its terminal, and never walks away.

## Control Is Guaranteeing the Noun, Not Starting the Verb

The breakthrough — when it comes — is a redefinition of control.

To the imperative mind, control means *I can start the action.* I have the button; I can fire. But starting an action in a distributed system guarantees nothing about its outcome, which is exactly why the verb-thinker spends their life adding more verbs: a `sleep 10` here, a retry loop there, error-handling bolted onto error-handling — a fragile tower of steps trying to reconstruct, one brittle command at a time, the single thing they threw away the moment they chose the verb. A guarantee about the state.

Real control is the opposite. It isn't being able to start the action; it's the system **guaranteeing the outcome** whether you act or not. A thermostat has it and a space heater on a timer doesn't. *Run the heater for twenty minutes* is a verb — it executes blindly, and if the room is already an oven or a window's open, too bad, the verb ran. *Hold the room at seventy-two* is a noun held true by a loop — it measures reality against the target and corrects, indefinitely, without you. One gives you the feeling of having done something. The other gives you a warm room at 3 a.m. while you're asleep and doing nothing at all.

That is the trade the verb-thinker is terrified of, because it reads as *giving up the steering wheel.* It isn't. Handing a continuous controller the nouns is how you get, for the first time, a guarantee you never actually had while you were frantically steering — that what's in git is what's running, or alarms are sounding. You give up the *feeling* of control to get the real thing.

## The Process Monkey Serves the Method, Not the Result

There's a degenerate form of verb-thinking that's worse than anything above, because the person doesn't even own their verbs. They borrow them. They do what they're told — the ticket, the checklist, the runbook, the process — and they execute those borrowed steps with total devotion and zero reference to whether the steps are producing the result. They are serving the *process*, not the *goal*. And the process is a verb. The goal is a noun.

An actual person inspired this diatribe. They didn't fail to follow directions, exactly — they slavishly followed their own *misreading* of the directions, over and over, despite multiple clarifying conversations, producing the same broken output each time, and then handed it off to the next person as though the handoff were the finish line. The process was observed to the letter. The result was garbage. And when you pointed at the garbage, the answer was, in effect, "I did what the ticket said." That is not an accident or a skills gap. It is a stance — a passive-aggressive devotion to process that quietly screams *I don't care about the result, and you can't blame me for it.* Compliance as a weapon. The checklist as an alibi.

Dick Marcinko put the counter-principle about as bluntly as it can be put, in his Ten Commandments of SpecWar in *Rogue Warrior*: **"Thou shalt not be paid for thy methods, but for thy results."** I don't care about the steps you took to get there. I'm not interested in the orders you followed, the tickets you closed, or the boxes you ticked. I'm interested in the result — the running system, the noun — and no action you take *necessarily* gets you there, no matter how faithfully you perform it. The checklist is a proxy for the goal, and [like a spec, a proxy is never complete](/blog/running-a-system-not-writing-code). Follow it perfectly and you can still miss, because the map was never the territory. The person who confuses executing the method with achieving the result has mistaken the verb for the noun in the most total way available — and made a virtue of it.

Now the objection this always provokes, so let me kill it here: *so the ends justify the means?* *So a clever one-off hack counts, and the 3 a.m. heroic save is the whole point?* No — and that objection only lands if you let "result" quietly shrink to mean "it worked, once, somehow." It doesn't mean that. The result I'm demanding is a far *higher* bar than any corner-cutting means can clear, and a hack and a hero both fail it on their face. A one-off fix that holds until someone breathes on it isn't a result; it's a pet nobody can reproduce. A [heroic manual intervention](/blog/stop-holding-out-for-a-hero) that only stands up while the hero is awake and watching isn't a result; it's a [load-bearing human](/blog/load-bearing-humans) in a cape. The work is not done — the noun is not true — until it is [reproducible, autonomous, and continuously reconciling](/blog/ddcri): demonstrably working, and proving it's working, with nobody holding it up by hand. That standard is exactly what a cut corner cannot produce, which is why results-thinking, taken honestly, is the strictest master you will ever answer to, not a loophole. You don't get credit for the outcome. You get credit for the *durable, self-sustaining, provable* outcome — and nothing short of it counts.

## "Done" Is a Claim You Have to Prove

Say you clear that bar — you actually care about the result, you're aiming at the noun and not the checklist. You're still not finished, because the noun makes one more demand the verb never does: the running system doesn't just have to be running. It has to be running *continuously*, and provably so — not up at the instant you looked, but demonstrably still up now.

This is the question that separates the two mindsets at the finish line. You think it's up. Fine — *how do you know?* You believe the deploy worked. *Prove it.* Not "the pipeline went green," not "I followed the runbook," not "it worked on my machine" — prove that the system is, right now, doing its actual job, correctly, for the people who depend on it. The verb-thinker has no answer, because the verb exited successfully and that was the whole of their evidence. The green checkmark certified that the *action* completed. It certified nothing about the *state.*

This is the entire reason [observability, telemetry, monitoring, and dashboards exist](/blog/metrics-logs-traces-events), and why they are never optional. They aren't decoration, and they aren't a nice-to-have you bolt on if there's time. They are the apparatus by which you *prove the noun* — the only way to turn "I think it's running" into "I can show you it's running, continuously, and I'll know within seconds when it stops." [A 200 with a broken payload is a failure](/blog/continuous-acceptance-tests), and the only way you ever learn that is by asserting the result and watching the assertion, forever, in production. Without it, "done" is not a fact. It's a feeling you had at the moment you walked away.

So when you call something done, ask what assurance you actually created that it *is* done. Will the next engineer, the next client, the next system that consumes yours be able to use it to do *their* job? Or did you tick some imperative actions off a checklist, generate a green light that proves only that you performed the steps, and leave? One of those is finishing the work. The other is performing the appearance of finishing it — and the difference stays invisible right up until someone downstream reaches for the result you never actually verified.

## It Isn't Only Infrastructure

I came at this through infrastructure, but the grammar is the same everywhere I look.

[The whole "running a system, not writing code" shift](/blog/running-a-system-not-writing-code) is this sentence one level up: "I write code" is a terminating verb — produce the diff, merge it, done — and "I run a system" is the continuous one. [The climb from automated to autonomous](/blog/manual-automated-autonomous) is the same move again: an open loop is a verb you fire and forget; a closed loop is a noun a system holds. Even management runs on it — a manager who leads by issuing verbs (*do this, ship that*) and walking away is running a push pipeline against people, and is just as blind to the real state of the humans as the push-deployer is to the cluster.

And it matters more now than it used to, for the same reason everything in this corner of my writing matters more now: when the verbs get cheap — when a model will generate the pipeline step, the manifest, the migration, the diff faster than you can type them — the typing was never the job. [What's left when the verb is free](/blog/running-a-system-not-writing-code) is the noun: deciding what *correct* means, declaring it, owning the loop that holds reality to it, and proving it holds. The engineer whose entire identity was a verb they performed is about to watch that verb get automated out from under them. The one who was tending a noun still has a job, because no machine was handed the state.

The process monkey is the purest case. By reducing themselves to a faithful executor of defined steps — do what the ticket says, run the checklist, hand it off — they wrote their own job description as a function: steps in, actions out, no judgment, no responsibility for the result. That is exactly the function a machine performs, and the machine performs it faster, cheaper, and without the passive-aggression. They didn't just do a bad job. They [described their own replacement](/blog/people-are-not-cattle) in precise detail, and then volunteered for it.

## Declare the Noun

So the thing I'm actually trying to teach, under all the tooling, is a change of grammar. Stop narrating your work as a verb you perform and finish. You are not your actions — not the push, not the closed ticket, not the steps you followed or the boxes you ticked. Nobody downstream will ever experience a single one of them. They experience the running system, and you are worth exactly what it does and what you can prove it does. You are your accomplishments, not your actions.

Declare the noun. Change the map of what should be true, review the change where it can still be read, hand the tireless, present-tense, never-finished verb to a system built to never walk away — and instrument it so you can prove, at any hour, that it's holding. Do that, and you can finally go to sleep. The loop doesn't need you to remember, and the telemetry doesn't need you awake to keep watch. That was the whole point.
