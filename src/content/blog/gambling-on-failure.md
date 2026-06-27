---
title: 'Gambling on Failure'
excerpt: "Most people gamble on success — they assume the thing will work, and they're genuinely surprised when it doesn't. A tiny, birdlike kung fu master taught me to gamble on failure instead. Expect every move to be blocked, and win anyway. It turns out to be the same discipline that keeps systems alive at 2 AM."
publishDate: 'Jun 26 2026'
tags:
  - Philosophy
  - Engineering
  - Martial Arts
isFeatured: true
---

## Two Kinds of Gamblers

Everyone is gambling. Every plan, every deploy, every architecture, every hire, every fight, every Tuesday — you are betting on an outcome you do not fully control. Shit happens.  We all know it.  The only real question is which way you bet.

Most people bet on success. They believe it will work. The deploy will go clean. The vendor will stay up. The one database with no replica will keep spinning. The hero will be awake and respond to an emergency page. And because they believe it, they are *surprised* when it doesn't — surprised by the outage, the breach, the dead disk, the punch they never saw coming. The surprise is the tell. If you're surprised, that means you bet on success and the house won.

I prefer to bet the other way. I expect it to fail. And when I'm wrong — when the thing actually works — I am *pleasantly* surprised. I try to arrange my life so that all of my surprises are good ones.  I still get bad surprises of course.  Nothing and no one is perfect.  Sometimes I get a chance to feel smart and prepared. There's a formal name for arranging your exposure this way — [antifragility](https://en.wikipedia.org/wiki/Antifragility): gaining from disorder instead of getting broken by it.

That isn't pessimism. It's the only bet where the odds run in your favor. And I learned it, of all places, by literally getting hit — repeatedly — as a fighter.

## Energy and Time

Before I was an engineer, I was a professional kung fu instructor. I even did a little bit of 'full contact'.  The two careers look unrelated until you notice they're the same activity: **rule-based problem solving.** A fight and a distributed system are both bounded spaces where a finite set of pieces interact under fixed rules.  The discipline in both is figuring out which moves actually pay off under pressure — and which ones just look good.

"Kung fu" literally translates as *energy and time*: skill bought with work. And that's exactly the trap, because most martial artists gamble on success based on the strength of their hard work. The assumption is seductive: *I'm the one who trains. I'm the athlete. I put in the energy and the time. When it comes to it, I will prevail.*

Sometimes that's true. All too often it isn't. The other person is just better — bigger, younger, faster, meaner, who knows. There's always a roll of the dice; some days you're lucky, some days you're not. And here's what the martial arts world doesn't like to admit: not all skills are martial, and not all fighting is skillful. Sometimes you just run into a natural 'junkyard dog' who never trained a day and will put you down — *hard*.

The movies make it worse. They sell the low-probability tactics — the jumps, the spins, the flips, the spinning back kick to the jaw. Another teacher of mine had a name for the whole category: ["your day" moves](/blog/can-vs-does). Would a spinning jump kick work? Sure — if it was *your day.* And if it wasn't, you'd just thrown both feet off the ground in front of a stranger and turned yourself into a committed, airborne, off-balance target with nothing left to do but hope it works. 

You know what else hangs in the air waiting to be hit?  A punching bag.  Acrobatic moves can be beautiful, they require incredible athleticism and practice.  They're almost never the right bet in a real fight. The sucker punch beats the jump kick nearly every time, and hope is not a strategy.

I put it to my own students more bluntly: *"Do you want to bet your nose on that?"* Because that's the real stake. If you're right, great. If you're wrong, you've got a broken nose. It's remarkable how many plans stop sounding clever the moment you say out loud what they cost when they fail. KISS isn't only an engineering principle; it's a survival one — the simple thing, done when it counts, beats the spectacular thing that needs 17 steps to all succeed in order for it to land right.

## "Put Some Cheese on the Trap, See if the Rat is Hungry"

I had some experience.  I won a bunch of fights.  Everyone agreed I was one bad dude.  Then I met a master who had thrown the whole assumption out. He gambled on failure.

[Wai Lun Choi](https://liuhopafa.com/master-wai-lun-choi). He stood maybe five foot nothing. Claimed to weigh 140 pounds.  *Maybe* he did — soaking wet with rocks in his pockets. He was the most intimidating birdlike little man I have ever met: a thick Cantonese accent and an offbeat sense of humor so that talking to him was like talking to Yoda. I'm 6'2" and 300 pounds. I have been known to leave fingerprint bruises on opponents merely by grabbing them.  Sifu Choi barely came up to my shoulder. It did not matter in the slightest. In his eighties, he would do push-ups balanced on his index fingers and toes. I am not exaggerating in the least here.

Choi's abilities were amazing, but what made him terrifying was that **he expected nothing he did to work.** He expected you to block him — every move. He was *counting* on it. "Put some cheese on the trap," he'd say, "and see if the rat is hungry."

Here's why that works, and it's the same insight that runs through everything I build now: the solution set in your domain is far smaller than people think. A human being has two arms, two legs, and one head. The knees and the elbows bend exactly one way. You have to stand on at least one leg or you fall over, and you can't lift a leg until you take your weight off it. That's the whole board. It feels like infinite possibility; it's actually a short list of constrained, predictable responses.

So Choi would lay out the cheese and see if you were hungry enough to walk into the trap. If you took the bait and blocked — which good sense and the rules of your own body all but forced you to — the trap closed. Your arms got crossed, you tangled yourself up, your weight shifted to the wrong foot, and your situation got worse, and worse, and worse, until you were simply done. And if you *didn't* block? You got hit. Like a Mack truck — nearly all 140 pounds of that tiny old man arriving at once.  

Often he would touch you with a single fingertip (the one he could support his entire body weight upon) on a precise pressure point.  Choi's "Dim Mak" (death touch) didn't kill you, but it left you curled up on the floor, writhing in agony. What's worse is he barely had to move to do it.  He'd teach each point by doing it to you, so you remembered.  Almost nobody ever volunteered to learn more than one.

Tactically, he was either right, or he was pleasantly surprised. There was no outcome where he lost. He had engineered the failure of his own moves into a win either way.

Sifu Choi never seemed to learn my name in all the time I studied with him — to him I was just "the Big Guy from Minnesota." It didn't matter though.  He knew who I was.  His memory was perfect for every conversation we'd ever had, and he was able to articulate amazingly fine points of physics, mechanics, anatomy and human physiology in terms that were not necessarily scholarly, but incredibly precise and accessible. 

I'll remember him for the rest of my life. His picture hangs in my office, as it should.  He even signed it referring to *me* as 'Sifu Nik'.  (So maybe he *did* remember my name after all.) Highest 'certification' I have ever achieved.  

Grandmaster [Wai Lun Choi](https://liuhopafa.com/) taught Liu Ho Pa Fa ("Water Boxing"), Hsingyi, Pa Kua, Taiji, and Lama Pai in Chicago for decades; the lesson in this post is his, not mine. I just carried it into a different kind of fight.  

Thank you Sifu.  You changed my life.  I still follow what you taught me.  Every day.  It has made all the difference.

## The Same Game, With a Pager

That's the whole philosophy, and it ports straight to technology — because technology is rule-based problem solving too, and Murphy is the opponent who never has an off day, never gets tired, and almost never, ever lets it be *your day*.

[Every moving part in a system is a bet, and the house always wins given enough time](/blog/can-vs-does). Anything that can go wrong will, given enough opportunities. If you bet on success — the clean deploy, the vendor that stays up, the disk that won't die, the hero who's awake — you collect nothing when you're right and lose everything when you're wrong. Tiny upside, unbounded downside. You only take that bet because you've talked yourself into believing it can't go bad.

Choi never believed that, and neither do I. I assume the deploy breaks, so [the rollback is a `git revert` and the system heals itself](/blog/ddcri). I assume the disk dies, so the backup is real and I've restored from it on a schedule — because a backup you've never restored is just a rumor. I assume the one person who knows the system is asleep, so [the playbook is written down and anyone can run it](/blog/stop-holding-out-for-a-hero). I assume the engineer at the keyboard is tired, at 2 AM, taking the shortest path — so the shortest path had better be the safe one, because that may be the only engineer who actually shows up to the incident.

Lay the system out so that whichever way it breaks, you win.  That's the cheese on the trap.  See if Mr. Murphy is hungry today.  Maybe he is, maybe he's not.  You don't need to care.  The failure is cheap, obvious, and recoverable. 

The game was never to prevent failure — you can't. The game is to make losing survivable, so you can afford to keep playing.

## The Asymmetry of the Bets and their Outcomes

At bottom this is a treatise about being wrong, betting wrong, because you will.  Everyone's predictions mostly turn out to be wrong. Shit happens.  The universe is an imperfect place at best.  Try as you might, you don't get to choose success.  The only thing you get to choose is the direction of your error and what it costs when you are inevitably wrong.

Bet on success and be wrong: catastrophic surprise, and the bill is everything you didn't prepare for. Unbounded. 

Bet on failure and be wrong: pleasant surprise, and the bill is some preparation you didn't strictly need. Bounded, and cheap. 

One error mode ends companies. The other ends with "huh, that went better than I thought," and a backup you never had to touch.

Same question, scaled up: *do you want to bet your nose on that?* In the studio, the 'nose' is your actual nose. In production, the 'nose' is the business. Either way, the clever move stops looking so clever the moment you say the stake out loud.

When you can't control whether you're right, control the *cost* of being wrong. [Getting better at optimism doesn't fix that](/blog/the-best-dog-trainer) — it just makes you more confident as you walk into the same wall. 

The fix isn't a sharper forecast. It's a stance that wins whether the forecast holds or not. Choi's stance.  Plan to be wrong.

## The Known Cost and the Imaginary One

This is also why people keep betting on success when they should know better — and in security and infrastructure work I hit it every single day. You are forever weighing a *known* cost against an *imaginary* one. The known cost is concrete and immediate: the dollars, the hours, the effort to build the backup, wire the rollback, stand up the replica, run the drill, secure the platform. The imaginary cost is whatever happens if you don't — hypothetical, deferred, and trivially easy to wave away. *That won't happen to us.*

People are wired to dodge the real bill and discount the imaginary one. The benefit is legible; the cost is illegible, and we discount what we can't see — [normalcy bias](https://thedecisionlab.com/biases/normalcy-bias), the quiet certainty that tomorrow will look like today, handles the rest. Roughly four out of five people freeze on exactly this when the disaster finally shows up.

Then incentives make it worse. A manager rarely spends a known budget to prevent an imaginary catastrophe — partly because imagination wasn't in the job description, and partly because of the calculation nobody says out loud: *it might not go down on my watch.* The bill comes due eventually, but maybe not this quarter, and maybe not while they're still in the chair. The person who pays for the bet is seldom the one who placed it. That isn't stupidity. It's a rational trade of a real, present cost for a deferred, someone-else's-problem one.

The trouble is that the imaginary risk is not imaginary. It has names and numbers. One of them is Knight Capital.

On August 1, 2012, Knight Capital — the largest retail market-maker in the United States at the time — pushed a new release to its trading system by hand, across eight servers, and missed one. The new code reused an old feature flag that, on that one un-updated server, woke a dead piece of test code from years earlier — code nobody had bothered to delete. At the opening bell it began firing millions of erroneous orders into the market, buying high and selling low in a loop with no limits. Forty-five minutes later the firm had lost about $440 million and was effectively finished. The warning even fired — 97 automated emails naming the fault — into an inbox nobody watched. Every known cost they had declined to pay — automated deploys, deleting dead code, a real kill switch, alerts wired to a human — was cheap. The imaginary cost they kept deferring turned out to be the entire company.

## Keep a Spare

A display adapter died on me last week — mid-workday, no warning, the one driving my monitors. It cost me five minutes, because there was a spare in a drawer. There was a spare in the drawer because *of course* it was going to die. Everything in that drawer is there because I assumed, the day I bought it, that the working one would fail at the worst possible moment. It did. I was ready.

People call that paranoia. It isn't. Paranoia is fear without a plan. This is the opposite: I've made peace with the fact that things break, so I don't fear it — I provision for it and stop thinking about it. The optimist spends his calm believing it won't happen and his crisis discovering he was wrong. I spend a little up front and buy calm on both sides.  

Preparedness is more expensive than just-in-time supply chains.  A spare adapter, server, or disaster recovery site are all, by definition, 'wasted cost' — until they save you.

So gamble on failure. Expect every move to be blocked. Expect the disk to die, the vendor to vanish, the deploy to break, the hero to quit, the adapter to cook itself on a Tuesday. Put some cheese on the trap, see if Mr. Murphy goes for it.  Maybe he will, maybe he won't, but **you don't want to have to care** whether he does or not.  Build so that every outcome favors you, and then go live your life — relaxed, prepared, and wrong just often enough to be delighted.

The house always wins. So does the master — you are not going to beat either one, so forget about trying. But if you take it as an absolute that the hit is coming — you just don't know when — you can prepare for it, and preparation is the whole difference between getting carried out and walking away with a spring in your step. 

That isn't betting against yourself. It's the only way anyone ever survives the house — or a tiny little man who hits like a granite boulder.
