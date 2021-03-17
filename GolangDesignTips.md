# Golang Design Tips
Many of Golang’s ‘unwritten rules’ can be summed up by: [https://go-proverbs.github.io/](https://go-proverbs.github.io/)

I’ll give you my own extension/take on a couple of them here, along with some of my own recommendations.

## interface{} says nothing
Rob says it best in his video (link above), but in my simplified and more pedantic words:

Golang is a strongly typed language. Everything has a type. That type carries information that is critical to both you and the compiler to help you write better software.

If you use the ‘empty interface’ (`interface{}`) you’ve lost all meta information about this ‘thing’, and you’ve made it difficult if not impossible for the compiler and your IDE (if you use one) to help you.

Be more explicit. Help your tools help you.

Use ‘real’ interfaces. Your future self will thank you.

## A Little Copying is Better Than a Little Dependency

Labyrinthine interdependency with other repositories becomes a mess eventually.

Face it, we want to be so big that there are a bazillion ‘things’ in play out there. Do you really want to grok (and maintain) that graph?

I worked for a shop once that followed the principle of DRY (Don't repeat yourself) so aggressively that we couldn't update/upgrade/change _anything_ without it breaking production.

Copy and paste can absolutely be misused and overused. So can aggressive reuse. Strike a sane middle path!

## Clear is Better Than Clever

At some point, your code will be looked at by a mentally deficient individual. Does that statement shock you?

Some day, someone who is not as smart as you are is going to have to look at, understand, debug and maintain your code.

It could be a junior dev. It could be a contractor. It could be you at 3AM when something is down, people are screaming, and you have to FITFO (Figure It The, ahem Fun? Out).

Do everyone a favor, including your future self, and don’t have an attack of the clevers. The next time you read this code you may not have the flash of insight you had in your moment of brilliant design nirvana. Keep it simple, keep it clear. You’ll thank yourself later. (And all of the rest of us will too!)

## Errors Are Values

Golang is rife with the construction:

    if err != nil {
        // do something here
    }

Golang’s error handling is not just ‘Try/Catch’ with some different syntax.

The value is useful information. Don’t just check it enough to satisfy the compiler or make the program continue. Use that value

## Don’t Just Check Errors, Handle them Gracefully

As said above, Errors are Values. When you construct your error handling routines, take the time to make them useful.

Don’t do this:

    thing, _ := SomethingThatReturnsThingAndErr()

You’re just skipping the error. This will be hell to debug later when the excrement hits the rotary impeller.

Or this:

    if err != nil {
        return err
    }

Now you’ve caught the error, but you’ve added zero context.

You’re taking an error that was created by the package you’re using, and mindlessly handing it up to the calling context. It might be understandable, but more often it will also be hell to debug later.

There’s a great package, github.com/pkg/errors that I personally use all the time. It allows you to wrap and error with more information. Personally I use this all the time. An example:

    thing = "foo"
    err := DoSomethingWith(thing)
    if err != nil {
        err = errors.Wrapf(err, "failed to do something with %s", thing)
        return err
    }

This is much more useful. You’ve added context to the error.

Now, especially if you made your wrap statement provide specific information, you can search your codebase for that statement, and voila! You now know where the error came from. Command line tools such as grep are crude perhaps, but they’re also very very useful.

## Don’t Panic

Relying on Golang’s panic (a runtime error where the program just stops) is just lazy.

Make your errors useful, bubble up some pertinent information.

Panics are failures on your part as a programmer. They will happen, but they are indicative of a case where you should have put a little more work in.

## Return Early

Golang generally avoids things like ‘else' (Though it’s totally legal syntax) and prefers to return from a function early.

Check your errors, and bail out of the function as soon as you find one that you can’t handle, providing the calling context with information that will help your user help you figure out WTF went wrong.

## Write Golang as Golang

Golang is a weird language.  Some parts of it are crazy.  Other parts are crazy like a fox.

If you look at the 'main sequence' of computer languages, from ASM to C to Perl, to Python to Ruby and to Java, there is a definite progression as the field advanced. Many things are easy to do in Python and Ruby because Perl came before, and people thought "Aha!  We can do better!".

Golang is off this 'main sequence'.  It's way off in left field in many ways. Take for instance Golang isn't Object Oriented, though its syntax looks very OO-ish.  

Golang is actually an "Interface Oriented Language".  Stop.  Go back and read that again.  Honestly that needs to be written in flashing letters in the Golang docs.

To really understand what an "interface oriented language" is, you'll have to dig into golang, and golang's interfaces.  If you spend some time there, you'll see what I mean.  It's superficially close to OO, but fundamentally very different.

Why am I rambling on about this?  What's the point?

The point is you need to write golang as golang, not as C, or ruby, or python, etc.  Each language has its synatx, but also it's _idiom_.  You have to learn both, else you're missing out on the features that make each language worth using.

Packages in golang are another good example.  All to often people build these labrynthine package trees, and shit gets complicated real quick.  Then you need extra tooling like [mage](https://magefile.org/) to build things. I'm not knocking the developers of Mage.  I'm sure they're lovely people, but if you keep your golang packages flat, you don't need it.  

I'm reminded of an anecdote from the early days of Git and Mercurial.  It went something like this:  "If you have a simple build and release process, you probably only need Mercurial.  If your release process is so complicated that you need the extra control that Git provides, you should probably go back and rethink it.".

Follow the K.I.S.S. principle.  Keep It Simple, Stupid.  Your co workers, maintainers, and future self will thank you.


