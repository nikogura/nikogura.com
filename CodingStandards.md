# Coding Standards (especially in Golang)

This rant is at the surface about code best practices ('best' as defined by me of course.), but it's really about design philosophy and how I try to approach my work.

## Code Privacy and Reusability

As a general principle, every line of code you write should be as general as possible, and should be to a standard that you’d be proud to publish it under your own name, or under your company's name.

That’s not to say all code repos are candidates for publication or release as open source- far from it.  However, even though a repo will ‘never see the light of day’ we owe it to ourselves and our successors to write and maintain it to that same level of excellence.

Git is forever.  If your name is on it, it should be an object lesson in coding excellence.  Sure, this is not always possible, and we cannot let the ‘best’ become the enemy of the ‘good’.  We can, however strive to achieve this (perhaps impossible) goal in everything we do.

Good code is commented, documented, has thoughtful variable and function names, has tests, and is laid out in a fashion wherein it is easy to reuse and refactor.

If you write your code this way - even if you’re not necessarily planning on publishing it you'll enable something very powerful:  You'll be able to refactor it quickly and easily in small units of 'free' time.

This is key.  Everybody knows about 'refactoring'.  Most coders would admit that their first draft of _anything_ will suck.

How do you produce functional things quickly, and yet avoid technical debt our mounds of unintellible code?  The answer is by paying it forward and making it easy for your future self to take a moment and swap out some nasty kludge with something more elegant.

Odds are any decision you make at any one point in time will be a mistake in the light of hindsight.  Rather than let this paralyze you however, embrace it!  Write stuff that's easy to swap out in 5-10 minutes of free time.  'Waste' time writing tests of your kludge so that you can prove that given this input, you get the output you need.  Doing so enables quick and confident refactors down the road.

Technical debt doesn't get paid down due to a lack of desire.  Most of the the time an engineering team would *love* to get rid of that nasty spaghetti code.  It doesn't get addressed because of a lack of time and resources.

Front load your pain by writing tests, and by making your code modular.  You'll find that if it's easy to refactor in a few minutes - and prove by testing that your refactors work - then it will get done.  We humans avoid the 'hard' work.  Make refactoring easy.

Do it right the first time.  Every time.  Even if it 'doesn't matter'.  First off, you don't necessarily know what will matter in the future.  Shit happens.  Things change.  Secondly, and perhaps most importantly, 'doing it right' is a muscle.  The more you flex it, the stronger it becomes.  There is absolutely a tradeoff between doing it better and doing it faster.  Get this though:  the stronger you make that 'muscle', the easier/faster it is to flex.  You get faster at doing better, and better at doing faster.

That's what we call 'mastery'.  The master in any field can produce master-level work with less effort than it takes the apprentice to pick up the tools.  That's what 'mastery' means.  Work that muscle and become a master in your own right.

(and yes, you SJW's out there, I used the 'm' word - and used it in not only an innocent context, but in an entirely appropriate, proper, and historical fashion - that of someone who has attained complete knowledge or skill in their subject.  I use words to convey ideas - the ideas *I* mean to express.  Nothing more.  Nothing less.  Whatever else you try to read into it is your problem, not mine.)

## Code Paths

In golang, the pkg/ directory is intended to contain code that can be re-used by other programs.  In contrast, the internal/ directory is for code that should never be reused.  In fact, the golang compiler will flat out refuse to import anything from an internal/ directory.

While there are certainly cases where code should never be reused, generally speaking this is a pattern to be avoided.  Reusing code is a huge time saver, and writing code that can be reused is just good design principles.

If you don’t have a really good reason for using internal/ put everything in pkg/.  Putting your code in internal/ only prevents use by other programs.  It doesn’t provide any security or privacy benefits.

You can say "Nobody will ever need to use this code.", and you may be right.  Why limit yourself though?  If it truly has to be private, stick it in a private repo.  Otherwise, leave it flexible and open.

Yes, I can hear you saying, if you're writing a big public repository it can be good to section off some internal code that you don't want people messing with or depending on.  I won't argue with you.  That can be a good thing.

You're better off in the long run taking the extra time and laying out good, useful, reusable code and not depending on the difference between `internal/` and `pkg/`.  It's not always possible.  It's not always reasonable.  I don't always follow it either.

Just because I *know* the path doesn't mean I always *walk* it.  Doesn't make it any less true though.

## Public vs Private Variable and Functions

In golang, a variable or function is public if it starts with a capital letter.  It’s private if it starts with a lowercase letter.

If something is public, it can be used outside of your package.  If it’s private, it cannot.  

As no doubt you can guess by reading the above, I'm not much in favor of private variables or functions.

Sure, they have their place, but if you cannot absolutely say "This is why this needs to be private", make it public.  Why lose flexibility if you don't need to do so?

In my martial arts career I would often teach people 'rules'.  I would also teach people the exceptions to the rules.  

The moment people learn of an exception to a rule, they try to apply it everywhere.  I don't know why.  My daughters do it too, so it's probably human nature.

What I say about exceptions - in coding, in martial arts, and in life is this:  if you don't know why the exception exists, and why it specifically applies to *this* situation follow the rule.  

The rule, in my not so humble opinion, is make all functions and variables public.  Don't impose restrictions on your future self unless you can articulate and defend a very good reason for doing otherwise.  Your future self will thank you for the consideration.