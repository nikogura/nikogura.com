---
title: 'Your Hiring Pipeline Has the Same Bug as Your Deploy Pipeline'
excerpt: "A résumé parser matches tokens, not competence. It's the same mistake as infrastructure that describes state instead of maintaining it, and the same mistake as confusing 'can' with 'does.' Keyword-gated hiring optimizes a proxy and quietly filters out exactly the senior people it claims to want."
publishDate: 'Aug 10 2026'
tags:
  - Hiring
  - Engineering
  - Systems
isFeatured: false
---

I build systems for a living, and I've started noticing that the systems companies use to hire the people who build systems are broken in exactly the ways those people would never ship.

The applicant tracking system — the ATS, the résumé parser sitting at the front of nearly every job posting — is the clearest example I know of a whole industry optimizing the wrong metric with total confidence. It is a search engine pretending to be a judgment engine. And like most of the broken infrastructure I get hired to fix, its failure isn't an accident or a bug to be patched. It's the natural consequence of measuring a proxy and forgetting it was ever a proxy.

## Keyword Match Is Not Comprehension

I've written before about the gap between [can and does](/blog/can-vs-does) — that "it can work" is a statement about a single moment under controlled conditions, and "it does work" is a property of reality sustained over time. Hiring has its own version of that gap, and the parser lives on the wrong side of it.

A keyword match tells you a word appeared in a document. That's all it tells you. The token "Kubernetes" in a résumé is not evidence that the person can operate Kubernetes, let alone that they've stood it up on bare metal, debugged its network layer at 3 a.m., or made the call *not* to use it when something simpler would do. The word is a shadow of the competence, and the parser hires the shadow.

This is the same error as most [Infrastructure as Code](/blog/most-infrastructure-as-code-is-broken): it describes a state instead of maintaining one. A résumé is a snapshot — a description of a career frozen at the moment it was written. The parser then matches the *tokens in the snapshot* against the *tokens in the job description*, and mistakes that token overlap for a fit. It's pattern-matching on the map and never once looking at the territory.

A keyword either matches or it doesn't — there's no partial credit for understanding the thing underneath the word. I spent years wrangling iptables; I wrote my first firewalls in ipchains, the predecessor it grew out of. Does it matter that the posting asks for nftables or eBPF? Same idea, newer packaging. I'd read up on the particulars before shipping either to production — but is that a gap, or just Tuesday? The parser can't tell the difference, because the thing that closes that gap in an afternoon — knowing what a packet filter actually *is* — was never a token it could match on.

Take AI infrastructure, since every posting wants it now. I haven't run GPUs at scale — but what is a GPU? A specialized chip soldered to a board. I've spent years on those: HSMs, secure elements, NVMe storage, and scheduling workloads across heterogeneous distributed systems so the right job lands on the node with the hardware it actually needs. That last part is **exactly** the GPU-scheduling problem wearing a different name. Do the specific details matter? Of course — and you look them up when you need them. Before AI you Googled it; now the retrieval is just faster and more accurate. What you can't look up is understanding the **problem domain** well enough to know which details to go find. That's the part that doesn't tokenize.

## The System Filters Out Exactly Who It's Looking For

Here's the part that should bother anyone who actually needs to hire senior people: the more experience you have, the worse the parser tends to score you.

The reason is structural. A résumé is a fixed-size container. A person who has done one thing for fifteen years can repeat that one thing's vocabulary until it saturates the document — every buzzword, every framework version, every tool in the ecosystem, stated and restated. A person who has done a dozen things deeply across twenty-seven years cannot. They've forgotten more tools than the job description lists, and they can't keyword-stuff all of it into two pages without turning their career into an unreadable word cloud.

My own career runs twenty-seven years at the time of this writing. How do you compress that into two pages someone will actually **read** — without turning it into the unreadable word cloud the parser rewards?

So the narrow specialist who wrote the exact incantation the parser is grepping for beats the broad operator who has genuinely solved the harder version of the problem three times, under different names, in different stacks. The senior generalist — the person who can walk into an ambiguous mess and just [figure it out](/blog/fitfo), who can learn any stack because they understand the fundamentals underneath all of them — is the person the job description swears it wants and the parser is structurally built to reject.

Judgment isn't a keyword. Taste isn't a keyword. "Can be handed a problem nobody has solved before and will come back with a working answer" is not a keyword. None of the things that actually distinguish a great senior hire survive tokenization, because none of them are tokens.

## It's Not Really About the Tool

I try never to blame the tool alone, because the tool is only half the story. The other half is human, and it's the half nobody admits.

The parser exists because hiring at volume is genuinely hard, and because deciding who's good is a judgment call that somebody has to own and be accountable for. The ATS is a way to *not* make that call. It launders a hard, fallible human decision into something that looks objective and scalable and defensible — "the system filtered them out" — the same way a broken deploy pipeline lets a team avoid owning the state of production. The bureaucracy doesn't love the parser because it works. It loves it because it's *defensible*.

And so you get the hiring equivalent of the thing I say about reconciliation loops bolted onto a broken specification: you don't get correct hiring, you get *incorrect hiring, faster, forever, with confidence.* The wrong filter, applied consistently, at scale, with a clean audit trail. Measurement theater. It feels rigorous. It is the opposite of rigorous, because it is rigorously measuring the wrong thing.

## What You'd Measure If You Meant It

The fix isn't a smarter parser. A better model for matching tokens is still matching tokens. The fix is remembering that the token match was always a proxy, and that the proxy is not the goal.

The goal — the thing you're actually trying to predict — is: *will this person make the team and the system better, and can they handle the parts of the job nobody has written down yet?* You do not get that signal from a bag of words. You get it the way you've always gotten it: a real conversation about a hard problem, a work sample, a portfolio of things they've actually built and can talk about in depth, references from people who watched them operate under pressure. Expensive, human, unscalable signals — because the thing you're measuring is expensive, human, and doesn't scale.

There's a second problem a parser can't touch: both humans and AI agents **lie** — résumés get embellished, and now they get generated. How do you catch it? You **have a conversation**. I've never found it even slightly difficult to tell, in a real back-and-forth about a hard problem, whether someone genuinely understands the domain or is just trying to bury me in buzzwords — and the buzzwords are exactly what the parser selected for.

That's not a nostalgic argument for doing it by hand. It's the same argument I make about everything: the outcome you care about is the only thing worth optimizing, and the moment you start optimizing a cheap stand-in for it, you will get a great deal of the stand-in and very little of the outcome. You'll fill the funnel with people who wrote the right words and quietly reject the people who could actually do the work.

## The Quiet Cost

None of this is a complaint. I've got plenty of work, and the market for people who can genuinely fix broken systems has never been tight. I'm writing it because it's a fascinating bug, and because it's a *systems* bug — the exact class of failure I spend my days diagnosing, showing up in the one place most engineering organizations never think to look: the front door.

The companies that win the talent fight over the next decade won't be the ones with the most sophisticated résumé parser. They'll be the ones who remembered that hiring is a judgment problem wearing a search problem's clothing — and who were willing to own the judgment instead of outsourcing it to a grep.

Your deploy pipeline shipping the wrong build with total confidence is an incident. Your hiring pipeline rejecting the right person with total confidence is the same incident. You've just arranged never to find out.
