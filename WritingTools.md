Scripts should be useful
nothing wrong with cobbling things together with ‘glue’ or ‘bare commands’.
First off
one should not have to be the author (or of equivalent knowledge/background) to USE a script.
i.e. a script/program/tool should be just that- a tool
it should make it easier to do somethign
or make it faster to do something
or give someone the ability to do something that was otherwise out of their reach
So, absolutely use bare commands.  Hell, type `history`, and you’re effectively looking at a script.
just one you wrote inadvertently over time and only looked at afterwards
Any tool you make should conform to the Principal of Least Astonishment
that is, it should behave in whatever manner will astonish your users the least
It’s default usage should be the most common/likely/obvious use case
and it absolutely should be able to accept flags or options or such to do really wild things, but such should not be required to use it at all.
so whether you should do fancy classes and stuff or just do ‘bare commands’, depends on what you’re doing
Nothing wrong with a crude baby step if it makes something easier to do
or easier to remember what to do
MVC-ish is the best pattern long term, but often that’s not something you have time/interest doing for a quick one off
but you should absolutely try to get used to that pattern
The more you use it, the easier/faster it will become
and then you start to accumulate these libraries (and tests!) with or without interfaces
open source as many of them as you can
cos after you have a critical mass of shtuff lying around it’s like putting legos together, and people will be amazed by how fast you ‘work’

First we make work, then we make work well.  This is the Way.
The trick is writing it in discrete steps/components so that you can easily and quickly refactor it later when you have time/interest.
If you can make it easy on your self to do in 5 minutes here or there (that’s what testing helps do), you’re more likely to FIND time to refactor it


I want us out of the business of having to manually make builds.  Someone- QE, Product, whomever aught to be able to push a button and have it just work.

Akash:
Yes, with the approach I am suggesting any one can build the images without any special assistance, it will just require updating a config file and making a commit to trigger the build.

Updating a config file and making a commit are too much to ask product and or QE.

I'd rather see it captured in a library we can exercise from a CLI or from a web page.

I really want us out of the business of deployments.  They're always a distraction for us, and a delay for the product folks.

Akash:
The reason I am not very keen on creating a golang tool for it is because of the dependency we have on packer scripts. Even if we build a cli tool it will also end up doing a packer build packer-script.json only. (edited) 

Nik:
what's wrong with that?

What you're doing is making an interface that makes it easy for people to do exactly what we want them to be able to do via indirect selection.

'everything' is both too many permissions, and too many options for the target audience.  Too much complexity.  Too many chances for syntax errors, et al.

By wrapping it in an interface, we allow them to pick from a set of pre-defined options.

I agree, writing a bunch of code in golang to shell out and run packer build is crude, but due to it's compiled nature it freezes the options we want into a known set

It would certainly be more elegant to use the packer libs directly, but time is short, and we don't always have time for 'perfect'

by essentially scripting packer, you're providing new abilities to people who would otherwise not be able to access the system, while simultaneously setting us up to be able to 'do it better' in the future

Give people the ability to self service.  This makes them happy cos they can do their jobs.  This makes us happy because we don't get interrupted.  Do so in a way that contains discrete parts that can be replaced at need with a 'better version'.  Don't worry if some of the 'glue' is less elegant than we'd like.  If the abstractions/interfaces are well designed, we can replace them in the future at need.  Enable users, enable ourselves. This is the Way.