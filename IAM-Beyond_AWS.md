# IAM Beyond AWS or *Hacking Hacks, and the Hackers who Hack Them*

I was handed a pretty problem one day.  It was simple.  It needed to be done.  It was as inevitable as death and taxes.  

What was this inexorible juggernaut of a task that was rolling towards me?  I needed to get a handle on AWS Credentials for our entire department.

Is that all?  Credentials?  Bah.  That's easy.  You poke around the AWS console screen and bob's yer uncle, yer done.  

Right?  Not so fast sparky.  Pull up a chair and lemme riff on this tale of woe.

## Total Freedom, on Rails

The Platform team of a company I've recently worked for has this wild idea.  We want to embrace total freedom for our data scientists to be their brilliant best selves and follow whatever flights of fancy they may discover in their febrile minds.  That's a pretty neat goal.  It aught to be thus for all users says I.

We also want things to *just work* and glide around with the style and elegance of a Tesla Model S.  That's hard to do when the cats refuse to be herded.  So what's a guy to do?

AWS Credentials for a goodly sized team of individualists was just a small microcosm of the bigger problem.  Everyone needed them.  Everybody wanted them.  Many already had them- several sets in fact.  How in ned were we gonna get a handle on them and manage it going forward?

Furthermore everything has to *just work* as stated above.  Data Scientists do not want to worry about securely maintaining credentials.  Neither does Management.  They have this weird idea that they have better things to do with their time.  I tend to agree. 

This is the thing about Security.  It sucks.  

Even if you enjoy the philosophical exercise of imagining how a system can be brought down, (and I do), running around frantically trying to cover every possible failure point and making sure **YOUR** system isn't brought down is 'effing miserable.  Who wants to live like that?

So a good system has to be secure, and relatively painless.  Ideally people will just do the right thing- without necessarily even knowing what the right thing is.  That's what we call *enablement*, and is what Platform Engineering is all about.  

We Platform Engineers don't really do anything useful.  Our job is to keep the painters painting.  It's the things they do with the brushes we give tham that makes the dough and wins the fame.

You don't get into Infrastructure if you want to be visible.  The only visible things here are the failures.  Blech.

## Relax, AWS Has You Covered... Somewhat

For a shop beyond a certain size, managing personal creds in the AWS IAM dashboard is too much of a hassle.  

Too many cooks in that particular kitchen makes for a big mess when Mr. BlackHat dude comes to call.  So there's a temptation to make it all flow through someone who's in control of all access, but there's a big problem with that too.  

That job sucks, bigtime. The only person you can hire to do such a job for any length of time either has no imagination, or is totally checked out, cos it's *boring*.  

While this mythical person might be a snappy dresser and a good dancer, they're not the person you want in charge of the keys to the kingdom.  Any person who *would* be a good person to put in charge of the keys will be bored silly.  Even if you can get them to take the job, they won't be there long.

## Enter AWS Security Token Service

This is not going to be a how to for everything AWS.  Amazon has ~~perfectly good~~  er, Amazon has ~~helpful~~, uh... Ahem.  Amazon has docs.  How about that?  [http://docs.aws.amazon.com/STS/latest/APIReference/Welcome.html]  I'm not actually knocking Amazon or their document writers.  They do a better job than I would do.  Among other things, I can't resist the urge to ramble off in some tangental direction....

Reading AWS Docs is a skill in and of itself though, kind of like reading man pages or javadocs.  They're good skills.  I recommend you develop them.  The learning curve can seem vertical at first.  Don't worry though, it levels off pretty quickly, and the only way to really get good at it is to just do it.

Anyway, one of the cool things in the AWS world is this thing called STS.  In tl;dr; terms, STS gives you temporary, expiring, renewable credentials, and if you make them available, AWS SDKs and the tools build off of them *just work*, which is what we've been aiming for all along.

Things that just work are awesome.  They save your brain cycles for the things that don't *just work*, of which there tend to be many many more.

So, with STS, you can get creds to do what you need, and they expire in a reasonable amount of time.  They renew if you're still using them.  AWS has a way of keeping tabs on who gets creds for what and when.  It's a slick system.

There's a problem though.  It only works in AWS.

## IAM on the Laptop

Without giving away too much information about exactly how I implemented it, in round terms, what I set up was a service that interacted with the AWS STS service to grant assumed roles to authenticated individuals.  How we authenticated the individuals isn't really important, but I'll tell you it involved asymmetric encryption and didn't require passwords.  The reader can likely figure out the rest.

Ok, ok, we had a service that authenticated and granted STS Creds.  Is that it?  Almost.  See, every AWS based library ever written automatically looks to the AWS metadata service to do it's thing.  It only uses env vars and potentially hardcoded credentials if this service is unavailable.

So what I did, which prevented the need for credentials, or code changes, is I impersonated the metadata service itself, and I did it locally and transparently.  Huh?  Yup.

Now I can't take credit for the idea of actually doing this.  Some very AWS savvy individuals I worked with came up with the basic idea.  The conversation went something like this:

    Them: "What we need is some way to impersonate the metadata service on a laptop."
    
    Me: "Why can't we do that?"
    
    Them: "We don't know how."
    
    Me: "I aught to be able to make that happen.  It's just packets."
    
    
So I did.  Here's how.

## Hacking the DHCP Spec

To really understand how this works, we have to back up.  First off there's this spec for something called 'DHCP'.  DHCP, if you're not familiar, is the "Dynamic Host Configuration Protocol".  It's how your computer get's a unique address in order to communicate with other machines on a network.

Addreses need to be unique, otherwise the streams get crossed and bad things happen.  This condition is known in user terms as 'It doesn't work'.  This is the most frightening bug report that an engineer can receive.

Normally, when you connect to a network, you ask for an address, and something called a 'dhcp server' hands you a unique one for your private use.  The server keeps a list of what addresses it's handed out, and how long they're good for.  The idea being that you don't hand out the same IP twice.

This is all great and wonderful, but what if you don't have a DHCP Server on the network?  Or worse yet, if there's supposed to be one, but it goes down?  Well, it turns out the designers of the spec already thought this one out for you.

There's a small restricted subnet hidden in the DHCP spec.  If you connect to a network, and try to get an IP via DHCP, and nobody answers, your computer will randomly pick one of the addresses in this range and use it, hoping to all that is holy that it hasn't picked an address in use by another machine.  If this happens, you have the dreaded bug listed above.  It won't work.

Ok, ok, this is some wild tech trivia, but why am I inflicting it on you, the gentle reader?  Well, it turns out Amazon brilliantly (or dastardly I suppose if you disagree with them) reasoned that there was no good reason for this subnet to be used within their EC2 cloud.  After all, it would mean that their highly available and reliable DHCP system would be down, and if that were the case, they would have deeper problems.

So what they did was pick an IP in the middle of the private range, 169.254.169.254, and put a metadata service on it with all sorts of goodies for use by EC2 instances.  What's more, all AWS SDK's are hardcoded to look for information at this point, and if they find it, they'll seamlessly *do the right thing*.  

## Hacking Hacks

So Amazon hacked the DHCP Spec, and I'm about to demonstrate how I hacked the hack, hence the title.  Note I'm using the term 'hack' in int's original sense, that of messing with a system and using it in a way it wasn't exactly intended to be used.  There's no maliciousness inherent in either their use, mine.  We're both just taking what is and using it in a new and creative manner.

So what I needed to do was threefold:

1. I needed authenticate my users in the proper fashion, granting them temporary STS credentials according to the IAM Role setup within AWS.

2. Impersonate the metadata service so that I'm actualy authenticating to *my own* service in a secure fashion. (The base AWS metadata service is more or less wide open)

3. Somehow make sure that *every AWS SDK Library Ever Written* hits *MY* service, not the real one, which it wouldn't be able to hit anyway, because it's a non-routable address that only works within AWS.

###  Authenticated STS Service

This part was easy.  Look at any AWS SDK in the STS section.  This has to be a service in my VPC that has the power to grant roles.

I based authentication based on asymmetric crypto keys that were already in use on everybody's laptops- SSH keys that people already had in place.  Basically I worked out how SSH uses the keys to authenticate, and duplicated that mechanism in code.  If you were you demonstrably enough for SSH, then you were you enough for the system.

### Impersonate the AWS Metadata service

This was simple too, just write a webservice in the language of your choice that performs according to the behavior of a subset of the metadataservice's endpoints, and voila! 

In short, the various SDK's are expecting to make a call to:

        http://169.254.169.254/latest/meta-data/iam/security-credentials/
        
And they're supposed to get back a role name such as "fargle".  With that in hand they're expecting to make a further call to:

        http://169.254.169.254/latest/meta-data/iam/security-credentials/fargle
        
and sometimes:

        http://169.254.169.254/latest/meta-data/iam/security-credentials/fargle/
        
If *something* answers on that IP and path with some AWS looking creds of the proper format, (try it yourself) you're good to go.

So that's it.  There's just a little service that reaches out to the Service listed [above](#authenticated-sts-service), gets it's information and spits it back in the way the AWS SDK expects it.

That's it?  Well, no, there's more. You have to get around the hard coded, unroutable IP address, cos you don't want to actually monkeypatch that AWS SDK code.  Trust me.  You don't.

### Bending the Packets

In order to make the packets go where **I** tell them to go, rather than where they would normally go, you have to get down and dirty with the packet routing stack of your kernel.  This is not for the faint of heart, but once you've swam in those waters, it's also not so bad.  What makes it especially annoying is every kernel has it's own way of doing it.

On Linux, you've got the mighty IPTables.  "Eew IPTables!" you cry?  Yup.  IPTables.  Seriously, I learned to write firewalls with *IPChains* which is what we used before IPTables, back when we would walk 20 miles each way to reach the compiler.  Uphill *both* ways.  In a snow storm.  Yes, I'm that old.  IPTables is an incredibly welcome change over the 'bad old days'.

On a Mac, you've got 'PF', which stands for 'Packet Filter', which does more or less the same thing as IPTables.  Saying that 'PF is IPTables on a Mac' is sort of accurate, though it will annoy purists.  PF is a BSD tool, that happens to be on a Mac because MacOS is based on a version of BSD called 'Darwin'.  Darwin itself is based on a version of BSD called 'FreeBSD'.  This will become important shortly.

#### Linux Magic

This stuff is incredibly easy on Linux because the packet filter in the kernel does it's job no matter what.  Incoming, outgoing, it's all the same.  So we just bend the traffic thusly:

    sudo iptables -t nat -A OUTPUT -d 169.254.169.254/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 50000
    
And now Voila!, traffic heading for 169.254.169.254 port 80 actually routes to 127.0.0.1:50000, where our service is waiting for it.  Start said service, and you're good to go.  For those of you looking for a '127.0.0.1' in the above invocation, it's implied.
    
#### Mac Magic

Doing it on a Mac is harder.  Why?  Well, it turns out there are a lot of different opinions on how to do things in the open source world.  This is hardly news, is it?

Turns out the authors of NetBSD and OpenBSD thought in a Linux like fashion, and thought it might be useful to have the packet filtering stuff work regardless.  I imagine they felt like I do, and thought that if you were savvy enough to tell the packets where to go, the packets aught to go where you told them to go.  I wish I could achieve the same with my kids.

The authors of FreeBSD however, figured there was no reason for PF to redirect OUTBOUND packets.  Who would want to do that?  Hackers of AWS's Hack of the DHCP protocol, obviously, but I guess we can't fault them for not imagining *I* would come along some day.  Even my momma wasn't prepared for me.  The rest of the world didn't have a chance.

So, remember I said that MacOS is based on Darwin, which is itself based on FreeBSD.  It turned out that this was critical CS trivia to remember, because all the guides I found out on the interwebs about doing what I wanted to do were written for the NetBSD or OpenBSD versions of PF, and their advice did not work on a Mac.  Phooey.

What I finally found, was a footnote somewhere (I don't recall where exactly) stating the problem and part of how to solve it.  That factoid combined with other tidbits assembled from the dark corners of the Internet yielded a solution.

1. First, we assign an alias to the loopback interface, telling it it has another name of 169.254.169.254.  Without this, the loopback will politely ignore traffic that hits it, as clearly, it's not intended for here.

        sudo ifconfig lo0 alias 169.254.169.254
        
2. Then we exercise PF

        PFUP=$(cat <<EOF
        rdr pass on lo0 inet proto tcp from any to 169.254.169.254 port = 80 -> 127.0.0.1 port 50000
        pass out route-to (lo0 127.0.0.1) inet proto tcp from any to 169.254.169.254
        EOF
        )
        
        echo "$PFUP" | 2>/dev/null sudo pfctl -ef -
        
        
Why all that nonsense?  Mainly because I don't want to burden the users with a bunch of PF gobbledygook.  They're not likely to like|care|understand.  It's not that they can't.  They just have other things to think about.  Fair enough.  I don't do data science either.

I also was hobbled by needing to pass it all to PF in a single block, and PF really wants to parse files, with newlines in them and such.

So, what we've done, is we've created an alias on the loopback, which tells the loopback it can listen to the message, and then we've redirected things that are out bound back around to the loopback.  Once they're inbound, PF will redirect them again as intended.  Whew.


## Conclusion

So there we are.  I'm sick of talking in my head about this.  I'll come back after a break and clean up the prose some, and perhaps add some diagrams.

It'd be awesome too if I can find the time to give you some example scripts, but that's for another day.

Until next time.

Happy Hacking!
