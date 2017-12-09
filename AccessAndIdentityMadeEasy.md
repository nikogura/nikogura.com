# Access and Identity that Just Works
This treatise is a demonstration on how to get an Access and Identity system spun up.  It will be reasonably secure, and reasonably scalable.

I say 'reasonably secure', because, like most things in Security, you can go as far as you want to.  What one person calls 'paranoia', another calls 'reasonable".  This system will ultimately depend on credentials, and as such, is as secure as the credentials you choose to secure it.

It's also 'reasonably scalable' in that it works just fine for a couple up to a few thousand people.  As it gets larger, you're going to be more and more dependent on how you get the information into and out of the system.  A directory server is a storage mechanism.  What you fill it with is up to you.

We are going to:

1. Spin up a set of what are popularly termed 'LDAP Servers', which more properly are instances running the service 'slapd'.  These instances will be 'n-way-multi-masters', which is to say they are a council of co-equal masters that will exchange information amongst themselves at need to stay in sync.  If one or more of the masters is replaced, a new master will be able to join the council and 'catch up' it's information.  We can tolerate any number of masters going down, so long as at least one remains online, and any new masters have time to 'catch up' before the 'old masters' finally go away.  

2. Configure these masters to take the place of things like ```/etc/passwd```, ```/etc/shadow```, ```/etc/group```, and ```/etc/sudoers``` on a POSIX type system.  In short, after we have this all set up, the info in LDAP is considered authoritative, and what's on the disk is more or less ignored.

3. Configure our containers and instances to use the LDAP server as their source of truth.

We'll do 2 masters, and we'll call them 'gold' and 'blue'.  Why?  Nuclear submarines, like LDAP servers are basically useless unless they're out doing their thing.  The hardware can run for years without replenishment.  The crew, not so much.  In the navy they solve this by having a 'gold' crew and a 'blue' crew.  When they run out of food and crew energy, they come back in, replenish the perishable supplies, swap out the crew, and off they go.  It seemed to be a close enough analogy.

Our servers will reside at the following addresses:

        ldap-blue.fargle.com
        
        ldap-gold.fargle.com
        
DNS will have an alias with a name of ```ldap.fargle.com``` which resolves to both.  Any given user will hit one or the other, and since the data and configs are replicated, it shouldn't matter which one you're actually talking to.

# Ugh.  LDAP?

I can already hear the protests.  LDAP?  LDAP.  For the love of all that is holy, why?

Well, see, I agree with you.  LDAP sucks.  My favorite quote about ldap is:

*"Never has so much been written so unintelligibly about so little"*

LDAP is one of those things that conjures images of the Dilbert character "Mordac, the Preventor of Information Services". This is apt, as the 'directory trolls' and the 'security trolls' in many large companies seem to have learned from the same [BOFH](https://en.wikipedia.org/wiki/Bastard_Operator_From_Hell).  Let's face it.  A lot of them *deserve* their reputation.  A lot of seem to have read some guide that an unusable system is a secure one.

Balderdash.  *(Wow, I finally got a chance to actually use that word in a sentence.)*  In the world where I was learning my security principles, there were 3 sides to the triangle:  Integrity, Confidentiality, and *Availability*.  But I digress.

Yeah, so, LDAP.  It's ancient, it's nasty.  However, if you take the time to learn how to schpreken zie LDAP, it *just works*.  What's more, just about any system you could ever want to connect to *already knows how to talk to it*.

So in defense of this ancient and somewhat misunderstood technological dinosaur, I'm going to show you how to use it, and how to make a simple access and identity system for your instances- be they virtual machines or containers.

# LDAP, Ubiquitous LDAP

What's that you say?  Everything already knows how to talk to it?  Yup.  Even containers?  Uh huh.  See, the LDAP integration into PAM and such is low enough level that, even if you weren't setting out to enable single sign on into containers, you get it for free.  Neat huh?

There are advantages to the old and venerable.  Like syslog, LDAP is so old that just about anything in the Access and Identity space already knows how to use it.

That means the pieces are lying around on the floor of your package repository like legos left on the carpet by my children.  The difference is you're unlikely to hurt your bare feet by stepping on the LDAP packages.

So, grasshopper, if you invest a trivial amount of time learning how LDAP works, you too can be a security and access wizard and put the lego pieces together in an afternoon and voila!  A directory server!

The cool thing about this directory server is not only can you centrally store your user's identity, you can hook to just about every other tool in the Access and Identity space.

OpenVPN?  Sure.  Apache?  Check.  Nginx?  Uh Huh.  Linux instances?  Yessir.  Containers?  Yeppers.

You can literally connect all the things with LDAP because LDAP came before all these things.

The other really slick thing is there's a good chance the client packages at the very least are not only available for your favorite system.  Odds are *they're already installed*.  

This is the case for every Mac out there.  Check it out. Typing:

    which ldapsearch
    
will yield:

    /usr/bin/ldapsearch
    
That thar is a system utility son.  Mr. Cook, and Mr. Jobs before him included that in the OS.  The only thing better than a tool that's easy to install is one that's *already there*.

# But LDAP is Hard

Yeah, it's ugly as all get out.  Even it's mother can't bear to look at it.

Here's the thing though.  There's nothing that you would ever do to an LDAP Directory that you wouldn't do to any other data source.

In short you have to be able to:

* Authenticate

* Search

* Filter

* Create, Retrieve, Update, and Delete Items

In short, it's basically just another flavor of database.  It's just got some really wonky syntax for doing so, and syntax is just that, syntax.  It's not any worse than learning another language or database spec.  You learn it, and then you know it.  Problem solved.

# LDAP History

LDAP stands for 'Lightweight Directory Access Protocol' which is 4 lies in one.  It's only 'Lightweight' insofar as it's a whole lot better than what came before it.  LDAP used the new fangled TCP/IP stack, and hence didn't have to muck about with the whole routing packets or sending signals down a wire.  That's how old it is, and why it's 'light weight'.

LDAP is technically a protocol, not a server.  It's the protocol you used to talk to x500 directory servers, which stored numbers for the Publically Switched Telephone Network (PSTN) for Ma Bell.  Yeah, your granddaddy's tech.  One step above the lady in the black and white photos wearing the headset and pushing the pins with wires into the wall of sockets to complete the telephone call.

# A (very) Short LDAP Primer

Before we can go much further, we need to learn some LDAP terms.  I promise this will be short and sweet.  There are many more terms and such you'll need to know if you want to be an LDAP master, but do you really?  I don't.  

*As an aside, my master once told me about 'Duck Kung Fu'.  Turns out there both is such a thing, and it's actually pretty nasty.  Like, ridiculously effective.  Ducks and geese fight dirty.  I asked him if he'd learned any of it, he said he had not, mostly due to ego.  He didn't want to be the 'Duck Master'.  Of course that goes both ways he said.  The ladies still think you're cool if you get creamed by the 'Tiger'.  Not so much when you get your ass kicked by the 'Duck'.*

Anyway.  Here's a short list of things you need to know:

* **DN** (Distinguished Name)  This is LDAPeze for your ID or username.  It's a unique identifier.  It'll look something like: '*cn=admin,dc=somecompany,dc=com*'.  That whole thing is the DN.  Don't panic.  Just think of it as a string.

* **Base** A base is basically a namespace.  You get namespaces, right?  A DN is only required to be unique within a namespace, which is to say a base.  The base for '*cn=admin,dc=somecompany,dc=com*' is '*dc=somecompany,dc=com*'.

* **Bind** Binding is authenticating, i.e. logging on.  That's it

* **Anonymous Bind** What you do if you try to connect to an LDAP server without authenticating.  Sometimes this is allowed, sometimes not.  Depends on how the directory server is set up.  You're *always* binding, even if you don't explicitly try to do so.  This is important to remember, because if you try to search without binding, it's going to complain at you that the 'bind failed', which will be confusing if you don't remember that you always bind, even if it's anonymously.

* **SASL** (Simple Authentication and Security Layer) Also 4 lies in one.  You generally don't care about this, but OpenLDAP, the most common implementation of LDAP tries to use this by default.  You probably don't want this.  It's not likely set up.  Instead every time you do an LDAP command you'll specify -x for 'simple authentication', i.e. a username and password.  If you forget, the system will whine about SASL and if you don't remember this line you'll be confused.

* **LDIF** LDAP Data Interchange Format.  This is basically the language by which you speak LDAP to the server.  It's goofy though, it's not really meant to be spoken or invoked.  It's meant to be written into *files* and then those files are piped to the LDAP commands.  Strange huh?  Painful, but you get used to it.  Things like newlines can be significant.  I say *can* because I have yet to figure out all the ins and outs of where they're needed.  Suffice to say if you write the commands complete with newlines into files- even temp files, things work as intended.  That's what we really want in the end, right?  It's just got to work.

That's really it.  With those factoids, you can pretty much spin up your own LDAP directory and get hacking.


# Installing the LDAP Server Slapd

I have to confess something.  'Slapd' is the most awesomest name for a daemon ever.  Come on, admit it.  Most places need a daemon in the background handing out slaps as needed, right?

LDAP is the name of the protocol, honestly, and I guess you could call the directory something like 'The Directory', though it also gets called LDAP these days.  Slapd is the server process that listens on ports 389 and/ or 636 for the LDAP protocol, and presents the directory on disk to the client.  

So, if you're wanting to run an 'LDAP Server', at least in the open source world, you're really talking about running 'slapd'.  Here's how.

## Packages

This guide is written from a RedHat perspective.  So I'm going to talk about RedHat packages, or rpm's.  Mostly it's the same stuff for any other distro.  The names may change, but there is likely a package to do something similar.  Again, this is the benefit of using the tried and true... It's already supported out of the box.

For the purposes of this guide, you'll need:

* openldap-clients

* openldap-servers

* openssh-ldap

Just doing the usual yum incantation will do, but of course, there's a couple of interesting tidbits hidden in the works.  Aren't there always?  For posterity:

#### Step 1
 
        sudo yum install -y openldap-clients openldap-servers openssh-ldap
        
## Slapd Doesn't Start by Default

For some reason, the current RedHat versions of the openldap-servers package doesn't start by default.  In fact, it's even configured to be OFF by default.  I don't understand why this is useful.  Personally, I like my directory server to come back up after a reboot, or on a first boot.  I like my directory servers to be up as much as possible, and I prefer it when they stay that way.  Call me old fashioned.

This will take care of that little oversight:

#### Step 2

        chkconfig --del slapd
        
        sed -i 's/# chkconfig: - 27 73/# chkconfig: 2345 27 73/' /etc/init.d/slapd
        
        service slapd start
        
        chkconfig --add slapd
        
There.  For the unaware, I've removed the slapd init script from chkconfig, rewritten the init script's header to actually start the service by default, started it myself, and re-added the service to chkconfig.  Whew.

# Configuring the Server

We've already covered that LDAP is old, and fugly.  It's syntax is obscure and hard on the eyes.  The LDAP community had a chance to fix this completely when they came out with the 'online config' extensions to Slapd.  Like Captain Jack Sparrow, they happily stood by and waved as that opportunity passed them by.

What I'm talking about is basically there are two kinds of LDAP configs.  There's an old one, which is basically slapd.conf, and there's this new fangled 'Online Config' or OLC format.  OLC is where the magic happens, but it had the additional effect of making the obscure and obtuse obscurer and obtuser, if that's even a word, which it is, now.  Ask anyone who's had to figure out how to deal with OpenLdap's OLC and they'll agree.  Obtuser is *definitely* a word.

How obtuse you say?  Well, once upon a time, there was a simple config file called 'slapd.conf'.  It was located in /etc/openldap, and you configured it as you pleased, and it did it's thing.  Life was good in those halcyon days, but you couldn't really make any changes without shelling into the box, changing the file, and restarting things.  

This is painfully inelegant, and if you were to make a really big change, you might have to bring down your whole fleet of directory servers.  Bringing down a single directory, much less a fleet, is something directory administrator types really do **not** like doing.  Or talking about.  Or *thinking* about.

## LDAP Directories and DevOps
Interestingly enough, that's one of the big problems inherent in running LDAP directories in a modern devops-ey type environment.   Access and Identity systems are precious commodities.  By their very nature, they tend to underpin an organizations entire infrastructure, and rightly so.  

There's no bigger red flag in a security context than multiple competing identity systems.  Of course, if everything connects to a single system, that system becomes a *single point of failure*.  Are you following the inherent contradictions here?

Andrew Carnegie once said '“Don’t put all your eggs in one basket” is all wrong. We tell you “put all your eggs in one basket, and then watch that basket.”'  He was later quote more widely by Mark Twain.  Whether you agree with this advice or not, it's generally where most security related systems come down on the question.

In the DevOps world though, we like to reverse things.  Generally speaking, if something sucks, we say we should do it **more**.  Polish off the rough edges.  Get really good at handling it.  Make the 'suck' part go away through repetition and outright *mastery* of the subject.  

Since anyone with experience will tell you that things *will* go down, let's get good at taking them down and bringing them back up.  That way, even the 'worst case scenario' becomes *yawn*  just another day.  

This is where the worlds of DevOps and Martial Arts intersect.  When you're perfectly comfortable with people attacking you with fists, feet, and even sticks, mere harsh language is no call for stress.

You can see where this is going.  Security and identity systems are designed to be these towers of stability.  Towers of stability do not go down regularly due to things like 'chaos monkey', just so you can be sure to handle their demise.  You're supposed to ensure that it can **never** go down.

## Online Configuration of LDAP

To solve this, they came up with 'OLC' or 'On Line Config", which lets you change the oil while the engine is running.  This is, as you can imagine, both a useful thing, and a messy thing.  

I suspect that, when they tried to extend the old system into a newer and fancier online-configurable thing they were really worried about staying backwards compatible with legacy systems.  This is a wonderful goal, but taken to extremes, it can saddle you with some serious cruft.  That's the big problem with OLC.

The original system wasn't built with OLC in mind, and to enable it, while still not breaking the old and familiar LDIF stuff they walked a very fine line.  One could argue that in this case, they should have just broken things, but they didn't, and we have to deal with what is.

What is in this case is a really nasty file and directory syntax that works, but even it's mother would have a hard time looking at it.  If you look in the directory ```/etc/openldap/slapd.d``` you'll see what I mean.  LDAP's antiquated config syntax does not make for friendly bash file and directory names.  It's workable, but it causes a lot of squinting.  Examples from a fresh ```/etc/openldap/slapd.d/cn=config``` :

        cn=schema  
        cn=schema.ldif  
        olcDatabase={0}config.ldif  
        olcDatabase={-1}frontend.ldif  
        olcDatabase={1}monitor.ldif  
        olcDatabase={2}bdb.ldif

Same goes for the internals of the files.  LDIF didn't really have a mechanism for dealing with hierarchies, so you see things like:

        objectClass: olcDatabaseConfig
        olcDatabase: {0}config
        olcAccess: {0}to *  by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=exter
        
Blech.

Don't let that scare you though.  It's not really greek or cyrillic.  You will not be expected to produce or edit it offhand.  If your temples immediatelly started to throb you are not alone.

## Dealing with OLC
Here's what we're gonna do.  We're gonna play "let's pretend".  A directory is basically a database.  You can speak SQL to a database, which is somewhat human readable, but what about the output?  I'm thinking of say, the console output from a typical MySQL database with all it's nice command line formatting.  You can look at it.  You can generally tease out the information you need, but you're not really expecting to process the whole output and certainly wouldn't expect to *write* it.

The LDIF, files, and directories under ```/etc/openldap/slapd.d``` are the same way.  Just forget that they're files.  You don't edit them with vi.  You read from and write too them with the various ldap commands, which will tell you if you grossly screw up the syntax, and furthermore the server itself handles updating any other peer systems.  Seen this way, it's doable.  

Personally I've read the files just enough so that I can confirm that my command took and that it looks mostly like what I thought I wanted.  After that, they could be stored in mystical Sanskrit incantations scribed on unicorn hide parchment in goat's blood by a bevy of virgin priestesses.  I don't care.  Neither do you.

## Passwords
Most passwords are stored in the LDAP configs in a hashed manner.  Most, but not all.  It could be that all are able to be stored hashed, but I have yet to figure out how to successfully do that.

Passwords are hashed using the utility ```slappasswd```  As one person I instructed in the wild ways of LDAP said "Of course it's called that.  How could it be called anything *else*?"  Yeah.  None of this is rocket science.  It does all make sense, it's heavily grounded in old school Unix history.  It just developed semi independently, and totally missed the memo on how systems should be 'user friendly'.

You just run ```slappasswd```  and that's it.

For instance:

        $ slappasswd
        New password: 
        Re-enter new password: 
        {SSHA}FM6N1jTf/0PflNiYX1GDVd0V3b/acp0w
        
For this example I used the incredible esoteric and obscure string 'fargle', and got the hash you see above.  That's good enough for most of the configs.
        
## Base Configs

First off, we set up some base credentials in LDIF files.  The following are examples that you'll have to adapt to your own needs.

### Have a Base

Above we talked about the 'base'.  You need one.  If your company is called 'fargle', and you have a website at 'fargle.com', you could use a base of say 'dc=fargle,dc=com'.  Really you could pick anything, but you'll need to remember it for the next steps.  For this discussion, we'll use a base of:

#### Step 3

    dc=fargle,dc=com

### Create an Administrator

Remember, usernames in LDAP are DN's, so a common pattern for an admin is something like:


#### Step 4

    cn=admin,dc=fargle,dc=com
    
This is, of course, not a normal user, but rather the directory admin.  Even if a user has admin-ish privileges, you'll want a separate admin user.


### Root Config LDIF

Make a file.  We'll call it 'rootConfig.ldif'.  It's contents look like:

#### Step 5

        dn: olcDatabase={0}config,cn=config
        changetype: modify
        replace: olcRootPW
        olcRootPW: {SSHA}FM6N1jTf/0PflNiYX1GDVd0V3b/acp0w
        
## Base Config

Now we start actually personalizing things for your useage.  Check this out:

#### Step 6

    dn: olcDatabase={2}bdb,cn=config
    changetype: Modify
    replace: olcSuffix
    olcSuffix: dc=fargle,dc=com
    -
    replace: olcRootDN
    olcRootDN: cn=admin,dc=fargle,dc=com
    -
    replace: olcRootPW
    olcRootPW: {SSHA}kiK3tAwYSioOigdWg5zTCLlStoopoTFm
    
Note the password.  I generated another one with the ```slappasswd``` utility.

## Schemas

Schemas are another wonderful LDAP thing.  Schemas tell the server how to represent certain types of data.  The spec is pretty wide open so you can store any information you like, as long as you can speak LDAP-ese well enough to give the server some idea of what to expect.

It would be a wonderful world if all the schemas you want were magically available to you.  Sadly, the magical 'do what I mean and anticipate all my future needs' application has yet to be written.  

When I get around to writing it, I'll let you know.  It'll be the next thing on my list after writing the 'mind reading' app.

For the space of this discussion, we're looking to have a central Access and Identity system, so we really need 2 additional schemas to make our LDAP server able to handle all the various Access and Identity things a user on a POSIX system needs to do.  These schemas are:

1. The OpenSSH LDAP extensions, supplied by the package 'openssh-ldap' installed above.  This basically gives you buckets to hold the public keys of the users that want to login to your systems.

2. A 'sudo' schema to teach LDAP how to store information that's normally found in the file ```/etc/sudoers```.

The ```openssh-ldap``` package gives you #1.  All you need to do is find it and load it thusly:

#### Step 6

        ldapadd -Y EXTERNAL -H ldapi:/// -f /path/to/rootConfig.ldif
        
If you run this as root on the box running slapd it will *just work*.  It *just works* because of the weird ```-Y EXTERNAL -H ldapi:///``` bits.  Basically that's telling ldapmodify to use the local Unix socket connection, and telling the system to use the normal Unix permission system for authentication (hence the 'external' bit).  It works for root, on the box that's running slapd.  Yes, this is scary, but then again, the number of horrible things root can do on a box is already ridiculously high, so, what's one more thing?  You're already protecting root access right?  Right?!!

*LDAP Gotcha:  There are two very similar commands.  ```ldapadd```, and ```ldapmodify```.  One adds a thing that was not there before.  The other modifies an already extant thing.  There is a rhyme and a reason to when to use each, but it's fraught with land mines and the syntax is slightly different.*

If you're a purist who is looking to master the world of LDAP, RTFM and good luck to you.  It's all in the various man pages and online.  Me?  I dig just hard enough to get the job done, and dig deeper when it becomes necessary.  

In my pragmatic world all I've been able to retain is that add and modify are different, the syntax is slightly different, and try to ascertain which one you're supposed to be using in what context.  Yes, I know that ldapadd is actually calling ldapmodify with extra flags.  I don't ever want to be deep enough in this space enough to write LDIF on the fly.  I've got better things to do with my life.  

In any event, adding a schema is definitely an 'add sort of operation'.


The ```sudo``` package gives you most of what you need for #2, but it's not quite right for use in an LDIF file.  *sigh*.

If you were to open the sudo schema, you'd see something like:

        attributetype ( 1.3.6.1.4.1.15953.9.1.1
            NAME 'sudoUser'
            DESC 'User(s) who may  run sudo'
            EQUALITY caseExactIA5Match
            SUBSTR caseExactIA5SubstringsMatch
            SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
        
        attributetype ( 1.3.6.1.4.1.15953.9.1.2
            NAME 'sudoHost'
            DESC 'Host(s) who may run sudo'
            EQUALITY caseExactIA5Match
            SUBSTR caseExactIA5SubstringsMatch
            SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )

Which is great, but ```ldapadd``` won't add it. *grumble grumble*

Some helpful soul on the internet provided the following, which is basically the same, but with the line breaks set up properly:

        dn: cn=sudo,cn=schema,cn=config
        objectClass: olcSchemaConfig
        cn: sudo
        olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.1 NAME 'sudoUser' DESC 'User(s) who may  run sudo' EQUALITY caseExactIA5Match SUBSTR caseExactIA5SubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
        olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.2 NAME 'sudoHost' DESC 'Host(s) who may run sudo' EQUALITY caseExactIA5Match SUBSTR caseExactIA5SubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
        olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.3 NAME 'sudoCommand' DESC 'Command(s) to be executed by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
        olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.4 NAME 'sudoRunAs' DESC 'User(s) impersonated by sudo (deprecated)' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
        olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.5 NAME 'sudoOption' DESC 'Options(s) followed by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
        olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.6 NAME 'sudoRunAsUser' DESC 'User(s) impersonated by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
        olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.7 NAME 'sudoRunAsGroup' DESC 'Group(s) impersonated by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
        olcObjectClasses: ( 1.3.6.1.4.1.15953.9.2.1 NAME 'sudoRole' SUP top STRUCTURAL DESC 'Sudoer Entries' MUST ( cn ) MAY ( sudoUser $ sudoHost $ sudoCommand $ sudoRunAs $ sudoRunAsUser $ sudoRunAsGroup $ sudoOption $ description ) )
        
So just copy that into a file called 'sudo.ldif' and run it like so:

        ldapadd -Y EXTERNAL -H ldapi:/// -f /path/to/sudo.ldif

## Access Control Lists

These control who can access what in your directory.  I'll provide you an example of one I've used.  You can decide if it's too much, or not enough for your organization.

acls.ldif:

        dn: olcDatabase={2}bdb,cn=config
        add: olcAccess
        olcAccess: to attrs=cn,sn,email,loginShell,sshPublicKey
          by self write
          by dn="cn=admin,dc=fargle,dc=com" write
          by * read
        -
        add: olcAccess
        olcAccess: to attrs=userPassword
          by self write
          by anonymous auth
          by dn="cn=admin,dc=fargle,dc=com" write
          by * none
        -
        add: olcAccess
        olcAccess: to *
          by self read
          by dn="cn=admin,dc=fargle,dc=com" write
          by anonymous read
          by * read
          
This should read pretty easy to anyone conversant in both code and English.  Basically I'm saying:

1. 'cn', 'sn', 'email', 'loginShell', and 'sshPublicKey' can be written by the person or the admin user, and are readable by anyone else.

2. The field 'userPassword' can be written by one's self, can be used by the anonymous user for login purposes. *(basically it asks you for your password, hashes it, and compares the hash to what's in the directory.  If they match, you're considered to be you.)*  Admin can write this value (admin reset password), and pretty much everybody else is explicitly blocked.  

3. The last stanza opens the whole of every entry to anonymous reads, with the exception of the directives above it.  In our case, we wanted anyone to be able to read the information with the exception of the user password.

#### Step 7

Load your acls thusly:

        ldapmodify -Y EXTERNAL -H ldapi:/// -f /path/to/acl.ldif 

## Base Client Configs

LDAP Directories and Clients are very flexible things.  They can be configured to do all sorts of magic, but you generally need a very small subset to get the job done.

By default, you have to specify the 'host' and the 'base' on every LDAP operation.  This leads to truly lengthy gibberish that will drive you to drink.

You can prevent a lot of this by doing the following:

#### Step 8

    echo "BASE dc=fargle,dc=com" >> /etc/openldap/ldap.conf
    echo "URI ldap://localhost:389" >> /etc/openldap/ldap.conf

This is modifying the system- wide base ldap *client* config file to have a default BASE and a default URI.  If you don't do this, then every LDAP command would also have to have ```-H ldap://host:389 -b dc=fargle,dc=com``` in it.  I'm guessing you don't want to do that.  Remember this.  You'll do it on the servers, on the clients, and probably on your laptop.

## Sync Configs

This is where you make each instance running ```slapd``` into a master on the council of masters.  It gets a little weird.  You can do it though, so stay with me.

LDAP's intended role as an unassailable tower rears it's ugly head here.  It really doesn't want to be dynamic, but you can make it be so if you sweet talk it just right.

### Server ID

#### Step 9

Each master needs a unique ID.  On each server, you have to write serverId.ldif.  Each one is slightly different:

        dn: cn=config
        changetype: modify
        add: olcServerID
        olcServerID: 1
        
And load it via:

        ldapmodify -Y EXTERNAL -H ldapi:/// -f /path/to/serverId.ldif
        
Obviously on server 2 you use olcServerID: 2, and so on for however many master seats there are at your particular table.  In our case, we have 2, so this is the config for ```ldap-blue.fargle.com```.

### Sync Module
N-Way Multimaster is just one of many ways you can set up directories.  No particular design is forced upon you.

#### Step 10

So, since it's up to you, you need to load it.  Write syncModule.ldif like so:

        dn: cn=module,cn=config
        objectClass: olcModuleList
        cn: module
        olcModulePath: /usr/lib64/openldap
        olcModuleLoad: syncprov.la
        
Install it via:

        ldapadd -Y EXTERNAL -H ldapi:/// -f /path/to/syncModule.ldif
        
#### Step 10.5

Debug logging is occasionally useful.   You can enable it by writing a debugLog.ldif:

        dn: cn=config
        changetype: modify
        replace: olcLogLevel
        olcLogLevel: 65
        
Load it with the now familiar:

        ldapadd -Y EXTERNAL -H ldapi:/// -f /path/to/debugLog.ldif
        
### Config Synchronization

The following allows the OLC config settings to sync between masters.  This is the internal config of the directory itself, not the data you're going to put into the directory.  Yes, you want this to replicate.

#### Step 11

Write configSync.ldif, noting that this is a per-server type of config.  This is the config for ```ldap-blue.fargle.com```:

        dn: cn=config
        changetype: modify
        replace: olcServerID
        olcServerID: 1 ldap:///
        olcServerID: 2 ldap://ldap-gold.fargle.com
        
        dn: olcOverlay=syncprov,olcDatabase={0}config,cn=config
        changetype: add
        objectClass: olcOverlayConfig
        objectClass: olcSyncProvConfig
        olcOverlay: syncprov
        
        dn: olcDatabase={0}config,cn=config
        changetype: modify
        add: olcSyncRepl
        olcSyncRepl: rid=001 provider=ldap:/// binddn="cn=config" bindmethod=simple
          credentials=__CONFIG_CREDENTIALS__ searchbase="cn=config" type=refreshAndPersist
          retry="5 5 300 5" timeout=1
        olcSyncRepl: rid=002 provider=ldap://ldap-gold.fargle.com binddn="cn=config" bindmethod=simple
          credentials=__CONFIG_CREDENTIALS searchbase="cn=config" type=refreshAndPersist
          retry="5 5 300 5" timeout=1
        -
        add: olcMirrorMode
        olcMirrorMode: TRUE
        
And load it:

        ldapmodify -Y EXTERNAL -H ldapi:/// -f /path/to/configSync.ldif
        
Note the __CONFIG_CREDENTIALS__ tokens.  Yeah, you have to write in the creds to that file.  Yucky, I know.  If you're using a config management system such as Chef or Puppet you can write them in when you make the file.  I've also been known to pull the creds from something like Vault or AWS Parameter Store at launch time and paste 'em into the file via good old ```sed```.  Either way, you probably want to clean up the resulting file once you're done.

Also note we refer to both servers in both server configs.  Slapd works out the difference, even though the configs are replicated, each server can work out which one it is if the initial config is right.  Again, I'm not a master of this stuff.  I just worked out how to make it, well, work.

Usually I refer to 'this' server via ldap:///  and the 'other' server via it's url.  That's a convention that has worked for me.  YMMV.

### Data Synchronization

Now we sync the data.

#### Step 12

Write dataSync.ldif:

        dn: olcDatabase={2}bdb,cn=config
        changetype: modify
        add: olcLimits
        olcLimits: dn.exact="cn=admin,dc=fargle,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited
        -
        add: olcSyncRepl
        olcSyncRepl: rid=003 provider=ldap:/// binddn="cn=admin,dc=fargle,dc=com" bindmethod=simple
          credentials=__ADMIN_PASSWORD__ searchbase="dc=fargle,dc=com" type=refreshAndPersist
          interval=00:00:00:10 retry="5 5 300 5" timeout=1
        olcSyncRepl: rid=004 provider=ldap://ldap-gold.fargle.com binddn="cn=admin,dc=fargle,dc=com" bindmethod=simple
          credentials=__ADMIN_PASSWORD__ searchbase="dc=fargle,dc=com" type=refreshAndPersist
          interval=00:00:00:10 retry="5 5 300 5" timeout=1
        -
        add: olcMirrorMode
        olcMirrorMode: TRUE
        
        dn: olcOverlay=syncprov,olcDatabase={2}bdb,cn=config
        changetype: add
        objectClass: olcOverlayConfig
        objectClass: olcSyncProvConfig
        olcOverlay: syncprov
        
Once again, notice the __ADMIN_PASSWORD__ tokens.  You'll need to replace them via your favorite method.  Don't forget to clean up afterwards.


And load it via *(One more time, with feeling!)*:

        ldapmodify -Y EXTERNAL -H ldapi:/// -f /path/to/dataSync.ldif

And that's basically it.


# LDAP Summary

What you have now, if you've executed all the above steps correctly, faithfully, and without fat fingering it is a set of 2 boxes that will share data and config between themselves.  

So long as one of the servers is up, you can replace the other one and the new server will automatically replicate off the old one.  There is a slight replication lag in which the data from each server may be inconsistent.  I have not been able to really pin down.  There's a time period wherein a server will ask for updates, but they also publish changes to each other.  Again, dig further if you care to.  There's a lot of depth there.

A careful observer will note that there's nothing in here about actually *filling* the directory with data here.  That's by design.

In my case, I had another process that backed itself up before pulling user and group data from the SSO source of record, and populating the directory with the new info.  It added new users, cleaned out old users, and then walked the directory in a paranoid fashion and removed anything that was not found in the SSO.  Paranoid.  Yup.  Gotta be.

I also have not included any password rules regarding strength, aging, reuse, etc.  There are plenty of guides out there that can help you do that.  Basically you craft an ldif, and load it in.  Same old same old.

# To be Continued....

Stay tuned for the user side configs to make any container or linux instance use the above LDAP servers as their source of truth.
