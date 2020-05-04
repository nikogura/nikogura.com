# Managed Secrets

Secrets management is an important job, but it sucks.  There.  I said it.

Everybody needs secrets.  What's so hard about them?

First off, anyone who's actually run/managed a secrets system of any size knows that making sure your app has the secrets it needs is just the tip of the iceberg.  

Yeah, that's all the developers care about.  It's all most people think of.  Just about any solution can provide for that use case.

For the unsung heroes who maintain the system however, there's more.  Quite a lot more.  Ask any security pro or *gasp*, an auditor.

## Nonfunctional Requirements

Here's a short list of the 'other' concerns behind a secrets system:

* Audit (who has access to what?)

* Logging (Who accessed what when?)

* 'Rotation' (i.e. changing secrets)

* Granting of access

* Revocation of access

* Generating hard to guess secrets

* Portability and Disaster recovers (What happens if you lose the system containing your secrets?)

The problem with all the above tasks is, they're necessary, and individually they're not hard.  

They are, however, time consuming and inglorious, so most of the time, they _don't get done_.

What's that you say?  They don't get done?  Surely you jest.  No conscientious engineer would allow that laundry list of things to languish in the bottom of the ticket backlog.

I'm dead serious- and don't call me 'Shirley'.  *(Come on, I had to use that!  I'm not writing this for my health.  I must educate _and_ entertain!)*

## The Case for Managed Secrets

