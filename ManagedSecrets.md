# Managed Secrets

Secrets management is an important job, but it sucks.  There.  I said it.

Everybody needs secrets.  What's so hard about them?

First off, anyone who's actually run/managed a secrets system of any size knows that making sure your app has the secrets it needs is just the tip of the iceberg.  

Yeah, that's all the developers care about.  It's all most people think of.  Just about any solution can provide for that use case.

For the unsung heroes who maintain the system however, there's more.  Quite a lot more.  Ask any security pro or *gasp*, an auditor.

## Nonfunctional Requirements

Here's a short list of the 'other' concerns behind a secrets system:

* Audit (who has access to what?)

* Logging (Who has accessed what?  And when?)

* 'Rotation' (i.e. changing secrets) *Personally I hate this term.  We don't rotate secrets, we change them.*

* Granting of access to secrets

* Revocation of access to secrets

* Generating hard to guess secrets

* Portability and Disaster recovery (What happens if you lose the system containing your secrets?)

The problem with all the above tasks is, they're necessary, and individually they're not hard.  

They are, however, time consuming and inglorious, so most of the time, they _don't get done_.

What's that you say?  They don't get done?  Surely you jest.  No conscientious engineer would allow that laundry list of things to languish in the bottom of the ticket backlog.

I'm dead serious- and don't call me 'Shirley'.  *(Come on, I had to use that!  I'm not writing this for my health.  I must educate _and_ entertain!)*

## Secret Backends

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

* make it so nobody has to have the horrible job of entering secrets into any sort of interface for a system they don't support, know nothing about, and frankly, care nothing about.

The computer should make this all happen, freeing the humans to *just* do their jobs.

##  What is 'Managed Secrets'

Managed Secrets is basically a system in which you define your secret's metadata in yaml, and let the tools do the rest.

It's essentially a *yaml interface on your secret access and storage system*.

Let's say that again:  *Managed Secrets is a YAML Interface on your Secret System*.  The guts take care of translating what you have stated that you want in a yaml file into action in your backend.  

That's what makes this approach so cool.  Everybody gets what they want.  Developers can 'just get secrets'.  Security Engineers and Auditors can get the reports/alerts they want.

Secrets can be rotated on schedule or on demand as needed.  Everybody wins.

## Implementation

I chose [Hashicorp Vault](https://www.vaultproject.io/) as the backend for my reference implementation, but you could write backends for AWS Secrets Manager, or SSM Parameter Store, or any other system.

I also wrote it in golang, because it has the wonderful ability to compile everything down to single binaries without dependencies, and easily cross compile for OS'es other than the one I the author work in.

None of these choices mean jack.  I could have written it in Ruby and backed it by AWS SSM Parameter Store.  Really, Really, REALLY doesn't matter.  It's the UX that counts here.


### Managed Secrets Components

There are 4 components to Managed Secrets, as originally implemented by me.  (I'm no longer the custodian of the repos, so who knows what's changed.)

* https://github.com/scribd/keymaster - Library for configuring and managing your secret storage and access system.

* https://github.com/scribd/vault-authenticator - Library for granting access to your secrets.

* https://github.com/scribd/secrets - Tool demonstrating how to use *vault-authenticator* to access secrets.

* https://github.com/scribd/keymaster-cli - Tool demonstrating how to use *keymaster* to read secret definitions and make the machine manage your secrets.

These repos conform to my idea of [MVC-Ish](MVC-Ish.md).  In short, it's 2 binaries that exercise libraries in the other repos.  It was my intention that the libraries be used by other systems (programs, Lambda's, etc), but the cli binaries would provide both a reference implementation and a default tool that anyone could use from the CLI or a bash script.

... to be continued 








