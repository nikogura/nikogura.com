---
title: 'Put Dex In Front of Google OAuth'
excerpt: Google OAuth has two surprises that make every internal-service auth story uglier than it should be. The standard workaround involves domain-wide delegation and a service account JSON key shipped to every application that wants group-based authorization. There is a much better answer that doesn't require any of that.
publishDate: 'May 27 2026'
tags:
  - Identity
  - Infrastructure
  - Security
  - IAM
isFeatured: false
---

## You Probably Don't Need Domain-Wide Delegation

Google OAuth won't issue you a public client, and it won't put groups in an ID token. Both are documented, both have well-known workarounds, and both workarounds are uglier than they need to be. The standard answer for the second one — domain-wide delegation with a service account JSON key per application — gets recited so reflexively that I've watched teams adopt it for problems that don't even need group information in the first place.

You don't have to live with any of that. Put Dex in front of Google and split authentication from authorization, and the two surprises become Dex implementation details that you stop thinking about. You can do it without ever asking your Workspace Admin for a DWD grant. The piece I'm proudest of figuring out is that for most internal services, you don't actually need groups at all.

## Google OAuth Doesn't Do Public Clients

Every OAuth client you register in the Google Cloud Console gets issued a `client_secret`. Every one. Including the "Desktop app" type, which is supposedly designed for distributed CLI tools that obviously can't keep a secret. Google's own documentation acknowledges that the secret isn't really a secret in this case — PKCE is what protects you — but they hand it out anyway, and your CLI's config file has to include it.

So `claude mcp add` requires `--client-secret`. So does `gcloud`. So does every native-app Google OAuth integration I've ever wired up. The "secret" ends up in every user's `~/.config/whatever/config.json`, distributed widely enough that it's clearly not confidential, but ceremoniously enough that everyone has to keep producing it and treating it like it matters.

OAuth has had a public-client type since [the original RFC](https://datatracker.ietf.org/doc/html/rfc6749#section-2.1) in 2012. PKCE has been the standardized hardening since 2015. Google just doesn't issue them.

## Google ID Tokens Don't Carry Groups

This is the more load-bearing one, and it isn't obvious from the Google Cloud Console. **No matter what scopes you request, no matter what consent-screen settings you choose, no matter which OAuth client type you use, the ID tokens Google issues do not contain a `groups` claim.** There is no toggle. There is no setting. Google's OAuth surface simply doesn't carry that information.

Group membership lives in the Workspace **Admin SDK Directory API**, which is a completely separate surface. To call it, you need:

- A service account in your Google Cloud project
- A JSON key file for that service account, distributed to whichever application is going to make the API call
- A Workspace Admin to authorize that service account for `admin.directory.group.readonly` via domain-wide delegation
- Code in your application that does the impersonation dance: "I'm the service account, acting on behalf of `admin@yourdomain.io`, asking for groups for `alice@yourdomain.io`"

That's a lot of moving parts. Service account keys are credentials that have to be rotated, mounted, secured. The DWD grant has to be requested and approved. The impersonation grant is configured per scope, per service account, per Workspace.

You do all of this *per application*. Every internal service that wants Google-Workspace-group-based access control gets its own service account, its own JSON key, its own implementation of the Admin SDK call, its own bug in the retry logic. Or, more commonly, you give up and use something cruder.

## The Two Things People Usually Do, Both Bad

**Option A: Ship the client secret to every user.** Common, works because PKCE saves you, but every user's config file ends up holding a non-secret labeled "secret." People see that and either treat it with inappropriate ceremony, or — worse — treat *real* secrets with the same casualness. The aesthetic and operational drag is real even when nothing is actually compromised.

**Option B: Do DWD per application.** You get groups, at the cost of every application owning a service account key and importing a Google API client library. The auth code knows about Workspace specifically. The service-account JSON has to be mounted into the pod, rotated, audited. You repeat this for every internal service that wants group-based authz.

Both options bake Google into your application stack. Switch identity providers and you rip out the integration.

## Dex Is Both Sides of Itself

[Dex](https://dexidp.io/) is a small Go service that presents an OIDC interface to anything that wants to authenticate users. Behind the scenes it federates to *upstream* identity providers via connectors — Google, GitHub, LDAP, SAML, generic OIDC. To your downstream applications, Dex is a generic OIDC provider. To the upstream IdP, Dex is a normal OAuth client.

The trick: "OAuth client" and "OIDC provider" are different roles, and Dex plays both simultaneously, on opposite sides of itself.

```
Your app  ─── OIDC ───►  Dex  ─── OAuth ───►  Google
       (validates JWT)         (acts as OAuth client to Google)
```

Three things change the moment you do this.

### Public Clients Come Back

Dex supports `staticClients[].public: true`. That's a *real* public client — no secret on either side of the `your-app ↔ Dex` relationship. PKCE handles security. The `client_id` you distribute is just a string, "diagnostic-bot" or whatever you named it; knowing it doesn't let anyone authenticate as anyone.

`claude mcp add --client-id diagnostic-bot --callback-port 8080`. No `--client-secret`. Done.

The "Google doesn't do public clients" problem becomes a Dex implementation detail. Dex *does* do public clients. You no longer care what Google supports.

### Groups Get Solved Once — If You Need Them

This section is conditional. **If your authz policy is domain-based or email-based, skip it and go to the next section — you won't need DWD anywhere.** Read on only if you genuinely need group-membership-based authz, in which case Dex makes it dramatically less painful than the per-application alternative.

Dex's Google connector can take a service account file, an admin email, and a list of allowed groups. When you configure it that way, Dex does the DWD impersonation dance on behalf of *every* downstream application that connects through it. The JWT Dex issues includes a `groups` claim populated from the Admin SDK call Dex made. Dex isn't synthesizing the data — it's making the same Admin SDK call any application would have to make, just doing it once on everyone's behalf.

Your application doesn't know any of this is happening. It validates a JWT. Reads a `groups` claim. Applies its policy. It doesn't import a Google SDK. It doesn't hold a service account key. It doesn't know what Workspace is.

You set up DWD once, on Dex's service account, with one Workspace Admin grant. Every internal service backed by that Dex gets groups for free. Compared to the per-application alternative — N service accounts, N JSON keys, N implementations of the Admin SDK call — that's the substantive win on the groups axis.

### The IdP Becomes Replaceable

Your applications validate JWTs from `https://dex.yourcompany.io`. That's it. If you move from Google to Okta tomorrow, you swap a connector in Dex's config and nothing in your applications changes. The IdP is a Dex implementation detail.

## You Probably Don't Need Groups Anyway

Here's the part I'm proudest of: **for most internal services, you don't need group claims at all — and if you don't, you don't need DWD anywhere in the stack.** Not on Dex, not on your applications, nowhere. The previous section becomes irrelevant. Your Workspace Admin never sees a delegation request. No service account JSON key gets minted.

Ask what your authorization policy actually is. For an internal MCP server I run, the policy is binary: a small allowlist of humans can use the server in full; everyone else gets `401`. The connection-level gate is two env vars stacked as defense-in-depth:

- `MCP_OIDC_ALLOWED_HOSTED_DOMAINS=katn-solutions.io` — first filter. Anyone outside the Workspace is rejected, full stop. Derived from the `@`-suffix of the JWT's `email` claim.
- `MCP_OIDC_ALLOWED_EMAILS=alice@katn-solutions.io,bob@katn-solutions.io,nik@katn-solutions.io` — second filter. Even inside the Workspace, only these specific humans get through. Exact match on `email`.

A request has to clear both filters to reach a tool. Stacking them this way is the actual win: the domain filter catches the obvious "wrong company entirely" case at the cheapest possible check; the email allowlist narrows from "anyone with a Workspace seat" to "these specific people who run this thing." If someone leaves the team, dropping them from `MCP_OIDC_ALLOWED_EMAILS` is a one-line config change. If someone leaves the company entirely, Workspace Admin handles it before that env var even gets read.

Both filters derive from the `email` claim, which Google emits for free in any ID token requested with the `email` scope. No DWD. No service account. No Workspace Admin SDK calls. Anywhere in the stack.

The split is what makes this possible. The IdP (Google, via Dex) handles **authentication** — proving the user is who they claim to be. The application (the bot) handles **authorization** — given a verified identity, deciding what they can do. Stop trying to make the IdP do both jobs, and "what's after the `@` in this email?" turns out to be sufficient for the overwhelming majority of internal-service authz policies.

What you get:

- No client secrets in user-side configs.
- No domain-wide delegation grant from your Workspace Admin.
- No service account JSON key to rotate.
- No Workspace Admin SDK API calls at runtime.
- No Google-specific code in your application.

What you give up:

- Managing access entirely through Google Group membership without per-application config changes.

That's a good trade for most teams. Group-based access is appealing in the abstract — "just add them to the group" — but in practice you also have to add them to whatever team, project, or on-call rotation gives them context for using the tool, and that's a separate workflow anyway. A small allowlist in a Helm values file isn't more friction than that.

## What This Looks Like Running

Concretely, in production today:

**Dex** runs as a single Kubernetes Deployment behind an Ingress with a TLS cert. Its config has a Google connector — no DWD, no service account, no `groups:` block — and a `staticClient` per internal service:

```yaml
connectors:
  - type: google
    id: google
    name: Google
    config:
      clientID:     <dex's-google-client-id>.apps.googleusercontent.com
      clientSecret: <dex's-google-client-secret>   # Stays on Dex's pod
      redirectURI:  https://dex.yourcompany.io/callback
      hostedDomains:
        - yourcompany.io

staticClients:
  - id: diagnostic-bot
    name: Diagnostic Bot MCP
    public: true
    redirectURIs:
      - http://localhost:8080/callback
```

**The bot** validates JWTs from Dex. Two env vars handle the authz layer:

```
MCP_OIDC_ISSUER=https://dex.yourcompany.io
MCP_OIDC_AUDIENCE=diagnostic-bot
MCP_OIDC_ALLOWED_HOSTED_DOMAINS=yourcompany.io
MCP_OIDC_ALLOWED_EMAILS=alice@yourcompany.io,bob@yourcompany.io
```

**Each user** adds the bot to Claude Code with:

```
claude mcp add diagnostic-bot https://bot.yourcompany.io/mcp \
  --transport http \
  --client-id diagnostic-bot \
  --callback-port 8080
```

That's it. First invocation pops a browser, the user signs in with their Workspace account through Dex through Google, gets back a JWT, the bot validates it, and from then on every Grafana write the bot makes shows the human's actual email in the version history. Suspend a user in Workspace Admin and their next token refresh fails. They're locked out. No code changes anywhere when someone joins or leaves the team — Workspace membership is the gate.

## The Tradeoff

You have to run Dex. If you're already running it for something else — Kubernetes auth, internal SSO, an SSH-key connector for `kubectl` — this is free. If you're not, it's one deployment with a small resource footprint, and once it's there you'll find more uses for it. The next internal service authenticates against the same Dex with two lines of config and a new `staticClient` entry.

Anytime an identity provider gives you authentication but not the authorization surface your application actually needs, insert a thin layer between the two. Google does authentication beautifully. It's not the right place to do authorization for your specific application's policy. Dex sits in that gap, does the small amount of translation work, and lets each tier do what it does well.

Two surprises in Google's OAuth surface. Both papered over by teams daily. Both made to disappear by an architectural move that costs you one deployment.
