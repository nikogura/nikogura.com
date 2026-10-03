---
title: 'Maintainability Against the Unknown Unknowns'
excerpt: "At Terrace, curating the world's crypto market data, something like 71% of what came through the door was noise or outright fraud — and the worst of it was stuff we could not have imagined if we'd sat down and tried. You cannot filter garbage you have never seen. So you stop trying to predict the input and start building the thing that absorbs it in ten minutes flat. That isn't cleverness. It's enforced lint and tests and clean boundaries — maintainability as a weapon against the unknown."
publishDate: 'Oct 03 2026'
tags:
  - Engineering
  - Golang
  - Testing
  - Maintainability
  - Architecture
isFeatured: false
---

There is an Ethereum token out there whose name is a multi-page rant against the US tax system. Not its ticker — the *name field* is a screed. He makes a few fair points; I would also prefer to pay less tax. But whether he's right is not the interesting question for an engineer. The interesting question is: *why is that the name of a token, and what is it about to do to my parser?*

At Terrace, I owned the system that had to have an answer to that question — for every token, on every chain, forever. The job was to curate the world's cryptocurrency market data: millions of tracked assets across EVM chains, Solana, UTXO chains, and a pile of centralized exchanges, each with its own idea of what a "name" or a "price" or a "pair" even is. By one internal estimate, **71% of what came through the door was garbage** — dead tokens, scams, honeypots, deliberate fraud, and a long tail of things that existed purely to make a point only a deeply wired-in engineer would find significant. Someone, somewhere, is right now deploying a token specifically to break a system like mine, and they are being creative about it.

Here's the part I think matters most, and it still surprises people: I knew — and honestly still know — next to nothing about cryptocurrency. No thesis on which chain would win, no feel for the culture, no particular interest in any of it. I built the whole thing on two things instead: solid distributed-systems engineering, and pessimism about what people will do to a system the moment you let them. I didn't need to understand crypto. I needed to assume that whatever *could* arrive *would*, that a healthy fraction of it would be hostile or insane, and to build as if that were a certainty — because it was. I've made that case directly about [Web3 being infrastructure in a costume](/blog/web3-for-infra-engineers). The system underneath was one I'd built a dozen times in other clothes, and disciplined pessimism did the rest. Domain expertise would have been a nice-to-have, but I had people who lived and breathed crypto. Pessimism and clean interfaces were my job.

You cannot write that requirement down. That's the whole problem, and it's worth saying plainly because most of our craft quietly assumes the opposite.

## You Can't Filter Garbage You've Never Seen

You can filter the garbage you know about. Null names, negative prices, obvious honeypots, the scam signatures you've already catalogued — that's just work, and it's finite. The trouble is the other category: the stuff nobody has imagined yet. In an adversarial, chaotic domain, novelty is not a tail risk you can hedge against. It is *tomorrow's deploy*. The unimaginable thing isn't a question of *if* or even *when* — it already shipped, you just haven't been paged about it yet.

Most systems are built, without anyone deciding to, around the set of inputs their authors could picture. They handle the cases in the ticket. Then the input that no sane user would ever input, and the system doesn't bend — it shatters. A panic, a poisoned cache, a wedged pipeline, a number that's suddenly wrong three services downstream. The failure isn't that the engineer missed a case. *Everybody* misses the case, because the case was unknowable. The failure is that the system was built as though the list of cases were knowable and complete.

So stop pretending it is. You will never enumerate all the inputs. What you *can* do — the only thing you can do — is build the system so that when the unimaginable shows up, taking it on board is a ten-minute change instead of a rewrite. You don't design for the specific unknown. You design for the *arrival* of unknowns, as a permanent, first-class condition of the system. That is what maintainability actually buys you, and it's why I think it's the most undersold property in software: **maintainability is durability against the unknown.**

## How You Actually Build It

None of this is exotic. That's the point I most want to land. The way you survive the unimaginable is embarrassingly boring, and the boringness is a feature.

The data path was a pipeline of small, composable middleware — fraud detection, liquidity calculation, verification — each one a pluggable stage that consumed data and emitted data and assumed nothing about who called it or what ran next. New kind of fraud? New stage, or a new rule in an existing one. A scanner/parser abstraction sat underneath so that a new chain or a new token standard was a *new implementation of a known interface*, not surgery on the core. And it was an append-only system of record — we kept the garbage we rejected, because the definition of "garbage" changes, and when it does you want to reprocess history against the new rule rather than having thrown the evidence away. (I've argued the general version of that reconciliation-not-snapshots instinct in [DDCRI](/blog/ddcri) and [Most Infrastructure as Code Is Broken](/blog/most-infrastructure-as-code-is-broken).)

Then the part that made all of it actually hold: **table-driven tests, in Go, for even the stupidly simple things.** This is the mechanism. When some new piece of on-chain asshattery blew up the system at two in the morning, the fix wasn't heroic. It was a new row in a test table — *this input, that expected result* — and a few lines to make the row pass. The thing that took us down before lunch was a regression test and a closed ticket after lunch. Every novel disaster made the suite permanently stronger, because the disaster became a documented, enforced case the system would never regress on again. Test tables turn "we got surprised" into "we got surprised *once*."

And it only stayed that way — this is the unglamorous core of the whole essay — because lint and test standards were **enforced, not suggested.** [Coding standards](/blog/coding-standards) and [engineering standards](/blog/engineering-standards) that block the merge, not a wiki page everyone agrees with and nobody follows. [Continuous acceptance tests](/blog/continuous-acceptance-tests) that assert the contract, not just a green checkmark. You *could* build the same features any old way — ship the pipeline as one big function, skip the interface, test the happy path, let the linter slide "just this once." It would even work, right up until the day it had to change. My way cost a little more discipline up front and bought a system you could extend in ten minutes and — this is the part you can't plan for — *reuse in ways we never designed for*, because clean boundaries are reusable boundaries. The flexibility was never cleverness. It was a byproduct of refusing to let the boring standards slide.

## The Unknown Input and the Unsettled Rule Are the Same Animal

Here's where this stops being a crypto war story. You cannot know next week's token, and you cannot know next quarter's regulation, and — structurally — they are the *same problem*. Both are rules you don't get to see until they arrive. A regulator reclassifies your product; a chain ships a new standard; a fraudster finds a new seam. In every case the input to your system changed underneath you, and in every case there was no way to have known the specific shape in advance.

People treat "we don't know what the rule will be" as a reason to freeze. It isn't. You can't pre-know the rule, but you can build the thing that *bends to whichever rule lands instead of breaking.* That is the entire value of a clean, well-tested, well-bounded codebase when the ground is moving: not that it predicted the future, but that it made the future cheap to absorb. ([Don't paint yourself into a corner](/blog/dont-paint-yourself-into-a-corner) is the same lesson from the other direction.) Maintainability is how you keep your options open against a world that is under no obligation to be imaginable.

## The Boring Part Is the Secret

I'll put it as bluntly as I can: the way you defend against the unknown unknowns is not foresight, because foresight is exactly the thing you don't have. It's discipline you can't see the payoff of on the day you pay for it. Enforced linting. Table-driven tests on the trivial stuff. Interfaces that assume nothing. An honest system of record. You do these for their own sake, the way you do any fundamental, and the reward arrives later and sideways: the day something lands that you "literally could not have imagined" stops being a disaster and becomes just another day.

For most of my career I've played defense — infrastructure, SRE, the person who shows up at three in the morning and then, afterward, the person pointing out that the product wasn't built to bend. The thing that's started to pull at me lately is building that bend *in*, on the product side, from the first commit — not complaining that it's missing at prod handoff time, but being the one who puts it there. Because the unimaginable is coming. It's probably already in the queue. The only real question is whether your system meets it with a panic, or with a new row in a test table.
