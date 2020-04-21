# MVC-ish

I’m a big fan of MVC like patterns.  I say ‘MVC-ish’ because you could look at how I implement it and lecture me that it’s not “Proper MVC”.  

Whatever.  I’m trying to demonstrate a principle, and I’m pointing to the closest similar concept I can find.

What I mean is this:  I try to write libraries.  Libraries should be as general purpose as possible, and exhaustively tested.  Libraries are the Model of the MVC pattern.  

Models are generally specific to the job at hand, and as such, don’t change much.  Views on the other hand can change all the time, and you generally should plan on having a one Model to many Views relationship in your programs.

Models should consume data, and produce data.  They should not include any sort of assumptions as to how or where that library will be used.

Specifics of how the data is presented, consumed, or displayed is the province of your View.  A web page is a view, so is a CLI.  Huh?  Yes, a CLI is just a view.

Often a CLI is the quickest and easiest View to slap on a Model, but it’s not necessarily the only one.

A good library/model should be able to be exercised in many ways- by a CLI, by a web page, by other packages.  Design this way and you’re doing your future self (and the rest of us too) a big favor.

When you follow the suggested package layout above (in golang anyway), this means the meat of your code will likely live under /pkg/<name>, and your CLI will be under /cmd.  The files under /cmd end up being an object lesson on how to exercise your libraries in /pkg.

Here’s an external example of what I mean using a tool called gomason.  The purpose of gomason is to build, test, sign, and publish binaries easily based off a config file:  [https://github.com/nikogura/gomason](http://nikogura.com/MVC-Ish.html)

You’ll note that publish.go  is just calling functions in [https://github.com/nikogura/gomason/tree/master/pkg/gomason](https://github.com/nikogura/gomason/tree/master/pkg/gomason).  The functions, however, being under /pkg are fully available to be used by other libraries.  

The gomason tool only has a CLI view at this point in time, but there’s no reason why someone (maybe you!) could add a web UI to make it even more useful, adding an additional mechanism of exercising the same code.