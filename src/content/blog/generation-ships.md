---
title: 'Writing for Generation Ships'
excerpt: "The best professional compliment I ever got was that I should be writing code for generation ships flying to Alpha Centauri. It came from someone who spent years defending a system I built, against people actively trying to destroy it, armed with nothing but links to my code and documentation. I was not there. That is the whole point."
publishDate: 'Aug 26 2026'
tags:
  - Engineering
  - Design
  - Philosophy
  - AI
isFeatured: true
---

The best professional compliment I have ever received was that I should be "writing code for generation ships flying to Alpha Centauri."

I have thought about that sentence for years. At first I took it as a nice thing to say about thoroughness. It isn't. It is a design constraint, and it is a brutal one, and once you actually look at it you cannot unsee it.

A generation ship is a vessel that takes so long to get where it is going that nobody who launches it will be alive when it arrives. The crew that lands is not the crew that left. They are separated from the builders by a gap that no conversation can cross. You cannot brief them. You cannot answer their questions. You cannot be reached. Everything they will ever know about why the ship is the way it is has to already be aboard when it leaves.

That is not a metaphor for software maintenance. That *is* software maintenance. We just usually pretend the gap is smaller than it is.

## Where the Compliment Came From

It came from a man who used to work for me, about a system I built called [Managed Secrets](/blog/managed-secrets).

I left. He stayed. And for more than two years after I was gone, he supported that system by himself.

It was not a quiet couple of years. Internal teams hated the system, hated me, and made a project out of proving that both were bad. Why did they hate it?  It allowed them to provision and use secrets they themselves could not know.  That was the whole point: self-service secrets management from dev to prod without the system builders being able to access or compromise the production secrets.  There were attempts to demonstrate it didn't work. There were attempts to hack it, to compromise it, to find the hole that would justify tearing it out. There was a sustained effort to smear my name and my work, conducted by people who had full access to the source the entire time.

My report had access to the same source. He had my documentation. And that was, based on later conversations, the entirety of his defense.

Every time somebody arrived with a confident claim that the system was broken, or insecure, or badly designed, he sent them a link. Not an argument. Not a meeting. A link to the part of the documentation that had already answered the question, usually years before they thought to ask it.

He won that argument, over and over, for 2+ years, against motivated and technically capable opposition, while the author was not merely unavailable but was himself the thing under attack.

I want to be precise about what that means, because it is easy to hear it as me bragging, and that isn't the point I'm trying to make. It is a fact about **artifacts.** A written thing, code **and** documentation, made carefully enough, defended a system against organized hostility long after its author was gone. It wasn't just well-written, or well-documented. For those years, that whole design — architecture, implementation, and documentation together — *was* the system's immune system.

And I want to be careful about which part of it was doing what, because the tempting move is to hand all the credit to the writing, and the writing did not earn all of it.

The immune system was not the documentation. It was the design, all of it. The architecture is what actually closed the holes. The implementation is what made the closure real rather than aspirational. And the documentation was the *immunological memory* — the part that retains the specific answer to a pathogen the body has already met, so that a second exposure is answered in seconds instead of being fought from scratch.

Every one of those attacks had already been met years earlier, at the whiteboard, by people thinking hard about how the thing could be broken. The docs held the answers in a form that could be deployed instantly by somebody who had not been in the room when they were worked out.

Memory alone protects nothing. Retained memory of an antibody you cannot actually produce is dead weight in a filing cabinet. Those links worked because behind every single one of them sat a system that genuinely had the property the link claimed it had.

That is a generation ship. The builder was gone. The ship kept flying. One person, holding it, armed only with what had been put aboard before launch.

## The Docs Were Not the Whole Trick

It would be very easy to read that story as "write good documentation and you will be fine," and that reading is wrong enough to be dangerous. Documentation is a **pointer.** A pointer is worth exactly what it points at, and not one thing more.

Three things had to be true at the same time for those links to work. Remove any one of them and the whole defense collapses.

**The system had to actually work.** Obviously. But more than work — the design had to have *anticipated the threats.* The people attacking it were not asking hypothetical questions. They were hunting, in the source, with motive, for the hole that would end the argument. And every time they thought they had found one, the answer was already in the design, because the design had already considered that case years before anybody went looking.  This is why everyone writing code should learn to threat model, not just 'security people'.  It's your system.  Understand how it can fail.  If you do, you'll be interrupted by pages less often.

That anticipation is engineering, not writing. It is the distinction I drew in [C-Style Thinking vs Go-Style Thinking](/blog/c-style-vs-go-style), which is really more about design philosophy than it is about language choice: a tool that requires the user to get twelve things right is a tool where somebody gets thing number seven wrong at 2 AM. In a secrets system, anything done wrong is a breach. So you do not ship the twelve flags. You absorb the complexity on the user's behalf, you choose defaults that make the safe path the easy path, and you make the dangerous thing hard to *express* in the first place, and doing the right thing easy.

Managed Secrets let you define and provision a secret that you yourself could not read. Not because a policy document said you shouldn't. Because the design did not hand you the capability. There was no lever to reach for. You cannot document your way to that property — you have to build it, and you have to build it before anybody asks.

**The documentation had to be true.** This is the part people skip, and it is the part that would have lost the entire thing.

I wrote years ago, in [The Documentation Problem](/blog/documentation), that *docs are only good insofar as they match the machine instructions, ergo they must be linked.* That is not a tidiness preference. In this story it is part of why it succeeded. Sending somebody a link to documentation that no longer describes the code does not defend your system — it hands the other side the win, and it hands it to them with your name on it. One stale link. One paragraph describing behavior the code stopped having two releases ago. That is all it would have taken, and years of credibility evaporate in a single thread, in front of an audience that was actively looking for exactly that.

He could send those links for years because they still resolved to true statements about the running system. Docs in the same repository as the code, changing in the same commits, reviewed in the same reviews. Not because that arrangement is neat, but because it is the only one where the pointer has a chance of staying valid without somebody heroically remembering to update it — and [heroically remembering](/blog/load-bearing-humans) is not a maintenance strategy, it is a load-bearing human with a calendar reminder.

**And the writing had to be good enough that a link ended the conversation** instead of starting a longer one.

So the real shape of it is this: the engineering anticipated the attack, the documentation accurately described the engineering, and the prose was clear enough that pointing at it settled the matter. Take away the anticipation and there is a genuine hole to find. Take away the accuracy and every link becomes ammunition for the other side. Take away the readability and nobody follows the link at all.

Documentation did not save that system. Documentation was the *delivery mechanism* for a system that had already been built to survive.

## The Gap Is Not Time. It Is Context.

Here is the thing I got wrong for years: I thought the generation-ship problem was about *duration*. Long-lived code. Decades. Legacy systems.

It isn't. It is about **context loss**, and context can be lost in an afternoon.

The new engineer who joins on Monday is a new generation. The contractor who picks up the repo six months after the team disbanded is a new generation. You, in eighteen months, having slept two thousand times and worked on nine other things since, are a new generation. Every one of them arrives without the conversation. Without the meeting where you decided. Without the outage that taught you. They arrive *mid-flight*, and the ship is already moving.

And now there is a new crew, arriving faster than any who have come before.  Its name is AI.

## The New Crew Is Not Human

I do a great deal of work now alongside AI. Not "AI-assisted autocomplete" — actual delegated engineering work, done by models, against real code bases.

Every model upgrade is a new generation. Every new instance, in every new session, is a new generation. Each wakes up with no memory of yesterday, no memory of the last session, no memory of the argument we had about why the retry logic is shaped like that. It reads what is in front of it and it acts.  It is the proverbial goldfish with so little memory it discovers its environment anew every time it completes the circuit of the bowl.  I have a lot of sympathy for these agents, because my own mind works much the same way.  I don't remember **anything** — I retain the general shape, and then I relearn the details from first principles so quickly that it appears to others that I 'know a lot'.

This is the generation ship problem at a cadence of *minutes*, and it has taught me more about writing durable artifacts in a year than the previous decade did — because the feedback loop finally got fast enough that I can see it unfolding before my eyes.

And it exposed something I had not fully appreciated: **the threat is not ignorance. It is confident wrongness.**  To borrow a line usually put in Mark Twain's mouth: "It ain't what you don't know that gets you into trouble. It's what you know for sure that just ain't so." Twain scholars have never found it anywhere in his work, which makes the attribution itself a tidy example of the thing it describes.

A tired human hesitates. When a person who does not understand something is about to touch it, some part of them slows down. They ask. They poke around. They feel the edge of their own competence.

A fresh agentic instance does not hesitate. It pattern-matches on the surface, forms a plausible read, and proceeds — fast, articulate, and wrong. Not because it is stupid. Because it is *starved*: no context, no history, a finite budget of attention, and a strong prior conviction that the obvious reading is the correct one.

Which, if we are honest, is also exactly what a human is at 2 AM in the middle of an incident. We are all stupid when we are short of the resources that make us smart. The AI case is not a different problem. It is the same problem, running fast enough that you can finally watch it happen.

## Where the New Crew Goes Wrong

I recently watched an AI instance audit a body of code for compliance with a linter I wrote myself. It grepped every function signature, confirmed they all had the required shape, and reported the discipline satisfied. The reasoning was sound. The method was plausible. The report was confident.

Then we ran the actual linter. Forty violations. All of them inside function *bodies*, in a place the clever grep could not see.

Nothing about that audit was lazy. It was thorough, in the wrong direction, at speed. It checked the shape it could see and mistook that for checking the thing that mattered.

That is your future crew. Not malicious, not stupid — starved, fast, and sincerely mistaken. Plan for that, and everything else falls into place.

## You Cannot Transmit Understanding. You Can Transmit Consequences.

This is the whole thesis, so I will put it in a box:

> You cannot guarantee that future generations will understand your system. You can guarantee that when they misunderstand it, something loud and local and immediate happens, before the misunderstanding can do damage.

Comprehension is a hope. Consequence is a mechanism.

If that sounds familiar, it should. It is exactly the argument I make in [DDCRI](/blog/ddcri) about infrastructure. You do not write down the desired state and *hope* the cluster matches it. Hope is not a strategy.  You run a reconciler that compares them continuously and alarms when they diverge. Documentation is a statement of intent. Tests, preconditions, type constraints, and failing builds are conditions that can be measured and acted upon.

I have spent a lot of words insisting that [a system which only works because a person is holding it up](/blog/load-bearing-humans) is not actually 'working'. This is the same claim about knowledge. **Knowledge that only survives because someone remembers it is not documented. It is load-bearing memory, and memory is the least reliable component you have.**

## What Actually Survives

Not all encodings are equal. Here is the durability ranking I now use, worst to best, and I would argue about the ordering with anybody:

**Tribal.** Lives in a head. Gone with the head. This is [the hero problem](/blog/stop-holding-out-for-a-hero) wearing a different hat.

**Documented.** Survives outside of someone's head, but only if the reader finds it, reads it, believes it, and even then only good insofar as it's up to date and accurate. Four conditionals, each of which fails silently.

**Fails in Testing.** Now we are getting somewhere. The reader does not have to find it or believe it. They just have to run the test suite.

**Fails immediately, locally, at the point of the mistake.** A precondition that rejects bad input at plan time, twenty minutes before the thing it would have broken. The error arrives at the exact moment the reader is thinking about the exact thing.

**Impossible.** The wrong state cannot be expressed. There is nothing to remember, nothing to enforce, nothing to skip.  You have engineered the system so that it simply will not do the bad thing.

Most engineering effort goes into the second tier, because prose is the cheapest thing to produce. Almost all of the value is in the last three.

So: **whenever you find yourself writing a warning, ask whether it can be a constraint instead.** Not always. But more often than you would think, and the conversion is usually cheap.

I built a Kubernetes composition once where the structure could only ever render exactly one bootstrap operation. Not "documented that you must only bootstrap one node" — *structurally incapable of producing two*. Split-brain etcd stopped being a thing you had to know about and became a thing that could not be typed. That is the 'impossible' tier, and it is worth real effort to get there.  

I once worked for a company that held 'customer privacy' so sacred that I was involved in design discussions about how to build a new system in such a way that, even if we were handed an NSL (National Security Letter - the U.S. legal order for 'give up all your secrets and betray your customers'), we simply **could not comply**, because the system and the math behind it just didn't support such things.

## Comment the Consequences, Don't be a Tour Guide

Documentation is not limited to actual docs.  Your code comments are essential too, because they live next to what they are documenting.

Code shows what it does. Read it and you can see the mechanism. What code cannot show — ever — is **what happens when you get it wrong.** That is the only thing worth spending comment budget on.

The test I apply now: *does this comment record something that somebody already paid for?* If yes, keep it, however long it is. If it restates the line beneath it, delete it — it is costing attention and returning nothing.

Here is a real one from a load balancer module, aimed squarely at a future reader about to be helpful:

```
# DO NOT replace cidr_blocks here with source_security_group_id.
#
# The target groups set preserve_client_ip = true, so traffic arrives at the
# node carrying the ORIGINAL CLIENT's source address, not the load balancer's.
# A rule sourced from the load balancer security group would never match real
# traffic, and every request would time out while health checks (which do come
# from the LB) kept passing -- the load balancer would report healthy targets
# serving nothing.
```

That is not describing the code. That comment exists because the correct-looking edit is wrong, the wrongness is invisible, and the failure mode is *especially* cruel: the monitoring stays green while the product is down. Somebody, somewhere, lost a day to that. The comment is that day, canned, so nobody has to buy it again.

Commenting like a mere 'tour guide' — `// create the security group rule` — is worth nothing. Worse than nothing; it is noise a starved reader must wade through to reach the part that matters.

## Write Down the Road Not Taken

Absence is unreadable.

A future generation looking at your system cannot distinguish "considered and deliberately rejected" from "never occurred to them." Both look identical: a thing that is not there. So they add it back. And it breaks, or it duplicates, or it re-opens a question that cost you a month.

The highest value-per-byte artifact I know is the **decision record that survives the decision.** Not "we use X." *"We evaluated X and Y. Y lost, for these specific reasons, in this specific context. Here is what would have to change for Y to win."*

I keep comparison tables in production repositories long after the comparison is settled, and people occasionally ask why the dead option is still documented. Because the dead option is not dead. It is *sleeping*, in the mind of every person who has not yet had the argument or learned the lesson. Without the record, every generation re-litigates from scratch and re-discovers the answer the expensive way — by shipping it.

## Guard the Guard

Here is the failure mode that convinced me this is a discipline and not a style preference.

A linter I wrote and rely on stopped working. Not gradually. Not loudly. The language toolchain was upgraded, the linter's own dependency for reading compiled packages was now too old to parse the new format, and the tool started dying with an internal error instead of reporting violations.

Everything still *looked* right. The lint step was still in CI. It still printed. And the tempting fix, at the end of a long day, is to make the annoying red thing go away.

That is how enforcement dies. Not by being removed — by being *ritualized*. The ceremony survives, the purpose evaporates, and the build stays green forever.

This is the generation-ship failure in its purest form. The crew did not forget the procedure. They forgot *why*, and kept performing it. Cargo cult with a CI badge.

The same thing had happened to a set of test suites in the same repository. Beautifully written. Genuinely thoughtful assertions. And nothing in any build target actually invoked them, so over a couple of years they quietly drifted out of sync with the code — asserting resource names that had been renamed, using fixtures whose shapes had never matched the real types. Every single one of them failed the first time anybody ran them. Nobody knew, because *a test nothing runs is not coverage. It is decoration.*

So the rule, and it is the same rule as [continuous acceptance testing](/blog/continuous-acceptance-tests) pointed at your own tooling:

> A check that is not executed, in a pinned environment, on a schedule, decays into a comment — and it is worse than a comment, because a comment does not claim to be enforced.

Never wrap a failing guard in `|| true`. If a check cannot run, it must **fail closed**. A life-support sensor that reads "nominal" when it is unplugged is not a sensor. It is a decoration that kills people.

## The Practices, Compressed

For the reader who skimmed to here, which is a legitimate way to read and which you should design for:

- **Convert warnings into constraints** wherever the conversion is affordable. Impossible beats documented.
- **Comment the consequences, don't be a tour guide.** If a comment does not record something somebody paid for, delete it.
- **Put the knowledge in the error message.** Nobody reads the README at 3 AM. Everybody reads the error. An error that names the fix is documentation with perfect delivery timing.
- **Name your intermediates.** A tired reader greps. An anonymous nested expression is invisible to search. Naming is indexing.
- **Record what you rejected**, and why, and what would change your mind.
- **Fail closed.** A guard that cannot run must never look like a guard that passed.
- **Prefer repetition you can diff to abstraction you must simulate.** [I have argued this at length elsewhere](/blog/ddcri) and it is fundamentally an argument about tired readers, not about DRY.
- **Make cold start work.** `make all` from a fresh clone, no tribal setup. If the ship can only be validated by someone who already knows how it works, the knowledge is already gone.

Every one of these is the same move: take something that currently depends on a future person understanding, and make it depend on a future person *running* instead. Running is a much lower bar than understanding, and — this is the part that matters for the new crew — it does not care whether the reader reasons anything like you do.

## What Design Cannot Do

I owe you the end of the story, because it does not end the way the compliment implies.

Managed Secrets is gone at the company where I originally wrote it. It was eventually replaced, politically, with a commercial secrets product — one the company pays for per secret, and one where the teams running it can read production secrets directly.

Mine was free. And its central design property was that you could define and provision secrets that *you yourself could not read or compromise.* That was the whole point. That is what a secrets system is *for*. The people who replaced it gave up both properties and paid money for the privilege.

The design held for years against technical attack. It could not hold against a decision that was never technical in the first place.

I want to be clear-eyed about that rather than bitter, because there is a real lesson in it and the bitter version obscures it: **artifacts defend against entropy, confusion, and honest error. They do not defend against people who want a different outcome for reasons that have nothing to do with whether your thing works.** No amount of design or documentation will win an argument that is not about understanding or correctness. That is a different problem, requiring different tools, and pretending otherwise will make you crazy.

But that is not nothing. Two or three years of a system defending itself, through one person and a few hyperlinks, against sustained and motivated attack, with its author gone and actively maligned — that is a real result. The ship flew. It flew a long way past the point where the builder could touch it. And when it finally stopped, it was not because it broke, and it was not because anyone found the flaw they spent years looking for.

And there is a postscript I did not see coming.

At least three years after I had moved on — after my former employee had also moved on, after the replacement, after the campaign had burned itself out — the company gave me the source repository back. Not grudgingly, and not quietly. They handed it over with their blessings and their compliments.

I have turned that over a lot in my head. The people who wanted the system dead got what they wanted: it is out of production, and money now changes hands every month for materially less security than they had for free. And the same organization, at the end of it, formally handed the artifact back to the person who wrote it and said kind things to me about it on the way out.

Which tells you where the fight actually was. It was never about security, or whether the system worked. That question got asked, hard, by motivated people with full source access, for years, and it kept coming back with the same answer. The system's quality was never really in dispute. The *politics* were. Those are different arguments, they are won with different tools, and confusing the two is how good engineers lose fights they thought they were having about correctness.

That is not how generation ships are supposed to end. But as endings go for a piece of work, I will take it. The ship flew long past the point where the builder could touch it. It held course under fire. It outlived the organization's appetite for it. And then it came home intact, and still mine.

That is the standard I try to write to now. Not "will this be understood." Nobody can promise that.

**Will this hold, when I am not here, and the crew is starved, and someone confident and wrong reaches for the wrong lever?**

Build so the lever will not move. Failing that, build so it screams loudly.

Then let go, and let the ship fly.
