# TDD (Test-Driven Development)

## What 
TDD  is the coolest thing since sliced bread.  Maybe even since before that.  [Wikipedia](https://en.wikipedia.org/wiki/Test-driven_development) has a good, if dry explanation.  Read it!

I'll add that it's not so much that you *have* to write the tests *before* the code- which let's face it- is often a pain in the neck, especially if you're writing something new, and you're not sure yet which direction you're going.  

It's more that you need to alternate between tests and code.  Why?  Partially so that you actually *write* the tests and not forget about them in the rush to get a MVP going, but also so that you write code that *can* be tested.  

This is huge.  Rigorously following TDD as much as possible makes you write code in discrete units that you can test individually at first, and then later in groups.  It's absolutely priceless for finding problems quick, fixing them, and developing confidence about the state and reliability of your code base.  

## Why

Think about it this way.  How do you know that a line of code works?  You test it somehow.  You can eyeball it, and that works great, but once you're done, that test is lost.  It could be repeated, but only by someone with the time and knowledge to look at it and know that it's working correctly.

If instead, you teach the computer how to spot that thing you just eyeballed, why, then that test goes into the pile and we've forever captured that insight.  We can run it every time we run the test suite.  We can check that potential regression every time we examine the code, both personally and on the CI server.  Very quickly these little 'obvious' tests (which are not always obvious to people not as into the problem space as you are when you're writing the code) pile up and soon we have a really strong code base that we can trust.

So, please write tests.  Lots of them.  Any time you have something of interest that you'd want to check, teach the machine how to test that thing, and we'll all benefit.

## How

I actually do most of my development work (Java, Python, Chef) in tests.  I acquired the habit in Java Spring development, where getting the same thing that's happening in your IDE to work on the command line or on the CI server- thus proving it actually works- can be a real trick.  It's possible, but it's painful, and you really don't want to do it.  Once I got used to it, and started to depend on the benefits of TDD, I realized it applies equally to any language.

I'll write code in a test- even if it's something quick, dirty or experimental, hit shift + f10 (which in IntelliJ runs whatever test you have activated in the testing dropdown) and watch it go red or green out of the corner of my eye while addressing the next task.  

In the beginning, I'll just print to STDOUT, and eyeball the result (it shows up in the test results window).  Then I'll put the things I'm eyeballing into test fixtures that output the 'right answers' and change the test to compare A with B.  That way, every 'eyeball operation' is captured for posterity.  'Posterity' being me 10 minutes later when I decide to refactor things radically in response to the moment's latest 'great idea', and now I have to be sure the rest of the code still works.

It works well while exploring a new API- something I seem to be doing all the time.  My 'investigation' is saved, so when I'm distracted by a question or request from a colleague I don't lose as much ground.  The commands or constructs I'm exploring are easily copied from the test into the library I'm writing with a couple of keystrokes (I'm addicted to the IdeaVim plugin.  Even though I'm using an IDE, my fingers think I'm just using Vim).

Once the code is massaged into it's finished state, that whole investigation becomes frozen as a real test.  It's a great way to capture your output.  Your investigation history is there, captured in code.  It's way more intelligible than digging through your bash_history or trying to recall *how* you did that clever thing you seem to recall doing last week.  

I can't tell you how many times I've gone back and read my tests to remember how exactly I intended a project to work.  This applies to other people's projects too.  One of the first places I look to figure out how a library works (after our buddy google that is) is it's test suite.  If it's a reputable project built and maintained by dedicated professionals, it will have a comprehensive test suite.  Real developers write tests.

Once your IDE is configured to use the correct interpreter or environment, the tests will use that env by default- and the CI system is also set up to build and use the same env checked into the project (via requirements.txt or pom.xml, et al.).  We all stay on the same page by default, and most everything *just works*.

Anyway, that's the speech.  If you're going to contribute to a project I'm steering (and the more the merrier), please write tests to go along with your code.  If you don't, not only are you tragically uncool (all the cool kids write tests), but if I'm reviewing your contribution, I'll reject code that doesn't include solid tests.  I'm a jerk that way.

## Resources
* [Wikipedia](https://en.wikipedia.org/wiki/Test-driven_development) - Good explanations, if a little dry.  Don't let it scare you.
* [Test-Driven Development By Example](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) - It's only available in the dead trees version.  I wish this was available in an electronic format.  Maybe someday.  I've seen other books that have been searched for over and over eventually converted to ebooks.  The [Preface](https://books.google.com/books?id=CUlsAQAAQBAJ&printsec=frontcover&dq=isbn:9780321146533&hl=en&sa=X&ved=0ahUKEwi67ayQ94LPAhXLJR4KHbQzANkQ6AEIHjAA#v=onepage&q&f=false) is available online however, and is a great read.  Check it out.
* [Test-Driven Development with Python](http://shop.oreilly.com/product/0636920029533.do) - This one is good too, but it's written for use with Django, (a web framework) and Selenium (A web browser automation engine).  Both are great tools, and it's a great source of technical and philosophical information, but for the beginner it can be a steep learning curve.
* [Behavior-Driven Testing](https://en.wikipedia.org/wiki/Behavior-driven_development) - TDD taken to the next level, and expanded beyond pure code.
