That's what we call 'GitOps'.  If it ain't in git, it ain't running in our infra.
12:19
By adopting GitOps we have a full audit log back to the beginning of the project and simulaneously a mechanism for recreating this setup - and making new ones too!
12:19
cos the 'design' is not just human readable (for values of 'human' and 'readable' ￼ ) it's also machine executable.
12:20
This is part of why I advocate for things like Markdown and Git over say, Confluence.  Confluence might be 'human readable', but it's a dead end, as it is neither portable (Atlassian wants to keep you), nor is it machine executable.
A pernicious problem inherent in tool choice is we like to choose tools that make it appear like "the machine understands what the human means".  This is a lie.  They never do.
The tools that work best, and are the most synergistic require the humans to, at some level, learn how to talk to the machine.  Computers are dumb.  They do what they're told, but never know or care what you mean. (edited) 
12:21
Markdown, Git, Kubernetes (and many other tools) are force multipliers in that they allow for multiple systems to leverage the same sources of truth.  Work combines with work synergistically - the whole being greater than the sum of it's parts. (edited) 
12:21
i.e. we can do lots of cool things without hiring more engineers.