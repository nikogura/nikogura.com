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

In Golang, the `pkg/` directory is intended to contain code that can be re-used by other programs.  In contrast, the `internal/` directory is for code that should never be reused.  In fact, the Golang compiler will flat out refuse to import anything from an `internal/` directory.

While there are certainly cases where code should never be reused, generally speaking this is a pattern to be avoided.  Reusing code is a huge time saver, and writing code that can be reused is just good design principles.

If you don’t have an astoundingly good reason for using `internal/` put everything in `pkg/`.  Putting your code in `internal/` only prevents use by other programs.  It doesn't provide any security or privacy benefits.  Decompiling is trivially easy, so it's not as if you're keeping any secrets.

You can say "Nobody will ever need to use this code.", and you may be right.  Why limit yourself though?  If it truly has to be private, stick it in a private repo.  Otherwise, leave it flexible and open.

Yes, I can hear you saying, if you're writing a big public repository it can be good to section off some internal code that you don't want people messing with or depending on.  I won't argue with you.  That can be a good thing.  You also may be making excuses for being sloppy.

You're better off in the long run taking the extra time and laying out good, useful, reusable code and not depending on the difference between `internal/` and `pkg/`.  It's not always possible.  It's not always reasonable.  I don't always follow it either.

Just because I *know* the path doesn't mean I always *walk* it.  Doesn't make it any less true.

## Public vs Private Variable and Functions

In Golang, a variable or function is public if it starts with a capital letter.  It’s private if it starts with a lowercase letter.

If something is public, it can be accessed outside your package.  If it’s private, it cannot.  

As no doubt you can guess by reading the above, I'm not much in favor of private variables or functions.

Sure, they have their place, but if you cannot absolutely say "This is why this needs to be private", make it public.  Why lose flexibility if you don't need to do so?

In my martial arts career I would often teach people 'rules'.  I would also teach people the exceptions to the 'rules'.  

The moment people learn of an exception to a rule, they try to apply it everywhere.  I don't know why.  My daughters do it too, so it's probably human nature.

What I say about exceptions - in coding, in martial arts, and in life is this:  if you don't know why the exception exists, and why it specifically applies to *this* situation,  follow the rule.  Using an exception when you don't know exactly why you're using it means you're probably using it wrongly.

The rule, in my not so humble opinion, is make all functions and variables public.

Don't impose restrictions on your future self unless you can articulate and defend a very good reason for doing otherwise.

This is especially important if you're coming to Golang from another language.  Some of Golang's error messages are really esoteric and hard to follow for the beginner.  Words you think you know are used in _slightly_ different ways, and they'll bite you.

Later on, when you have really gotten your head around this weird thing called Golang, you'll know why some things should be private, and you won't have any misleading warnings from the compiler to make you tear your hair out.


## MVC-ish or SOLID Engineering in Golang

Face it.  You'll never have enough time, energy, or attention.  This is a given in our field.  If you ever did have enough, you'd soon be promoted, or change roles and voila!  You no longer have enough.

The trick for gaining enough resources to figuratively move mountains lies in how you lay out and organize the work you do.

When you write, write it so you can reuse it.  Don't tie anything you do to a specific implementation or use case.  Leave the door open.  You never know what's coming around the corner.  If you're smart, you'll leave yourself little 'nuggets' of functionality lying around like lego blocks in the wake of my kids.  Unlike my living room in the middle of the night, blundering into these building blocks won't be painful, instead you'll be positively delighted.

What I'm talking about here are basically the  [SOLID](https://en.wikipedia.org/wiki/SOLID) principles of software engineering.  The concepts have been around forever.  While SOLID was specifically written for Object-Oriented Programming (And Golang isn't OO), the principals remain the same, and will save you time and again if you adopt them.

SOLID goes back to the early 2000's, but much of the philosophy as existed since the dawn of computing.  The 'S' in solid: Single-Responsibility Principle, is just another of stating "The Unix Way", which is to do one thing, and do it well.  In the words of [Ron Swanson](https://en.wikipedia.org/wiki/Ron_Swanson) "Don't half-ass two things.  Whole-ass one thing.".

MVC, or "Model - View - Controller" is another example of this principle.  The 'Controller' part of MVC is a little specialized to programs that need to route traffic, but the Model and View bits apply everywhere.  The trick is to not mix them.

## Libraries

When I write code, I try to write libraries.  Libraries should be as general purpose as possible, and exhaustively tested.  Libraries are the Model of the MVC pattern.

A good Library / Model should be able to be exercised in many ways.  The same Library can be used by a CLI, by a Web Page, by other programs via a Web Service.  They can also be leveraged by _other people_.  People who can _help you get things done_.  

* Libraries / Models are generally specific to the job at hand.  Once written, they don’t change much unless the business fundamentally changes.

* Libraries / Models should _consume data_, and _emit data_.  They should not include any sort of assumptions as to how or where that data will be used.  

* Libraries / Models should be exhaustively tested.  When you write a piece of code, you know what your intention is.  You know how you think it should perform.  Take the time to _teach the computer to verify that your expectations are met_.  That's what 'automated tests' are.  You're just teaching the machine to a) know what 'working' is, and b) teach it how to test itself. Later when you make 'one little change' to this fundamental code, your tests will be your life saver.


## Views

Views on the other hand can change all the time, and you generally should plan on having a one Model to many Views relationship in your programs.

Specifics of how the data is presented, consumed, or displayed is the province of your View.  A web page is a view, so is a CLI.  Huh?  Yes, a CLI is just a view.  It's just one way of interacting with the data in the Model.

Often a CLI is the quickest and easiest View to slap on a Model, but it’s not the only one, nor is it necessarily the best.


## Tests

Don't hesitate to write what you might be tempted to call 'stupid tests'.  There is no such thing.  A simple test that concatenates strings, or trims a suffix might seem 'stupid', but it takes about 90 seconds to write, and once it's done it lives in your codebase forever.

That little 'stupid' test will save you down the road.  If it doesn't, it didn't hurt you in any way.  There are no stupid tests, and they're always worth the extra few seconds it takes to write them.

Little things, like atoms, molecules, and lego bricks build up.  One or two are not particularly impressive, but once you have a pile of them, they add up.  As they say, "No raindrop feels responsible for the flood."

In Golang, this means the meat of your code will likely live under /pkg/<name>, and your CLI will be under /cmd.  The files under /cmd end up being an object lesson on how to exercise your libraries in /pkg.  Never mix the two.

Design this way, and you’re doing your future self (and the rest of us too) a big favor.

Here’s an external example of what I mean using a tool called gomason.  The purpose of gomason is to build, test, sign, and publish binaries easily based off a config file:  [https://github.com/nikogura/gomason](https://github.com/nikogura/gomason)

You’ll note that publish.go  is just calling functions in [https://github.com/nikogura/gomason/tree/master/pkg/gomason](https://github.com/nikogura/gomason/tree/master/pkg/gomason).  The functions, however, being under /pkg are fully available to be used by other libraries.

The gomason tool only has a CLI view at this point in time, but there’s no reason why someone (maybe you!) could add a web UI to make it even more useful, adding an additional mechanism of exercising the same code.
