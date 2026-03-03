# The Best Dog Trainer in the World - Or Why Getting Better Isn't Helping

You can be the best dog trainer in the world. You can have decades of experience, an intuitive understanding of canine psychology, a wall full of certifications, and a shelf full of trophies. You can be *magnificent*.

Your cat doesn't care.

Your cat has never cared. Your cat will never care. It doesn't matter how good you are at dog training. The problem isn't your skill level. The problem is you're working with a cat.

This might seem obvious when I say it like that. But I watch smart, experienced engineers make this exact mistake every single day. They're failing, so they try harder. They try harder and it still doesn't work, so they try *faster*. They try faster and harder and it still doesn't work, so they conclude they need better tools, more training, a bigger team, a longer runway. Nobody stops to ask whether they're training a cat with dog tricks.

## The Reflex

When something isn't working, our first instinct is almost always "do it better." This is deeply ingrained. It's how we got through school. It's how we got our first jobs. It's how we learned to code in the first place. Practice more. Study harder. Get faster. Improve.

And it works! Right up until it doesn't.

The thing is, "get better" is only useful advice when you're doing the right thing badly. If you're doing the wrong thing, getting better at it just makes you more efficiently wrong. You arrive at the wrong destination faster. Congratulations.

I see this in tech constantly. A deploy pipeline is slow, so the team optimizes it. They parallelize steps, cache dependencies, upgrade the CI runners. They get it from 45 minutes down to 12. Everyone celebrates. But the pipeline is still pushing changes imperatively to production from outside the cluster, and when it breaks mid-deploy the cluster is in an unknown state and nobody finds out until the pager goes off at 2 AM. They didn't have a speed problem. They had an architecture problem. They made a faster version of the wrong thing.

## Different Animal, Different Motivations

In my martial arts career, I spent decades teaching people how to fight. One thing I learned early: techniques that work beautifully against one type of attacker are useless against another. A grappler and a striker might as well be different species. The footwork that keeps you safe from a boxer will get you thrown on your head by a wrestler. They move differently, they think differently, they want different things.

You can be the best boxing coach alive. If your student walks into a grappling match, all your excellent coaching is worse than useless --- it's actively harmful, because it's giving them confidence in the wrong skills.

This is the same problem. It's not about competence. It's about *fit*. Different animals have different motivations and different behavior patterns. What motivates a dog (please the pack leader, get the treat, avoid the correction) doesn't motivate a cat (I do what I want, when I want, and your opinions on the matter are irrelevant). You can't dog-train a cat any more than you can box your way out of a wrestling match.

In tech, the "different animals" are usually problems masquerading as the same species. They look similar on the surface. They use the same vocabulary. But they respond to fundamentally different approaches, and applying the wrong approach harder doesn't help. It can't help. It's the wrong approach.

## Some Examples, Because I've Lived This

**Scaling a monolith.** Team has a monolithic application that's getting slow under load. The reflex: optimize the database queries, add caching, throw more hardware at it. They get really, really good at optimizing that monolith. They squeeze every last drop of performance out of it. Six months later, they're back where they started because the load grew. The monolith was the cat. No amount of better dog training was going to change its fundamental scaling characteristics. What they needed was a different architecture, not a faster version of the same one.

**Incident response.** Team keeps having production incidents. Management's answer: better runbooks, more thorough post-mortems, faster MTTR. They drill. They practice. They get their incident response time from 45 minutes to 15. Impressive. But the incidents keep happening at the same rate. The incidents weren't a response-time problem. They were a reliability problem. The system was fragile, and no amount of getting better at responding to breakage addresses why things are breaking. Different animal entirely.

**Documentation.** Team's documentation is always out of date. The fix: hire a technical writer, mandate documentation updates with every PR, add a checklist. The docs improve for about a month, then rot again. The problem wasn't effort or discipline. The problem was the documentation lived in Confluence, disconnected from the code, maintained by a different process, in a different tool, by different people. The docs rot not because anyone is lazy, but because the system makes rotting more likely than not. You don't fix a systemic problem with individual effort. That's dog-training a cat.

**Security.** Team keeps failing security audits. The response: more training, stricter code reviews, better static analysis tools. All good things. But the real problem is the architecture exposes a massive attack surface, and no amount of vigilant code review changes the fact that the blast radius of any single compromise is the entire system. You can't review your way out of an architecture problem. Different animal.

## The Diagnostic Question

Here's the question I ask --- of myself and of anyone who'll listen --- when something isn't working:

**"Is this a skill problem or a strategy problem?"**

A skill problem means you're doing the right thing, just not well enough yet. The solution is practice, learning, and improvement. These are the problems where "try harder" actually works.

A strategy problem means you're doing the wrong thing. It doesn't matter how well you do it. The solution is to stop, step back, and reconsider the approach itself. "Try harder" not only doesn't help --- it delays the moment when you finally recognize you need a different approach. Every hour you spend getting better at the wrong thing is an hour you didn't spend finding the right thing.

Most of the time, when something has been failing for a while despite competent people working on it, it's a strategy problem. Competent people don't usually fail at skill problems for long. They learn, they adapt, they get better. If competent people are stuck, the problem is almost certainly not competence.

## The Trap of Optimization

Optimization is seductive. It feels productive. You can measure it. You can show progress. "We reduced build times by 40%!" Wonderful. Nobody asks whether you should be building the thing at all.

There's a reason for this. Questioning the fundamental approach is *uncomfortable*. It implies that past decisions were wrong. It implies that work already done might be wasted. It means telling leadership "we need to rethink this" instead of "we just need more time." Nobody wants to be the person in the room saying "I think we're training a cat."

So instead, we optimize. We polish. We improve. We make the wrong thing faster and shinier and more resilient. We become *world-class* at the wrong thing. And when it still doesn't work --- when the cat still doesn't sit on command despite our impeccable dog training --- we blame the cat.

I've been this person. I've spent weeks optimizing systems that shouldn't have existed in the first place. I've made beautifully efficient solutions to problems that turned out to be symptoms of a deeper issue I wasn't looking at. I've written truly elegant code that solved the wrong problem entirely. It's a humbling experience, but an instructive one.

## How to Know It's a Cat

There are some tells. Not foolproof, but useful.

**Diminishing returns.** You're putting in more effort and getting less improvement. If the first optimization gave you 40% and the next gave you 10% and the next gave you 2%, you're probably approaching the fundamental limits of the approach, not just running out of low-hanging fruit.

**Same problem, different costume.** You fix the issue, and a similar issue shows up somewhere else. Then somewhere else. You're playing whack-a-mole. This is the system telling you the problem is structural, not local.

**Competent people, persistent failure.** Smart, experienced engineers are struggling. Not because they're incompetent, but because the thing they're doing is fighting them. Good engineers failing repeatedly at the same class of problem is a strategy signal, not a skill signal.

**The workaround pile.** Every solution requires a workaround. The workarounds need their own workarounds. The documentation for the workarounds is longer than the documentation for the system. You're compensating for a fundamental mismatch with ever-increasing cleverness. Cleverness is not a compliment in engineering.

**"We just need to..."** If every retrospective ends with "we just need to be more disciplined" or "we just need to follow the process better," you have a process that fights human nature instead of working with it. You're training a cat.

## What to Do Instead

Stop. Step back. Ask the uncomfortable questions.

"Is this the right approach, or are we just getting better at the wrong one?"

"What if the problem isn't execution, but architecture?"

"What if the failure isn't in how we're doing it, but in what we're doing?"

These questions feel dangerous because they threaten sunk costs. All that work. All that optimization. All those improvements. If the approach was wrong, then what was all that effort for?

It was for learning. That's what it was for. You now know --- with hard-won evidence --- that this approach has limits. That's valuable information. More valuable, frankly, than another 5% optimization would have been.

In my experience, the moment someone finally asks "wait, are we sure this is even the right approach?" is the moment the real progress starts. Not because the new approach is immediately obvious, but because you've stopped pouring energy into a dead end. You've freed up the most valuable resource in any engineering organization: the attention of competent people.

## The Point

Getting better is important. Skill matters. Speed matters. But they matter *in context*. Being the fastest, most skilled practitioner of the wrong approach is not a success story. It's a cautionary tale.

Before you optimize, before you parallelize, before you throw more engineers at it, before you upgrade the tooling, ask yourself one question:

Is this a dog, or is it a cat?

Because if it's a cat, no amount of dog training in the world is going to help you. And the sooner you recognize that, the sooner you can stop training and start thinking.
