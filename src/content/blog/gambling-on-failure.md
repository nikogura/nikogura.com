---
title: 'Gambling on Failure'
excerpt: Most people gamble on success — they assume the thing will work, and they're genuinely surprised when it doesn't. A tiny, birdlike kung fu master taught me to gamble on failure instead. Expect every move to be blocked, and win anyway. It turns out to be the same discipline that keeps systems alive at 2 AM.
publishDate: 'Jun 26 2026'
tags:
  - Philosophy
  - Engineering
  - Martial Arts
isFeatured: true
---

## Two Kinds of Gamblers

Everyone is gambling. Every plan, every deploy, every architecture, every hire, every fight, every Tuesday — you are betting on an outcome you do not fully control. Shit happens.  We all know it.  The only real question is which way you bet.

Most people bet on success. They believe it will work. The deploy will go clean. The vendor will stay up. The one database with no replica will keep spinning. The hero will be awake and respond to an emergency page. And because they believe it, they are *surprised* when it doesn't — surprised by the outage, the breach, the dead disk, the punch they never saw. The surprise is the tell. Surprise means you bet on success and the house collected.

I prefer to bet the other way. I expect it to fail. And when I'm wrong — when the thing actually works — I am *pleasantly* surprised. I try to arranged my life so that all of my surprises are good ones.  I still get bad surprises of course.  Nothing and no one is perfect.  Sometimes I get a chance to feel smart and prepared.

That isn't pessimism. It's the only bet where the odds run in your favor. And I learned it, of all places, by getting hit — repeatedly — by a man I outweighed by more than a hundred pounds.

## Energy and Time

Before I was an engineer, I was a professional kung fu instructor. The two careers look unrelated until you notice they're the same activity: **rule-based problem solving.** A fight and a distributed system are both bounded spaces where a finite set of pieces interact under fixed rules, and the discipline in both is figuring out which moves actually pay off under pressure — and which ones just look good in the brochure - or the sales pitch.

"Kung fu" literally translates as *energy and time*: skill bought with work. And that's exactly the trap, because most martial artists gamble on success on the strength of their hard work. The assumption is seductive: *I'm the one who trains. I'm the athlete. I put in the energy and the time. When it comes to it, I will prevail.*

Sometimes that's true. Often it isn't. The other person is just better — younger, faster, meaner, who knows. There's always a roll of the dice; some days you're lucky, some days you're not. And here's what the martial arts world doesn't like to admit: not all skills are martial, and not all fighting is skillful. Sometimes you just run into a natural 'junkyard dog' who never trained a day and will clean your clock anyway.

The movies make it worse. They sell the low-probability tactics — the jumps, the spins, the flips, the spinning back kick to the jaw. Another teacher of mine had a name for the whole category: ["your day" moves](/blog/can-vs-does). Would a jump kick work? Sure — if it was *your day.* And if it wasn't, you'd just thrown both feet off the ground in front of a stranger and turned yourself into a committed, airborne, off-balance target with nothing left to do but hope it turns out well. Beautiful, and almost never the right bet. The sucker punch beats the jump kick nearly every time, and hope is not a strategy.

I put it to my own students more bluntly: *"Do you want to bet your nose on that?"* Because that's the real stake. If you're right, great. If you're wrong, you've got a broken nose. It's remarkable how many plans stop sounding clever the moment you say out loud what they cost when they fail. KISS isn't only an engineering principle; it's a survival one — the simple thing, done when it counts, beats the spectacular thing that needs everything to go right.

## "Put Some Cheese on the Trap"

Then I met a master who had thrown the whole assumption out. He gambled on failure.

[Wai Lun Choi](https://liuhopafa.com/master-wai-lun-choi). Maybe five foot nothing. Claimed to weigh 140 pounds — *maybe*, soaking wet with rocks in his pockets. The most intimidating birdlike little man I have ever met: a thick Cantonese accent and a sense of humor so offbeat that talking to him was like talking to Yoda. I'm 6'2" and 300 pounds. He barely came up to my shoulder. It did not matter in the slightest. In his eighties, he did push-ups on his index fingers. I am not exaggerating in the least here.

What made him terrifying was that **he expected nothing he did to work.** He expected you to block him — every move. He was *counting* on it. "Put some cheese on the trap," he'd say, "and see if the rat is hungry."

Here's why that works, and it's the same insight that runs through everything I build now: the solution set is far smaller than people think. A human being has two arms, two legs, and one head. The knees and the elbows bend exactly one way. You have to stand on at least one leg or you fall over, and you can't lift a leg until you take your weight off it. That's the whole board. It feels like infinite possibility; it's actually a short list of constrained, predictable responses.

So Choi laid out the cheese. If you took the bait and blocked — which the rules of your own body all but forced you to — the trap closed. Your arms crossed, you tangled up, your weight shifted to the wrong foot, and your situation got worse, and worse, and worse, until you were simply done. And if you *didn't* block? He hit you. Like a Mack truck — nearly all 140 pounds arriving at once, and as often as not through a single fingertip on a precise pressure point. His "Dim Mak" didn't kill you, but it left you curled up on the floor, writhing in agony. He'd teach each point by doing it to you, so you remembered — almost nobody ever volunteered to learn more than one.

He was either right, or he was pleasantly surprised. There was no branch where he lost. He had engineered the failure of his own move into a win either way.

Sifu Choi never seemed to learn my name in all the time I studied with him — to him I was just "the Big Guy from Minnesota,".  It didn't matter though.  He knew who I was.  His memory was perfect for every conversation we'd ever had, and he was able to articulate amazingly fine points of physics, mechanics, anatomy and human physiology in terms that were not necessarily scholarly, but incredibly precise and accessible. 

I'll remembered him for the rest of my life. His picture hangs in my office, as it should.  He even signed it and referred to *me* as 'Sifu Nik'.  (So maybe he *did* remember after all.) Highest 'certification' I have ever acheived.  Grandmaster [Wai Lun Choi](https://liuhopafa.com/) taught Liu Ho Pa Fa ("Water Boxing"), Hsingyi, Pa Kua, Taiji, and Lama Pai in Chicago for decades; the lesson in this post is his, not mine. I just carried it into a different kind of fight.  

Thank you Sifu.  You changed my life.

## The Same Game, With a Pager

That's the whole philosophy, and it ports straight to technology — because technology is rule-based problem solving too, and Murphy is the opponent who never has an off day, never gets tired, and never, ever gives you *your day*.

[Every moving part in a system is a bet, and the house always wins given enough time](/blog/can-vs-does). Anything that can go wrong will, given enough opportunities. Bet on success — the clean deploy, the vendor that stays up, the disk that won't die, the hero who's awake — and you collect nothing when you're right and lose everything when you're wrong. Tiny upside, unbounded downside. You only take that bet because you've talked yourself into believing it can't go bad.

Choi never believed that, so neither do I. I assume the deploy breaks, so [the rollback is a `git revert` and the system heals itself](/blog/ddcri). I assume the disk dies, so the backup is real and I've restored from it on a schedule — because a backup you've never restored is just a rumor. I assume the one person who knows the system is asleep, so [the playbook is written down and anyone can run it](/blog/stop-holding-out-for-a-hero). I assume the engineer at the keyboard is tired, at 2 AM, taking the shortest path — so the shortest path had better be the safe one, because that's the only engineer who actually shows up to the incident.

That's cheese on the trap. Lay the system out so that whichever way it breaks, you win: the failure is cheap, obvious, and recoverable. The game was never to prevent failure — you can't. The game is to make losing survivable, so you can afford to keep playing.

## The Asymmetry

At bottom this is an argument about being wrong, because you will be — everyone's predictions mostly are. The only thing you get to choose is the direction of your error and what it costs.

Bet on success and be wrong: catastrophic surprise, and the bill is everything you didn't prepare for. Unbounded. Bet on failure and be wrong: pleasant surprise, and the bill is some preparation you didn't strictly need. Bounded, and cheap. One error mode ends companies. The other ends with "huh, that went better than I thought," and a backup you never had to touch.

Same question, scaled up: *do you want to bet your nose on that?* In the studio, the nose is your nose. In production, the nose is the business. Either way, the clever move stops looking clever the moment you say the stake out loud.

When you can't control whether you're right, you control the *cost* of being wrong. [Getting better at optimism doesn't fix that](/blog/the-best-dog-trainer) — it just makes you more confident as you walk into the same wall. The fix isn't a sharper forecast. It's a stance that wins whether the forecast holds or not. Choi's stance.

## Keep a Spare

A display adapter died on me last week — mid-workday, no warning, the one driving my monitors. It cost me five minutes, because there was a spare in a drawer. There was a spare in the drawer because *of course* it was going to die. Everything in that drawer is there because I assumed, the day I bought it, that the working one would fail at the worst possible moment. It did. I was ready.

People call that paranoia. It isn't. Paranoia is fear without a plan. This is the opposite: I've made peace with the fact that things break, so I don't fear it — I provision for it and stop thinking about it. The optimist spends his calm believing it won't happen and his crisis discovering he was wrong. I spend a little up front and buy calm on both sides.

So gamble on failure. Expect every move to be blocked. Expect the disk to die, the vendor to vanish, the deploy to break, the hero to quit, the adapter to cook itself on a Tuesday. Put cheese on the trap, build so that every branch favors you, and then go live your life — relaxed, prepared, and wrong just often enough to be delighted.

The house always wins. So does the master — you are not going to beat either one, so forget about trying. But if you assume the hit is coming, you can prepare for it, and preparation is the whole difference between getting carried out and walking away whole. 

That isn't betting against yourself. It's the only way anyone ever survives the house — or a tiny little man who hits like a granite boulder.
