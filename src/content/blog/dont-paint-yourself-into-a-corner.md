---
title: "Don't Paint Yourself Into a Corner"
excerpt: "Larry Wall built Perl around a principle: no unnecessary limitations. Most of the limitations we build into our own code aren't necessary either — they're laziness wearing the costume of caution, and every one is a wet patch of floor between you and the door. Stop boxing in your future self."
publishDate: 'June 3 2026'
tags:
  - Philosophy
  - Engineering
  - Golang
isFeatured: true
---

Larry Wall built Perl around a handful of principles, and one of them has stuck with me longer than the language itself: **no unnecessary limitations.** The qualifier is the whole point. Necessary limitations are fine — the ones physics, security, or the problem itself impose on you. It's the *unnecessary* ones that rot a codebase, and we add them constantly, usually without noticing, usually because it was the lazy thing to do in the moment.

Here is the discipline I have landed on after twenty-five-odd years of watching code outlive every assumption I made while writing it: **write every line as if you are about to publish it open source.** Not "could theoretically clean it up later." Right now, to that standard. Not for the applause — for the simple, selfish reason that the version of you who writes that way never gets boxed in, and the version who doesn't always does, eventually.

This isn't about credit. It's about not handing your future self a mess.

## The Standard Is "Publishable," Always

When you write code you intend to open-source, something changes in how you write it. You document it, because a stranger has to understand it. You test it, because you won't be there to answer questions. You name things clearly, because there is no hallway to ask you what `tmp2` meant. You handle the errors, because someone you will never meet is going to hit them. You think about the interface, because other people have to build on it.

That standard — completeness, discipline, documentation, testing — is not a special mode reserved for open-source projects. It is just *what good looks like*. The only reason we let ourselves write to a lower standard for internal code is that we believe nobody is watching. But somebody always is. It is you, at 3 AM, eighteen months from now, when the thing is on fire and you have forgotten everything. (I have written about that person before — they are [not as smart as you think you are right now](/blog/golang-design-tips/), and you owe them mercy.)

So hold internal code to the published standard — not to impress anyone, but because the lower standard is a debt, and you are the one who pays it back.

## Hiding in `internal/` Is Laziness in a Security Costume

Go gives you a directory called `internal/`. Put a package under it and the compiler will flatly refuse to let anything outside your module import it. People reach for it reflexively, as if it were a safety feature. It is not. It provides no security and no privacy — decompiling is trivial, you are keeping no secrets — it provides exactly one thing: a guarantee that *nobody, including your future self, can reuse this code without moving it first.*

Read that again. The only thing `internal/` does is **manufacture a limitation.** It is a wall you build around your own work to stop it from being useful. And it is almost always the *unnecessary* kind of wall — put there not because reuse would be dangerous, but because thinking about reuse would have been work.

That is the tell. `internal/` is usually a confession: *I did not write this well enough to show anyone, so I am going to enforce that it never gets shown.* It is laziness wearing the costume of caution. You skipped the design work — the clean interface, the absence of assumptions about who's calling — and then you nailed the door shut so nobody could discover you skipped it.

Listen for the word that justifies it: *"this is **only** for internal use."* "Only" is a four-letter word, the same way "just" is. Both are used to trivialize work you are not personally willing to do. "I *just* need to..." waves off the effort; "it's *only* internal" waves off the design. When you hear yourself reach for either one, stop — you are usually about to excuse a shortcut, not justify a decision.

And do not let that shortcut hide behind a real principle. Premature optimization is a genuine anti-pattern, and so is the grandiose "one thing to rule them all" anti-pattern where you build for a future that never arrives — I have warned about [the attack of the clevers](/blog/golang-design-tips/) and about [unnecessary moving parts](/blog/can-vs-does/) for exactly this reason. But "only for internal use" is not restraint from premature optimization. It is the opposite failure. Premature optimization is doing *unnecessary* work; "only internal" is skipping *necessary* work — a clean interface and no baked-in assumptions are not gold-plating, they are the baseline. Don't borrow the credibility of "I'm avoiding over-engineering" to excuse "I didn't feel like doing it right."

I am not an absolutist about it. There are real reasons to use `internal/` — a genuinely unstable API you are not ready to commit to, a true security boundary. But they are *rare*, and "I don't want to think about whether this is reusable" is not one of them. The default belongs in [`pkg/`](/blog/coding-standards/). The default is: written well enough to share.

## Composability Is the Whole Game

The reason this matters — the reason it is worth the extra discipline on a Tuesday when nobody's looking — is **composability** not "Object Oriented" (not all languages are OO, but all benefit from reuse). Every well-made, self-contained, reusable piece is a part you can snap into something else later. Every limitation you bake in is a part that only fits the one socket you happened to be looking at the day you wrote it.

You do not know who is going to need this. You genuinely cannot know. It might be your future self, six months from now, building a thing you can't currently imagine. It might be a teammate who joins next year. It might be a *company you left years ago*, still running the library you wrote, still benefiting from the hour you spent making it general. It might be the world at large, if it turns out the problem you solved is one a lot of people have.

None of those people can use work you walled off. You cannot predict the socket, so stop soldering your parts to one board. Build the part well, make it stand alone, let it consume data and emit data without [assuming how the result gets used](/blog/coding-standards/) — and it remains available for every future you can't see yet. That is the difference between writing code and *building something.* A pile of bespoke, single-use, mutually-entangled functions is a liability that grows. A library of clean, composable, well-tested parts is an asset that compounds.

This is also just [writing Go as Go](/blog/golang-design-tips/). The meat lives in `pkg/`, the CLI is a thin `cmd/` that demonstrates how to drive it, and the two never blur. Your command-line tool is one *view* onto a library that could just as easily be driven by a web service, another program, or someone else entirely. Keep the model clean and the views are cheap. Tangle them and you have built exactly one thing, forever.

## Painting Yourself Into a Corner Is a Choice

Every unnecessary limitation is a wet patch of floor between you and the door. One is fine. A hundred, applied thoughtlessly over a year, and you are standing on the last dry tile wondering how the whole room got painted. And git is forever — those wet patches never dry on their own. Every one of them waits there until some future effort comes back to fix it.

This is the same idea as ["Can" vs "Does"](/blog/can-vs-does/) pointed at design instead of failure. Every assumption you hard-wire — this only runs in our environment, this only serves our one caller, this only does the exact thing I needed today — *can* be the one that boxes you in. Given enough of them and enough time, one *does*. Tech debt is rarely a single bad decision. It is the compound interest on a thousand small "I'll deal with it later" limitations, and `internal/` is one of the most common ways we take out the loan.

The fix is not to over-engineer for imagined futures — that is its own [attack of the clevers](/blog/golang-design-tips/). The fix is narrower and cheaper: **don't add limitations you don't need.** Don't assume a caller. Don't assume an environment. Don't wall off a package because thinking about its boundaries felt like effort. Leave the doors where they naturally are. Future-proofing, most of the time, is not adding flexibility — it is *declining to remove it.*

This connects straight to [how I think about C-style versus Go-style tools](/blog/c-style-vs-go-style/). The C-style instinct narrows: expose exactly this, assume exactly that, make the caller conform. The Perl/Go instinct keeps things open: sane defaults, no ceremony, no limitation the problem didn't actually require. Larry Wall's "no unnecessary limitations" is the same conviction one layer down — not just in how a tool greets its user, but in how every package greets the next piece of code that might want to use it.

## It's a Muscle

Here is the part that took me longest to internalize: this is not a fixed trait. It is a muscle, and like any muscle it grows with use and atrophies without it.

The first time you write a throwaway script as if you were going to publish it, it feels like overkill. You document a function nobody asked you to document. You write tests for code you "know" works. You design an interface for a library with exactly one caller. It feels slow, and it is.  It used to be that you had to carefully balance 'git r done' with 'do it well', feature work vs tests, etc.  With the advent of AI, this limitation is largely gone. AI does unit tests, mocks, documentation, and instrumentation very well and very quickly.

Do it enough and it stops feeling like extra work and starts being the only way you know how to write. Clean boundaries become reflexive. Good names come first try. Tests get written alongside the code because writing them after feels backwards. The metrics, the structured logs, the trace spans go in as the code is written, not bolted on after the first incident — because a thing you cannot see is a thing you cannot operate, and you stopped shipping blind a long time ago. You stop reaching for `internal/` because composable is simply your default shape. The discipline that felt like friction becomes the path of least resistance — and now your *fast* work is also your *good* work, because you trained the two to be the same thing. You get better at being faster, and faster at being better, until you can no longer tell them apart.

That is the whole return on the investment. You are not just producing better code today. You are becoming the kind of engineer for whom better code is the natural output. Skip the reps — write the lazy version, wall it off, assume the one caller — and the muscle wastes. You get faster at producing things you'll have to apologize for later.

And these days you are training two muscles, not one. The AI you work with has a memory and a set of skills, and those are *muscles too* — they get stronger with deliberate reps exactly the way yours do. When you encode this discipline into them — a memory that says "default to `pkg/`, never `internal/` without a real reason," a skill that scaffolds a new package with tests, docs, and a clean interface from the first commit, a standard the model is told to hold every diff to — you are not just getting one good result. You are making the *next* result good by default. Teach it once that "only for internal use" is a smell, that composable is the baseline, that undocumented is unfinished, that uninstrumented is unfinished too — a service ships with its metrics, logs, and traces or it does not ship — and every future generation it helps you write starts from that bar instead of below it. Same muscle, same principle — build it on purpose, in the human and in the machine, because both of them are writing your code now.

I have been told, more than once, that I get more out of AI than other people do. This is why. It is not a secret prompt or a better model — it is that I bring a standard for the tool to meet. The model is not the bottleneck; *knowing what good looks like* is. An engineer who has built the muscle can direct an AI to produce work at that bar and recognize instantly when it has not. An engineer who never built it gets exactly what they ask for, which is whatever was easy. The AI is a force multiplier, and a multiplier only ever amplifies what you already bring. Bring the discipline, and it makes you faster at *good*. Bring the laziness, and it makes you faster at the mess you will have to clean up later — at machine scale.

## Generation-Ship Code

I once hired an engineer who, after I had moved on, inherited a product I had authored and supported it for two or three years. We talked a while later, and what he told me is the highest compliment my work has ever received. He said I should be writing code for *'Generation Ships' flying to Alpha Centauri* — the kind that has to run, untouched and untouchable, for a hundred years with nobody aboard who built it.

What he meant was concrete. The code did exactly what it was designed and documented to do. It had stayed resilient for years against every attempt — well-meaning and otherwise — to work around it, bypass it, or declare it broken. And his actual job maintaining it, he said, mostly consisted of re-posting links to my original documentation when someone reported a "limitation" or a "bug". In most cases they weren't hitting a limitation at all. They weren't following the directions.

I tell that story not to flatter myself but because of what it demonstrates. The documentation was the load-bearing artifact — it outlived me at that company by years and did the explaining I was no longer there to do. The resilience came from not baking in assumptions that someone could later trip over. And the "limitations" people complained about were, mostly, the system correctly enforcing its actual design — which they'd have known if they read what came with it. That is what *no unnecessary limitations*, paid forward, buys you: code that keeps working long after you are gone, defended by the documentation you wrote when you could still remember why.

You will not write generation-ship code by intending to. You write it by holding every ordinary commit to the standard — composable, documented, no assumptions you didn't need — until the day someone has to live with it without you, and discovers there is nothing to fix.

## Leave the Doors Open

So: hold every line to the published standard, not for the credit but because the lower standard is a loan your future self repays with interest. Build every piece to stand on its own, because you cannot predict which piece some future person — quite possibly you — will need to pick up and reuse. And above all, refuse the unnecessary limitations, because every one you decline to add is a door you leave open for a future you can't yet see.

No unnecessary limitations. Don't wall off your own work out of laziness today and call it caution. Leave the doors open — the person who walks back through them is going to be you.
