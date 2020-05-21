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

So a good system has to be secure, and relatively painless.  Ideally people will just do the right thing- without necessarily even knowing what the right thing is.  That's what we call *enablement*, and is what toolsmithing is all about.  

We toolsmiths don't really do anything useful.  Our job is to keep the painters painting.  It's the things they do with the brushes we give tham that makes the dough and wins the fame.

You don't get into Infrastructure if you want to be visible.  The only visible things here are the failures.  Blech.

## Relax, AWS Has You Covered... Somewhat

For a shop beyond a certain size, managing personal creds in the AWS IAM dashboard is too much of a hassle.  

Too many cooks in that particular kitchen makes for a big mess when Mr. BlackHat dude comes to call.  So there's a temptation to make it all flow through someone who's in control of all access, but there's a big problem with that too.  

That job sucks, bigtime. The only person you can hire to do such a job for any length of time either has no imagination, or is totally checked out, cos it's *boring*.  

While this mythical person might be a snappy dresser and a good dancer, they're not the person you want in charge of the keys to the kingdom.  Any person who *would* be a good person to put in charge of the keys will be bored silly.  

Even if you can get them to take the job, they won't be there long.

## Enter AWS Security Token Service

This is not going to be a how to for everything AWS.  Amazon has ~~perfectly good~~  er, Amazon has ~~helpful~~, uh... Ahem.  Amazon has docs.  How about that?  

[http://docs.aws.amazon.com/STS/latest/APIReference/Welcome.html](http://docs.aws.amazon.com/STS/latest/APIReference/Welcome.html)

I'm not actually knocking Amazon or their document writers.  They do a better job than I would do.  Among other things, I can't resist the urge to ramble off in some tangental direction....

Reading AWS Docs is a skill in and of itself though, kind of like reading man pages or javadocs.  They're good skills.  I recommend you develop them.  The learning curve can seem vertical at first.  Don't worry though, it levels off pretty quickly, and the only way to really get good at it is to just do it.

Anyway, one of the cool things in the AWS world is this thing called STS.  In tl;dr; terms, STS gives you temporary, expiring, renewable credentials, and if you make them available, AWS SDKs and the tools build off of them *just work*, which is what we've been aiming for all along.

Things that just work are awesome.  They save your brain cycles for the things that don't *just work*, of which there tend to be many many more.

So, with STS, you can get creds to do what you need, and they expire in a reasonable amount of time.  They renew if you're still using them.  AWS has a way of keeping tabs on who gets creds for what and when.  It's a slick system.

There's a problem though.  It only works in AWS.

## IAM on the Laptop

In round terms, what I set up was a service that interacted with the AWS STS service to grant assumed roles to authenticated individuals.  Users were authenticated by that service using SSH keys.  SSH keys were a great mechanism for a number of reasons.  First they were already in use for both shell and Github access.  They're also a pretty tough nut to crack.  OpenSSH has been around for a long time, and to date, if there's a zero-day, it's usually in some 3rd party's 'improvement' on OpenSSH, not in the protocol itself.

OpenSSH also had the advantage of being *already installed* on every laptop in the organization.  Rolling your own can be fun, but it's even more fun to pick up something that already works, is battle tested to the nth degree, and can be counted on to be already installed.  

Ok, ok, we had a service that authenticated and granted STS Creds.  Is that it?  Almost.  See, every AWS based library ever written automatically looks to the AWS metadata service to do it's thing.  It only uses env vars and potentially hardcoded credentials if this service is unavailable.

So what I did, which prevented the need for credentials, or code changes, is I impersonated the metadata service itself, and I did it locally and transparently.  Huh?  Yup.

Now I can't take credit for the idea of actually doing this.  Some very AWS savvy individuals I worked with came up with the basic idea.  The conversation went something like this:

    Them: "What we need is some way to impersonate the metadata service on a laptop."
    
    Me: "Why can't we do that?"
    
    Them: "We don't know how."
    
    Me: "I aught to be able to make that happen.  It's just packets after all.  It's not magic."
    
    
So I did.  Here's how.

## Hacking the DHCP Spec

To really understand how this works, we have to back up.  

First off there's this spec for something called 'DHCP'.  DHCP, if you're not familiar, is the "Dynamic Host Configuration Protocol".  It's how your computer get's a unique address in order to communicate with other machines on a network.

Addreses need to be unique, otherwise the streams get crossed and bad things happen.  This condition is known in user terms as **'It doesn't work'**.  This is the most frightening bug report that an engineer can receive.  I know.  I've been given bugs like that.  (Yes, that was the entire bug report.  3 words.  *sigh*)

Normally, when you connect to a network, you ask for an address, and something called a 'dhcp server' hands you a unique one for your private use.  The server keeps a list of what addresses it's handed out, and how long they're good for.  The idea being that you don't hand out the same IP twice.

This is all great and wonderful, but what if you don't have a DHCP Server on the network?  Or worse yet, if there's supposed to be one, but it goes down?  Well, it turns out the designers of the spec already thought this one out for you.

There's a small restricted subnet hidden in the DHCP spec.  This is the 'link-local' network.  If you connect to a network, and try to get an IP via DHCP, and nobody answers, your computer will randomly pick one of the addresses in this range and use it, hoping to all that is holy that it hasn't picked an address in use by another machine.  If this happens, you have the dreaded bug listed above.  It won't work.

Ok, ok, this is some wild tech trivia, but why am I inflicting it on you, the gentle reader?  Well, it turns out Amazon brilliantly (or dastardly I suppose if you disagree with them) reasoned that there was no good reason for this subnet to be used within their EC2 cloud.  After all, it would mean that their highly available and reliable DHCP system would be down, and if that were the case, they would have deeper problems.

So what they did was pick an IP in the middle of the private range, 169.254.169.254, and put a metadata service on it with all sorts of goodies for use by EC2 instances.  What's more, all AWS SDK's are hardcoded to look for information at this point, and if they find it, they'll seamlessly *do the right thing*.  

## Hacking the Hack

So Amazon hacked the DHCP Spec, and I'm about to demonstrate how I hacked the hack, hence the title.  Note I'm using the term 'hack' in it's original sense, that of messing with a system and using it in a way it wasn't exactly intended to be used.  There's no maliciousness inherent in either their use, mine.  We're both just taking what is and using it in a new and creative manner.

So what I needed to do was threefold:

1. I needed authenticate my users in the proper fashion, granting them temporary STS credentials according to the IAM Role setup within AWS.  This meant a remote service in AWS with the proper IAM roles to perform this task.

2. Impersonate the metadata service so that I'm actualy authenticating to *my own* service in a secure fashion. (The base AWS metadata service is more or less wide open)  This meant a local service on the laptop that could identify the user of the laptop to the remote service above.

3. Somehow make sure that *every AWS SDK Library Ever Written* hits *MY* service, not the real one, which it wouldn't be able to hit anyway, because it's a non-routable address that only works within AWS.  This meant some serious network black magic that I shuddered to contemplate.  It would be slick, but it could be seriously used for evil.

###  Authenticated STS Service

This part was easy.  Look at any AWS SDK in the STS section.  This has to be a service in my VPC that has the power to grant roles.

I based authentication based on asymmetric crypto keys that were already in use on everybody's laptops- SSH keys that people already had in place.  Basically I worked out how SSH uses the keys to authenticate, and duplicated that mechanism in code.  If you could prove you're you well enough for SSH, well, thats good enough for me.

### Impersonate the AWS Metadata service

This was simple too, just write a webservice in the language of your choice that performs according to the behavior of a subset of the metadataservice's endpoints, and voila! 

In short, the various SDK's are expecting to make a call to:

        http://169.254.169.254/latest/meta-data/iam/security-credentials/
        
And they're supposed to get back a role name such as "fargle".  With that in hand they're expecting to make a further call to:

        http://169.254.169.254/latest/meta-data/iam/security-credentials/fargle
        
and sometimes:

        http://169.254.169.254/latest/meta-data/iam/security-credentials/fargle/
        
I never did work out which tools wanted a trailing slash, and which didn't.  Some simple testing showed that both variants were in play.  Sometimes, when presented with a fork in the road, you just take it.

As long as *something* answers on that IP and path with some AWS-ish looking output, you're good to go.

So that's it.  There's just a little service that reaches out to the service listed above, gets it's information and spits it back in the way the AWS SDK expects it.  The AWS metadata service does more than just that, but that's the only part that I needed to reproduce for this project's needs.

That's it?  Well, no, there's more. You have to get around the hard coded, unroutable IP address, cos you don't want to actually monkeypatch that AWS SDK code.  Trust me.  You don't.

### Bending the Packets

In order to make the packets go where **I** tell them to go, rather than where they would normally go, you have to get down and dirty with the packet routing stack of your kernel.  This is not for the faint of heart, but once you've swam in those waters, it's also not so bad.  What makes it especially annoying is every kernel has it's own way of doing it.

On Linux, you've got the mighty IPTables.  "Eew IPTables!" you cry?  Yup.  IPTables.  

Seriously, I learned to write firewalls with *IPChains* which is what we used before IPTables, back when we would walk 20 miles each way to reach the compiler.  Uphill *both* ways.  In a snow storm.  Yes, I'm that old.  IPTables is an incredibly welcome change over the 'bad old days'.

On a Mac, you've got 'PF', which stands for 'Packet Filter', which does more or less the same thing as IPTables.  Saying that 'PF is IPTables on a Mac' is sort of accurate, though it will annoy purists.  PF is a BSD tool, that happens to be on a Mac because MacOS is based on a version of BSD called 'Darwin'.  Darwin itself is based on a version of BSD called 'FreeBSD'.  This will become important shortly.

#### Linux Magic

This stuff is incredibly easy on Linux because the packet filter in the kernel does it's job no matter what.  Incoming, outgoing, it's all the same.  So we just bend the traffic thusly:

    sudo iptables -t nat -A OUTPUT -d 169.254.169.254/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 50000
    
And now Voila!, traffic heading for 169.254.169.254 port 80 actually routes to 127.0.0.1:50000, where our service is waiting for it.  Start said service, and you're good to go.  For those of you looking for a '127.0.0.1' in the above invocation, it's implied.
    
#### Mac Magic

Doing it on a Mac is harder.  Why?  Well, it turns out there are a lot of different opinions on how to do things in the open source world.  Shocking, right?

Turns out the authors of NetBSD and OpenBSD thought in a Linux like fashion, and thought it might be useful to have the packet filtering stuff work regardless.  I imagine they felt like I do, and thought that if you were savvy enough to tell the packets where to go, the packets aught to go where you told them to go.  I wish I could achieve the same with my kids.

The authors of FreeBSD however, figured there was no reason for PF to redirect OUTBOUND packets.  Who would want to do that?  Hackers of AWS's Hack of the DHCP protocol, obviously, but I guess we can't fault them for not imagining *I* would come along some day.  Mom wasn't exactly prepared for my arrival either.  The rest of the world didn't have a chance.

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
        
        
Why all that nonsense?  Mainly because I don't want to burden the users with a bunch of PF gobbledygook.  They're not likely to like / care / understand.  It's not that they can't.  They just have other things to think about.  Fair enough.  I don't do data science either.

I also was hobbled by needing to pass it all to PF in a single block, and PF really wants to parse files, with newlines in them and such.

So, what we've done, is we've created an alias on the loopback, which tells the loopback it can listen to the message, and then we've redirected things that are out bound back around to the loopback.  Once they're inbound, PF will redirect them again as intended.  Whew.

## Sudo and Userspace

Now you know how to do it.  Making it work seamlessly is another trick.  This wouldn't be fun if there weren't some interesting gotcha's lurking in the shadows.

The first one is, the 'network magic' that is PF or IPTables *must* be run as root or via sudo, but the rest of the system *cannot* be run as a privileged user.  The system had to simultaneously work in both realms.  Why?  I'll tell you.

See, the network stuff is low level kernel stuff, so of course it requires root.  I explored having it happen on startup, to make it further invisible, magical and delightful for my users, but that was a no go.  In their infinite wisdom and paranoia, Tim Cook's engineers have decided that, while you can mess with PF if you have admin privileges once the system is booted, you can *not* diddle with it at boot time.  Not without entering recovery mode and seriously hacking around.  Yuck.

Actually, I salute Apple for this annoying monkey wrench they tossed into my clever plans.  As I pointed out to several folks who thought having to type in your password all the time was a bit of a hassle: If I can do this with AWS's metadata services, what's to stop me from doing it with, say, the IP of your bank?  Jaws dropped.  Nice data scientists don't usually think in those terms.  I however, do.

Yes, the network magic I just learned you has some serious potential for malfeasance.  IP addresses aren't like physical addresses- they're not aliases or labels for locations.  They're more like precise maps and gps guided intertial navigational directions to get somewhere.  The bits represented by the numbers in the IP address are literally the switches that get 'thrown' electronically to get your packets from A to B.  If I can mess with that, I can break the Internet- for you anyway, and ultimately, that's what you care about, right?

So, that covers the network.  Mostly.  Another interesting tidbit is that network magic, once set, persists until unset, or the machine reboots.  That can cause some interesting errors, cos PF in particular does not like being set twice.  Annoying gotcha that came out in testing, but was resolved.  My code had to be smart enough to detect whether the network was bent, and unbend it before attempting to rebend it again.  Not a big deal when you expect to continuously prove your code works via testing.  Thus endeth the sermon.

The local service part- the bit that authenticated to the remote service on the other hand, had to run as the user.  Why?  How else to identify the user?  Remember, the whole point of this exercise was to identify a user and grant him or her elevated permissions within our AWS stack.  Even if you give everyone same permission, you need to identify to *whom* you're giving that permission to.  Otherwise what's the point.

By default, ssh keys are stored in ~/.ssh/ .  Well and good, but if you run it via sudo '~/' translates to '/root/', rather than '/home/(user)/' on Linux and '/Users/(user)/' on a Mac.  That's a problem, cos I wasn't going to suggest that data scientists set root keys and such.  Eew.

So the tools had to run in userspace, and had to elevate their permissions at need to do the more wizardly stuff.  That was a neat problem.

It cost me some grey hair, but eventually I realized that the best privilege elevation system was the one already built into the box itself.  I just worked out how to connect the streams to shell out to the native 'sudo' and I was in business.  Sudo, with it's timer, and it's retries and all is a surprisingly complex little beast.  Replacing all of that in code was... fugly.  Better to use the wheel I already had in place, rather than make a new one with more corners.  (Wheels aren't supposed to have corners.  That's the joke.)

## Conclusion

So there we are.  Passwordless expiring, temporary authentication for AWS SDK's positively linked to user identities and enabled by IAM Roles.  Neat huh?

The system worked pretty well.  As I reminded everyone continuously, it would probably never be perfect.  It's a hack of a hack, and as such, inherently unstable.  Whenever you use something in a manner it was not intended you're always going to run up against the limitations imposed by the original designer- who obviously was solving a different problem than you were.

If I had time, resources, and interest, I'd probably build these hacks into a notification area app that had nice blinking lights showing you the status of the local service and the network magic.  Who knows?  Could be I'll visit this problem again.  You know how to get a hold of me. 
