---
title: "People Are Not Cattle"
excerpt: "The 'replaceable cog' theory of management is the cattle model applied to humans — interchangeable, nameless, swap any one for another. It's true exactly as far as the work is a stateless, commodity replica. Your best people are not. They carry state you cannot reproduce — context, judgment, relationships, the undocumented why — which makes them pets, not cattle. Treat a pet like cattle and two things happen: you discover the replacement was never interchangeable, and, because this particular pet is self-aware and can quit, it notices first. And the cruel twist: the commodity work is exactly the work automation takes."
publishDate: 'Nov 06 2026'
tags:
  - Management
  - Hiring
  - Culture
  - AI
isFeatured: false
---

I [wrote recently that infrastructure is not an application](/blog/infrastructure-is-not-an-application): an application is a stateless, disposable artifact you stamp out in identical copies, and infrastructure is a stateful, singular thing you cannot duplicate because you cannot reproduce all of its state. The whole post is about what breaks when you forget which one you're holding.

The same asymmetry runs straight through how we manage the people who run the infrastructure. And we forget which one we're holding there too.

## The Cog Idea Presupposes You Have Cattle

There's a dichotomy ops people use for servers: *pets versus cattle.* A pet is a machine you name, tend, and mourn — if it dies, you're in trouble, because there's only one. Cattle are interchangeable: numbered, not named, and if one falls over you shoot it and the herd doesn't notice. "Treat your servers like cattle, not pets" is good advice *for servers* — stateless, reproducible ones, anyway.

The "employees are replaceable cogs" theory of management is that same cattle promise applied to people. Headcount is a herd. A role is a slot. A person is whoever currently fills the slot, and if they leave you hire another and the machine runs on. Expressed politely, the theory sounds like resilience — "no one is irreplaceable," "we don't want single points of failure." Expressed honestly, it's: every person is an interchangeable replica, and the org is a pile of identical units.

And like the cattle model for servers, the cog idea is true — *only insofar as the work is a stateless, commodity replica.* Some work genuinely is. Context-free, well-specified, learnable in a week, carrying nothing that doesn't fit in the job description. For that work, the herd model is correct and humane; nobody should be a load-bearing pet for a task that's genuinely interchangeable. In a pinch, you can hire contractors and interns for that work.

The error is assuming *all work* is commodity — and therefore that all your people are commodities too.

## Your Stars Carry State You Can't Reproduce

Your best people are not stateless replicas. They are the pets.

A star performer isn't holding a job description — they're holding irreproducible state. The accumulated why-it's-like-this. The map of who actually decides things versus who's on the org chart. The thousand small judgment calls that never got written down because they happened in the moment and were obviously right. The relationships that make a cross-team ask take an hour instead of a sprint. The scar tissue from the last three outages that tells them, instantly, which explanation of a weird symptom is worth chasing.

None of that is in the job description. The JD says "Senior Engineer." The person holds a decade of compiled context that the JD cannot describe and a replacement cannot inherit. You can hire the title back in an afternoon. You cannot hire the *state* back at all — it accretes, in one specific head, over years, and it leaves when the head does. That is the precise definition of a pet: singular, stateful, and not reproducible from a spec.

## Star Status Comes from a Track Record, Not a Title or Time in Station

A very important thing to note here: The irreproducible state that makes someone a star you cannot afford to lose is **judgment that keeps producing demonstrably correct decisions and designs** — the reliable act of being right about hard, ambiguous calls where the answer wasn't lying around to be looked up. Not stored knowledge; knowledge is reproducible, and we can watch machines prove it every day. The judgment that *generates* the right answer to a problem nobody has solved yet is priceless.

The operative word is *demonstrably*, and it rules out the two things people most often mistake for judgment. This is not the one person you've let decide everything — a decider by fiat holds a title you granted, not state they own, and you can hand that title to someone else tomorrow. And it is not the loudest or most senior voice in the room. Real judgment leaves a **track record**: a trail of calls that turned out right, designs that scaled instead of buckling, bets that paid, systems still standing and still maintainable years after they shipped. Judgment is reproducible in its *outcomes* — the wins keep coming, across different and unrelated problems — precisely because it is *not* reproducible in its source. You cannot copy the thing in their head that keeps producing them.

That test cuts in every direction. It's how you tell a star from a hoarder, and equally how you tell a star from a bully: the hoarder withholds reproducible knowledge and calls it mastery; the bully turns a title into the right to be the bottleneck on every decision and calls it judgment. Neither one owns the asset. The star is the one whose record of successful, scalable, reproducible wins would convince a skeptic who doesn't report to them — the one you'd back on the next hard call because they earned it on the last ten, not because of where they sit.

## The Pet That Can Quit

The management version of this mistake is worse than the ops version, in several ways.

First, same as infrastructure: treat your people like cattle and you'll reach, one day, for an interchangeable replacement that was never interchangeable — and find out the hard way, during the equivalent of an incident, that the person you failed to recognize was the one holding the herd together.

Second — and this is the part servers don't do — the state is *self-aware.* A pet server doesn't know you've decided to treat it like cattle. A person does. Treat someone who's carrying irreproducible state like a numbered unit — deny that their context is real, price them as a slot, manage them as interchangeable — and they notice before you do. Then they leave *on their own schedule,* which is always the worst possible one for you, and they take the entire uncommitted state with them out the door. The cog model doesn't just misjudge your stars. It actively manufactures the departure it claims to be insured against.

Third — when your cattle move on, you'll be getting exactly what you deserve. Do you really want employees who are so lacking in self-esteem or self-awareness that they're willing to put up with this? You're **creating** an adversarial relationship. Do this, and you should not be surprised when it comes back to bite you someplace tender — like your bottom line.

## This Is Not an Excuse to "Hoard Heroes"

The obvious objection: didn't I argue the opposite? I've written hard against [load-bearing humans](/blog/load-bearing-humans) and [holding out for a hero](/blog/stop-holding-out-for-a-hero) — the person who is the only one who can deploy on Fridays, the tribal-knowledge bottleneck nobody can go on vacation around. Those are real failures, and they're failures of *under*-reproducing state, not over-valuing it.

The two are the same project, not opposite ones. The job is to **reproduce every bit of state that can be reproduced** — write it down, automate it, make the cattle-izable parts genuinely interchangeable — *precisely so* the person is freed from being a single point of failure for commodity work, and freed to spend themselves on the part that genuinely can't be duplicated. Skip this, and your 'wizards' tire and move on to more interesting work. You externalize the mechanical state to protect the irreproducible state, not to pretend it doesn't exist.

Sadly, some people do this on purpose. They attempt to *manufacture* pet-status by hoarding — refusing to document, keeping the runbook in their head, arranging things so the deploy only works when they're in the room. It looks like irreproducible state and is its exact opposite: reproducible state being *withheld.* The knowledge would fit on a wiki page; they've simply decided not to write it, because the gap *feels like* their job security. That isn't a pet — or a hero. It's a cog cosplaying as one — and it's a thing to stamp out, not protect. Document around them, automate the hostage task, break the artificial scarcity, and treat withholding reproducible knowledge as the performance problem it is, not the moat they think it is.

One of my martial arts teachers used to say *the only secrets in martial arts are the things you don't know yet* — his point being that a secret is never mystical; behind every one is simply a teacher hoarding what they could have shared. A hoarded runbook is the same move in different clothes: a manufactured secret dressed up as mastery. But mastery is reproducible by definition — a real teacher's whole job is to copy their knowledge into the student until the student can do it on their own — and the one who refuses to do so is guarding a position, not a craft.

The test cuts clean, and you run it by *writing everything down* and *keeping the docs up to date*. Real pet-state survives the exercise: document everything a genuine star knows and they are still invaluable, because their value was never the stored facts — it's the judgment that keeps producing new correct decisions no wiki will ever hold. Fake pet-state evaporates the moment it's on the page, because it was only ever commodity knowledge, withheld. So write it all down. What's still standing afterward is your real irreproducible state; what vanished was a lie that was costing you a vacation nobody could take.

And the moat is draining on its own now. Hoarded knowledge was always just undocumented reproducible state — but reproducing it used to take a motivated human with time and energy. Not anymore. Point an AI at the source and it reconstructs the mechanics faster than the hoarder could dictate them; where there's no source, decompilation is close to trivial. This lands exactly where the rest of this is going: AI dissolves the hoarder's moat *because* what they were hoarding was commodity knowledge — reproducible by definition, and now reproducible by machine — while it leaves genuine judgment untouched, for the same reason. The hoard was never a moat. It was a bet that extraction stays expensive, and that bet just lost.

Two opposite errors bracket the correct middle. The hoarder — whether by neglect or by design — never externalizes the mechanical part, so ordinary work becomes hostage to one person. The cog theorist denies there *is* an irreproducible part, so the irreplaceable judgment gets priced and managed as though it were a slot. One makes commodity work fragile; the other throws away the non-commodity value. The fix for both is the same: know which state is reproducible, reproduce that ruthlessly, and treat what's left as precious — because it is, in fact, *priceless*.

## The Cruel Twist: The Herd's Work Is the Automatable Work

Here's where this idea becomes more than an essay — it's a *warning*.

The commodity work — the stateless, context-free, reproducible-from-a-spec work — and the *automatable* work are the same set. "Interchangeable replica with no irreproducible state" is just a description of a task waiting for a script, and now a model, to do it. AI is a cattle-producing machine: it is superb at precisely the work that was always the herd's, and it cannot do the pet's work, for the same reason a replacement hire can't — the state isn't reproducible from the inputs it's given.

So the cog model isn't merely unfair to your stars. It's *pointed at the roles most likely to evaporate.* "Make yourself a replaceable, interchangeable cog" turns out to be career advice for getting replaced — you optimized yourself into the one shape automation can copy. The engineer carrying pet-state — the judgment, the why, the relationships, the taste for which answer is worth chasing — is holding exactly what doesn't commoditize, and therefore exactly what doesn't automate.

This is the same turn as [running a system instead of writing code](/blog/running-a-system-not-writing-code): when the generator does the reproducible part, what's left is deciding what *correct* means and owning the result — the non-reproducible part. And it's the same escalator as [manual to automated to autonomous](/blog/manual-automated-autonomous): automation keeps eating the cattle layer and keeps exposing a thinner, higher layer of pet-judgment on top. The value doesn't disappear. It moves up, into the state no machine was handed.

## What It Means for Hiring and Managing

[Hiring by keyword is broken](/blog/hiring-by-keyword-is-broken) for exactly this reason: it's cattle-sorting. Keywords match the reproducible, specifiable attributes — the slot — and are structurally blind to irreproducible state, which is the only thing that separates a star from a résumé. You cannot grep for judgment. A hiring process that can only see cattle attributes will, reliably, filter out the pets.

And managing, stated plainly: your job is to find the irreproducible state, protect it, grow it, and *cattle-ize everything around it* so your pets aren't burning their one-of-a-kind context on commodity toil a script should be doing. The cog model does the exact opposite — it flattens everyone to a slot, which wastes the stars, insults them until they leave, and lovingly preserves the commodity work that was the first thing you should have automated.

Infrastructure is not an application. People are not cattle. It's the same mistake both times, and the same fix: know which of the two things in front of you can actually be reproduced — and stop pretending about the one that can't.
