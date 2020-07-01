# Managed Secrets

Secrets management is an important job, but it sucks.  There.  I said it.

Everybody needs secrets.  What's so hard about them?

How you store secrets and how you access them is all the developers care about.  It's all most people think of.  Just about any solution can provide for that use case.

Anyone who's actually run/managed a secrets system of any size knows that storage and access, while critical, are just the tip of the iceberg.  

There's more.  Quite a lot more.  Ask any security pro or *gasp*, an auditor.

## Functional Requirements of a Secrets System

* *Define Secrets*  You need to 'make a secret'.  This is similar to declaring memory.  You're making a 'bucket' in your system that can be filled by some value.

* *Set / Reset Secrets*  This task fills the 'bucket' created in the 'Define Secrets' task.  It has to be able to be done programmatically so that it can be changed regularly/easily/quickly.

* *Define / Provide / Revoke Access to Secrets*  Define groups of entities ('roles') who can access the secrets.

As a MVP, that's pretty much it.  The rest is all gravy.  *Any* backend system aught to be able to handle those tasks, but they all need to be automated.  

If they're manual, they won't be done as often or as quickly as needed.  That's just human nature.

## Nonfunctional Requirements of a Secrets System

Here's a short list of the 'other' concerns behind a secrets system:

* Audit (who has access to what?)

* Logging (Who has accessed what?  And when?)

* 'Rotation' (i.e. changing secrets) *Personally I hate this term.  We don't rotate secrets, we change them.*

* Granting of access to secrets

* Revocation of access to secrets

* Generating hard to guess secrets

* Portability and disaster recovery (What happens if you lose the system containing your secrets?)

The problem with all the above tasks is, they're necessary, and individually they're not hard.  

They are, however, time consuming, boring, and inglorious, so most of the time, they _don't get done_.

What's that you say?  They don't get done?  Surely you jest.  No conscientious engineer would allow that laundry list of things to languish in the bottom of the ticket backlog.

I'm dead serious- and don't call me 'Shirley'.  When's the last time your secrets were rotated?  Ask somebody in your company.  Bet the response is something like "Uh... Probably never?".

## Secret Storage Backends

There are a bazillion of them to choose from.  Every one of them has some way of getting your secret to your application, and I'm here to tell you which one you use *doesn't friggin matter*.  

Yes, you heard that. What secret backend you choose really doesn't matter.  (Within reason anyway.)

How can I say that?  Because any secret storage backend worth considering, specially one offered by a reputable cloud provider or serious Open Source software vendor probably has all it's little duckies in a row.

Big cloud providers like Amazon and Google almost certainly have their solutions audited/reviewed/vetted/certified by people who break into systems for a living.  Others like Hashicorp Vault are Open Source, and anyone can read, peruse, comment, and propose changes.

Odds are, unless you're trying to use something some idiot whipped up on a cocktail napkin, the secret storage backend of your choice is probably pretty decent.

Security software that's sufficiently paranoid to protect your secrets is actually not that hard to write.  You know what's hard?  Dealing with Humans.

## Humans are the Problem

Ask any Sysadmin.  The biggest headache they have are the users.  (Operators of computer systems of course spell it with a silent 'l' - luser.)

We humans like to do what we're interested in doing, and we don't like being distracted by details that get in our way.  

Case in point?  Every use a public WiFi access point?  Hmm?  You'd be hard pressed to find a more *IN* secure means of using a computer.  

You'd never lick the seat of a public toilet, but we'll all connect to a public WiFi without even thinking about it.  (And yes, it's more or less the same thing, electronically speaking.  At least the toilet is cleaned on some schedule.  The router at Starbucks?  Odds are it hasn't been touched since it was first plugged in.)

The worst four letter word in technology is - wait for it - 'just'.  As in, "I *just* want to do X.", or "I'm *just* trying to do Y.".  We humans happily ignore anything that doesn't interest us and gets in the way of something that does.

Humans are the weak point in any security system.  If it's boring, or tedious, or not directly and visibly part of our 'job description', we generally don't do it.

That's why secrets sit un-rotated - forever.  Human Nature.

The key to a successful secrets system lies in Human Nature.  In understanding it.  In finding ways to make it work for you.

Nobody ever (or at least rarely) thinks "I think I'm going to cause a data breach that destroys my company today.".  No, they *just* want to get 'their job' done.

They'll do just about anything to meet that goal.  If you can make the 'most secure' way also the 'easy way', they'll do anything you ask.

Laziness can be a powerful ally.

## UX is the Key

User Experience is the single most important factor in any tool's adoption or success.  Face it, if it's a pain to use, it will be ignored, replaced, or circumvented.

That laundry list of 'nonfunctional requirements' listed above will never get done if your users are required to do any of them.  They don't care.  They *just* want their app to get it's secrets.

You also can't *hire* anyone worth anything to do all that stuff, cos face it, it's a boring job that can be better done by a computer.

The trick is getting the computer to do all the shit work so we humans can do what we do best - work on things we find interesting.

## The Case for Managed Secrets

The perfect secret system should:

* make it easy for the right consumers to access secrets, and conversely, deny access to all others.

* make it easy to state categorically both who *can* access a secret, but also *who has* accessed it.

* make granting and revoking access easy

* make it easy to *generate* and *change* secrets

* version all secrets so that we can rollback or at least recover a previous value, cos verily, shit doth happen.

* vary secrets by environment

* provide a means for someone to *define* secrets, even though they cannot access the production values

* allow developers to freely access development secrets, while denying access to 'higer' environments (such as production)

* provide a means to detect whether a secret has been changed or rotated.

* make it so nobody has to have the horrible job of entering secrets into any sort of interface for a system they don't support, know nothing about, and frankly, care nothing about.

The computer should make this all happen, freeing the humans to *just* do their jobs.

##  What is 'Managed Secrets'

Managed Secrets is basically a system in which you define your secret's metadata in yaml, and let the tools do the rest.

It's essentially a *yaml interface on your secret access and storage system*.

Let's say that again:  *Managed Secrets is a YAML Interface on your Secret System*.  The code takes care of translating what you have placed in your YAML file, and translates that into reality in your secret storage system.

That's what makes this approach so cool.  Everybody gets what they want.  Developers can 'just get secrets'.  Security Engineers and Auditors can get the reports/alerts they want.

Secrets can be rotated on schedule or on demand as needed.  Everybody wins.

## Implementation

I chose [Hashicorp Vault](https://www.vaultproject.io/) as the backend for my reference implementation, but you could write backends for AWS Secrets Manager, or SSM Parameter Store, or any other system.

I wrote it in Golang, because go has the wonderful ability to compile everything down to single binaries without dependencies, and easily cross compile for OS'es other than the one I, the author, work in.

None of these choices mean jack.  I could have written it in Ruby and backed it by AWS SSM Parameter Store.  The backend and the language really, Really, REALLY don't matter.  It's the UX that counts here.

Too many people get lost in 'solutioning' and can't see the forest for the trees.  You create tools for users.  Users don't care about what's going on under the hood.  They care that the car goes when they want to go, and stops when they want to stop.

Design your tools for your users- one of which is undoubtedly yourself.  You want powerful, easy to use tools don't you?  I sure do.

### Managed Secrets Components

There are 4 components to Managed Secrets, as originally implemented by me.  (I'm no longer the custodian of the repos, so who knows what's changed.)

* [Keymaster](https://github.com/scribd/keymaster) - Library for configuring and managing your secret storage and access system.

* [Vault-Authenticator](https://github.com/scribd/vault-authenticator) - Library for granting access to your secrets.

* [Secrets](https://github.com/scribd/secrets) - Tool demonstrating how to use *vault-authenticator* to access secrets.

* [Keymaster-CLI](https://github.com/scribd/keymaster-cli) - Tool demonstrating how to use *keymaster* to read secret definitions and make the machine manage your secrets.

These repos conform to my idea of [MVC-Ish](MVC-Ish.md).  In short, it's 2 binaries that exercise libraries in the other repos.  It was my intention that the libraries be used by other systems (programs, services, Lambda's, etc), but the CLI binaries would provide both a reference implementation and a default tool that anyone could use from the CLI or a bash script.

This code, combined with a YAML config file, takes all the sting out of managing secrets for you, and for your users.  Again, I wrote the reference implementation with Vault as a backend, and Vault is the Cadillac of secret storage engines, but the idea was that I could swap out the backend at anytime and my users wouldn't know or care.  

Users don't interact with the storage system.  They just write YAML files.  Like this one:

#### Config Example

This example defines a Team, which is any logical grouping of people in a company.

    ---
    name: test-team1                        # The name of the Team
    secrets:                                # Definitions of the Secrets in the Team
      - name: foo
        generator:
          type: alpha                       # A 10 digit alphanumeric secert
          length: 10

      - name: bar
        generator:
          type: hex                         # A 12 digit hexadecimal secret
          length: 12

      - name: baz
        generator:
          type: uuid                        # A UUID secret

      - name: wip
        generator:
          type: chbs
          words: 6                          # A 6 word 'correct-horse-battery-staple' secret.  6 random commonly used words joined by hyphens.

      - name: zoz
        generator:
          type: rsa
          blocksize: 2048                   # A RSA keypair expressed as a secret (Not currently supported)
          
      - name: blort                         # I've clearly run out of standard throwaway names here.
        generator:
          type: static                      # Static secrets have to be placed manually.  API keys are a good use case for Static Secrets.

      - name: foo.example.com
        generator:
          type: tls                         # A TLS Certificate/ Private Key expressed as a secret.
          cn: foo.example.com
          ca: service                       # This cert is created off of the 'service' CA
          sans:
            - bar.example.com                # Allowed alternate names for this cert
            - baz.example.com
          ip_sans:                          # IP SANS allow you to use TLS and target an IP directly
            - 1.2.3.4
            
    roles:                                  # Your Secret Roles  This is what you authenticate to in order to access the Secrets above.
      - name: app1                          # A role unimaginatively named 'app1'
        realms:
          - type: k8s                       # legal types are 'k8s', 'tls', and 'iam'
            identifiers:
              - some-k8s-cluster            # for k8s, this is the name of the cluster.  Has no meaning for other realms.
            principals:
              - app1                        # for k8s, this is the namespace that's allowed to access the secret
            environment: production         # each role maps to a single environment.  Which one is this?

          - type: tls                       # 'tls' specifies authenticated by client certs (generally only applies to SL hosts)
            principals:
              - fargle.example.com          # for tls, this is the FQDN of the host
            environment: development        # when this host connects, it gets development secrets

          - type: iam                       # only works if you're running in AWS
            principals:
              - "arn:aws:iam::888888888888:role/some-role20201234567890123456789012"
            environment: staging            # each principal auths to a role in a single environment.
        secrets:
          - name: foo                       # These Secrets are defined above.  No 'team' in the config means 'team from this file'
          - name: wip
          - name: baz
            team: test-team2                # This secret is owned by another Team.
            
    environments:                           # Environments are just strings.  Use whatever you want.   Many people would like Scribd to use standardized Environment names.  That's a people problem, not a tech problem.  To the code, they're all just strings.
      - production
      - staging
      - development                         # The 'development' environment is special.  If you have one, anyone who can authenticate can access development secrets.  This is intended to ease/ speed development.
      
With the above file, all you need is a properly configured instance of [Keymaster-CLI](https://github.com/scribd/keymaster-cli) to configure the secrets backend.

Your systems can use [Keymaster-CLI](https://github.com/scribd/keymaster-cli) (or something like it) to authenticate and get their secrets.  

Heck, if they really want to, they can interact directly with the secrets backend directly.  The storage and access system of your backend is still there, and could be used.  The libraries described here are just a control / management plane on the backend.
 
Why someone would want to connect directly to the backend is beyond me.  Doing so makes whatever you're using *less* portable, and makes it more likely you'll have to go back and change your code when the secret storage system changes or upgrades.

Managed Secrets is an interface.  Interfaces are like fences.  Good fences make for good neighbors.  

Managing a secrets system is like making sausage.  The diner doesn't care how the sausage gets made.  They just get to take a bite and enjoy.  *yum*


... to be continued 








