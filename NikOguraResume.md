# Nik Ogura

### Principal Software Engineer

### San Francisco, CA

#### Aut viam inveniam, aut faciam

*(If I cannot find a way, I will make one)*

-- Hannibal of Carthage, when told there was no way he was bringing elephants through the Alps.

# Interesting Things I've Done

## Created an Access and Identity System for a Data Science Department 
It's the means by which an entire department of Data Scientists and Engineers connected to every system, instance, and container in the stack.  The whole access and identity lifecycle- onboarding, offboarding, partner connections, and a light weight roaming profile for any user on any system in a dynamic auto scaling cloud environment.  

The rest of the company used a 3rd party SSO offering.  They got breached and the SSO went down.  We stayed up.

## Bent AWS's Metadata System to Enable IAM Authentication on Laptops
I worked out how to bend AWS's metadata service so that we could leverage IAM Roles and STS credentials as if we were running in EC2, but actually do so with passwordless authentication on a laptop.  The idea to even try came from others, but I'm the one who worked out how to make it happen.

Absolute black magic that *just works* and requires zero code alteration of Amazon SDK code and no monkey patching whatsoever.  

Code works the same locally as it does in the cloud.  No surprises.  That's what it's all about.

## Invented a Signed Binary Tool Distribution and Execution Framework
It's used for distributing and running signed binaries on user laptops.  The system works online, and gracefully degrades when offline.  

It builds, tests, publishes, and even updates itself *in flight* when there's a new version available.  The binaries are signed, so you can verify integrity, trust, etc.  It works so automatically and magically that I had to make sure it couldn't be easily made to do evil.

When I figure out how to get it to actually *write* it's own new features and fix it's own bugs, I'll have invented SkyNet.

## Made Apple Pay's Test-Driven Cloud-Based CI/CD Pipeline
Apple Pay and the systems behind activation of every Apple device in the world used it.  

It worked pretty well, here and abroad.  I don't know how much of it they're still using.

Hear about them going down and being unable to deploy between 2015 and 2017?  Me neither.

## Made an Application Stack Prototyping and Orchestration Suite
I worked up a system whereby the entire deployment footprint of a group of applications can be described and manipulated in code. It was self healing and could detect and correct drift. 

Applications, Load Balancers, Firewalls, you name it.  Not only can it be managed 'for real' in the datacenter, but it can be virtualized in a private cloud or locally in docker up to the limit of the hardware.
  
 This was before things like Docker Compose was really stable, and Kubernetes was just beginning to gain serious traction.  
 
 In our case, we used the real Puppet and Chef modules used to configure the apps in the data center to build the containers locally for local integration testing.  
 
 It's not a model I'd suggest repeating.  There were way too many moving parts.  Building docker containers with Chef Recipies and Puppet Modules is kind of icky to even think about, but it worked.
 
 In this case we needed to prototype the 'real' applications locally, as the real running instances were all precious snowflakes that nobody could reproduce.  Taking what was running 'for real' and making it build us ephemeral local models for testing was the way to go.

## Built Static Code Analysis of Puppet Modules
 There were no tools to do SCA of Puppet modules for GRC (Governance, Risk- Management, and Compliance).  So I made some.
 
 The idea was to state categorically pre-merge and pre-deployment that a change to the code would not bring the system out of compliance with regulatory and security baselines, et al. 
 
 I got to delve into the world of Lexers, Parsers, Tokens, and language processing- all that wild stuff.  It was a blast. 

## Invented an Encryption Key Management and Delivery System
 The company bought a PKI, and it sucked.  The parts didn't talk to each other.  It couldn't deliver the keys.  Keys were being left on shared drives and pasted into group emails.  *Ouch.*

So I worked up a system to components from multiple sources together and automates deployments.  It allowed one button delivery of encryption keys to multiple operating systems across multiple network tiers.  

It had a friendly user interface allowed non-technical users in multiple countries to create and deploy SSL Certificates in a secure manner. The application saved the company over $1M based on vendor bids for similar systems.  

What's even slicker is I taught myself Java to do it.  From what I hear, they're still using it today.  I don't know whether I should be proud of that or scared- it was, after all my first Java app.  I'm sure they've polished off it's rough edges by now.  I hope.

### Designed a Credit Card PAN Encryption and Tokenization System
It was scalable.  It was highly available.   It encrypted and masked credit card numbers for a Merchant Acquiring systems (Credit Card Authorization and Settlement).  

I also built and maintained the secure management tools for same.  We had to hide the numbers, sure, but this was actual payment processing inside the financial sector.  *Someone*- the right someone, and only the right someone internally had to be able to see the numbers, but no one else.

## Made LAMP Stacks Galore
My first one let us use the latest, most up to date versions of Apache, OpenSSL and Perl to run secure apps on servers that were at least 5 years out of date.  5 is a lot in 'computer years'.
  
The stack was modern, but ran on an ancient systems.  Their priesthood lovingly maintained them as the precious works of dystopian art they were.  Meanwhile *we* did business in *this* century.  To each, their own.

I've done the same for Python, Gunicorn, Django and Nginx.  

## Built and Maintained Web Application Firewalls
I've designed, implemented, and maintained Web Application Firewalls for cross platform applications, some directly handling credit card PAN data.  

We proved our compliance with PCI DSS and the OWASP Top Ten.  You can install firewalls off the shelf with the push of a button.  The trick is knowing enough about what is going on to tune the rulesets and educate the app developers to understand why the 'easy' and 'simple' construction they like to use is actually opening the system to attack.  

Who can do that?  This guy.

## Brought a Whole Business Line into PCI Compliance
I participated in creating and executing a plan to bring a multi- million dollar business line centered around credit card processing systems from zero to PCI 2.0 compliant in < 12 months.  Can do it again too.

# Skills

## Communications 
I'm primarily a teacher, and an evangelist.  Mom wanted me to become a minister.  I would have been good at the 'fire and brimstone' parts, but I can't pull off the high hair.

With over 30 years experience in bringing the light of knowledge to the dark corners of the intellectual realm.  If I know something, I can help you know it too.  If you want to know it that is.  No power in the 'verse can make you want to if you don't.  You can lead a person to knowledge, but you *cannot* make them think.

I've written curriculum for courses in Test Driven Development, Application Security, Network Security, and some light Penetration Testing.  I've taught the courses too.

I've been a coach for public speaking and performance, was an instructor for leadership, taught both elementary and secondary classes, and was even a wildlife educator at the San Antonio Zoo in a past life.

## Computer Languages (To Date)

Languages to we computer types are like brushes to a painter.  Which is my favorite?  Favorite for what?  They're all wonderful in some way, and they're all miserable in some way.  You try to use the right tool for the right job and not get dinged too much by the rough edges.

So far I've been deep into: Java, Ruby, Python, Groovy, JavaScript, C, Perl, Go, and Bash.

My skills in all of the above rise and fall as each gets used and then left to erode and accumulate dust while I polish up the next.  I rarely spend enough time in any single language to really feel like a virtuoso anymore.  

Once upon a time I read and wrote Perl better than I read and wrote English, but those days of narrow focus are long behind me.

If you want to whiteboard some code, I can prove to you I know how, but it might come out as psudeo-code or *JavaGoPerlThon*.  It doesn't take long at all for me to get deep again into the language of the day.

## Networks and Traffic

I can claim broad and occasionally deep knowledge of how computers talk to each other.  

I grok the layers, and get the various thinga that happen at each,  though I confuse the 7 layer OSI model with the 4 layer TCP/IP model and have been known to forget who calls which layer what.  What's in a name anyway?  

I've written routers and firewalls from scratch, wrestled with IPSec, built VPN's, and traced network traffic to reveal poisoned ARP Caches.  

I've run set up and maintained BIND, and can both cause and resolve DNS issues across local, LANs and WANs.

Iptables and PF do my bidding.  The packets go where *I* tell them to go.

I've built IPSec tunnels, and have unwound the Linux networking stack with it's network namespaces to the point where I could run OpenStack *inside* of OpenStack and have it all mostly work.  Why?  Long story.  I'm still shaking from the experience.  I did however come away with a one-file installer for a private OpenStack cloud that I kept on my key chain.  Still have it too.

I get load balancers and the routing of traffic.  I've used Open Source ones such as Apache, Nginx and HAProxy, and some of the ones with price tags such as F5 BigIP, Netscaler, AWS ELB.  I can cross and uncross the streams at will.

## Quality, Security, and Testing
I'm a big believer in Testing, and Test Driven Development.  Actually that's not quite right.  I'm actually a big fan of *integrity*, as a person, as a coder, and as a citizen of the universe.  

What is Integrity?  Quite simply it's knowing what something *is* and what it *is not*, and being able to continuously demonstrate that for any interested parties.  This is the essence of QA, Security, and Trust.

We can't begin to talk about whether something is 'good', or 'bad', 'secure' or 'insecure' until we establish it's identity.  That's where code signing and secure, repeatable, transparent artifacts and build tooling comes in.  It is what it is and it can be trusted to be what it is and contain what it contains.

Once we can establish what it is, we can start to describe it's behavior, and the interface contract between the thing and it's users.  That's really what Testing is: proving to ourselves and any other interested parties that it does what we expect.

Moreover, you should never take my word *(or anyone else's)* for it.  Perform the experiment yourself and observe the result.  That's what science is.  They do call it *Computer Science* for a reason.  

Are tests enough? Depends on the tests.  Write crap tests and get smelly results.  Garbage in, garbage out.

If we can continuously prove that our code does what it's supposed to do and that we have full provenance of it's history and lifecycle, Security is a snap and auditors will leave you alone.  It's actually pretty easy if you develop the discipline.  It just looks like a bunch of meaningless work in the beginning until you build the muscles.

Proof is also not a one time thing.  To be really meaningful, it must be continuous.  With a one-shot we can only say 'it used to work'.  Well, great, it used to work, but things change so quickly these days that even if your code didn't change, the rest of the world changed around it.  It might not 'work' any more. It also might not be 'secure' any longer.  

We're all running to stand still here.  Lace up those shoes.

## Cloud Goodness
I've flown through the big clouds such as OpenStack, VmWare, and AWS.  Am I a master?  Hardly.  They're all so big that anyone who claims to know it all might just be pulling your leg.

Are they cool?  Hells yeah!  Do I like them?  I do indeed.

What kind of cloud do you want to whip up?  I'll make you one that'll register as a Category 5, but without the whole 'flooding' and 'backed up sewage' parts.  Eew.

## Making Stuff Work
I think of a hacker as someone who can pop the hood and fiddle around inside- make it go.  Someone who is entirely unintimidated by not knowing something, and who's entirely comfortable digging in and figuring it out.

Some of those sorts of people use that knowledge to bring ruin on others, and they have sullied the good name.  

I still think of myself as a 'hacker', but in the sense I just described.  I've had to learn more than a few of the tools the baddies use to do their nastiness, but I prefer to play defense.  I'm the Watcher on the Wall, not the invader.

Mainly I got into this field because I had a busines to run, and knew I couldn't do it all by hand.  What I realized is, if you have a job that merely requires precision, speed, accuracy and repeatability, it's a job for a machine.

The idea, to me anyway, is to get the machine to do what the machine does best, and free up the humans to do what only humans can do- the things that require imagination, judgement, artistry.  Those are the fun jobs anyway.  Who wants to be an automaton?

I groove on making things that help people do things that would otherwise suck.  Secure handling of encryption keys isn't rocket science, but it's *boring*.  It doesn't take much thought, but it does take great attention to detail.  So I made the machine do it.  Machines don't skip steps and don't get bored.  Machines don't get distracted.

What do you need to do, and what are the pain points?  I reckon that, with a little thought, a little sweat, we can find a way to make it not painful at all.

If I cannot find a way, I will make one.

# Employment History

## Stitch Fix inc. San Francisco, CA
2017 - Present *Data Platform Engineer  Algorithms and Analytics Department*

Here's where I made the Access and Identity system described above.  It's where I am now, so of course, my most exciting and up to date work on clouds and platform engineering is happening even as we speak.

## Apple
2015 - 2017  *Senior DevOps Engineer, iOS Systems  (Apple Pay)*

I'm one of two guys who Designed and built a dynamic test driven CI/CD pipeline for Apple Pay, Apple Sim, and every Apple device in the world.

I implemented a private OpenStack cloud for testing and verification of applications.  From scratch.  They handed me a pile of HP DL360's and 'do something with these'.

I authored a system whereby the entire deployment footprint of a group of applications can be described and manipulated in code.

I helped craft iOS Systems move from SVN to Git.

## DRC
2014 - 2015 *Principal DevOps Engineer*

I designed an auto scaling Continuous Delivery environment for educational testing.

While there I shepherded multiple applications from proprietary systems to fully Open Source platforms.  Goodbye Microsoft, hello Linux.

I designed and taught internal training curriculum for the technology, disciplines, and cultural concepts that come under the heading of DevOps.

I wasn't there long.  I would have happily stayed, but Apple called and sunny California beckoned.  Can you blame me?  I never want to see ice again outside of a glass or on a distant mountain top.  *Brr.*

## Wells Fargo
2014 *Sr. Software Engineer*

I was a DevOps Consultant for Development, Testing, Building and Delivery of Applications and Middleware.

My main job was that of Module Developer for Continuous Integration/ Continuous Delivery of multiple applications across multiple technologies and multiple operating systems.  They had multiple OpenStack clouds.  We built the Puppet modules to deploy into it.

My thing was, and still is, automation of anything and everything- anything that a machine can do faster and more reliably, freeing the humans to do what only humans can do.

This is where I designed and built language applications to parse Puppet source code to do SCA for GRC.

## US Bank
2007 - 2014  *Applications Systems Administrator Sr.*

Mainly I did what I call 'Specialty Application Development'.  That is projects too sensitive or specialized for a general development team, or things that were deemed 'impossible'.  I didn't know they were impossible, so I just did 'em.

This is where I built the encryption key delivery system, and my first LAMP stacks.  This is where I did most of my credit card related goodness, where I learned about encryption, PCI, that stuff.

I was basically a 'security consultant' for an Application Architecture team. I worked with Arch and Development teams to evaluate threats, explain the scan findings, and show the folks how the vulnerabilities work and how to fix them.

This is where I really delved into load balancing and monitoring.  I also presented internal courses/talks to business and engineering groups.  I trained teams in automated testing tools and techniques.

Blah blah blah.  It was a bank.  They were serious about protecting people's money *(I still use them, in fact.)*  All that fun security/encryption/spooky paranoia type stuff listed above?  I started doing it here.

## Plain Black
2006 - 2007  *Application Developer*

I provided online troubleshooting for customers, and performed core development on the WebGUI CMS.

## United Martial Arts
1998 - 2007  *President, CEO, and Head Instructor (also Lead Programmer, Receptionist, and Executive Janitor)*

I was responsible for day to day operations of the martial arts studio, including management, financial planning, personnel- you name it, I did it.  

I taught classes in Exercise, Wellness, Leadership, and the Martial Arts in the studio as well as for corporations and in the community.  

Over the course of 9 years, I designed, built and maintained a custom studio management desktop application that handled enrollment, financials, lesson plans, scheduling, video and print library management, and curriculum.  

Coding was cheap entertainment.  Kick and punch doesn't pay much.  Somewhere in there I guess I got good at it, because it turned into a whole new career.

