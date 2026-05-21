---
title: 'C-Style Thinking vs Go-Style Thinking'
excerpt: "You can identify a programmer's native language by the tools they build. Go and Perl natives build tools with sane defaults that work out of the box. C and C++ natives build tools that require you to understand the entire problem space before you can do anything at all."
publishDate: 'Apr 18 2026'
tags:
  - Philosophy
  - Engineering
  - Golang
isFeatured: true
---

## You Can Spot the Native Language

I have a theory I have yet to see disproved: you can identify a programmer's native language — the language they learned to *think* in, not just the one they happen to be writing today — by looking at the tools they build.

This is not about syntax preferences or brace placement. It is about what the tool expects from the person using it. What does the tool assume you already know? How much context do you need before it does anything useful? What happens when you run it with no arguments?

The answers to those questions tell you more about the author's mental model of software than any amount of code review.

## The Go/Perl School

Go programmers — and Perl programmers before them — build tools that work out of the box. Run it with no arguments and something useful happens. The defaults are carefully chosen so that the most common use case requires zero configuration. The tool does what you probably meant.

Larry Wall codified this as a design principle in Perl: *make easy things easy and hard things possible.* The easy thing should require no ceremony, no configuration, no reading of documentation. The complex thing should be achievable if you're willing to invest the effort, but the tool should never demand that effort from someone who doesn't need it.

Go inherited this philosophy, whether consciously or through cultural osmosis. `go build` compiles the current directory. `go test` runs the tests. `go fmt` formats the code. No project files, no build configurations, no flags to memorize. The tool does the obvious thing, and you can customize it if you need to.

`kubectl` is a good example despite its complexity. `kubectl get pods` does what you'd expect. `kubectl logs pod-name` does what you'd expect. The basic operations require zero configuration beyond having a kubeconfig, which itself has sensible defaults (`~/.kube/config`). You can go deep — custom output formats, JSON path queries, server-side apply with field managers — but the surface is approachable.

This is not accidental. It is a deliberate design choice that reflects how the author thinks about the relationship between a tool and its user. The tool serves the user. The user should not have to earn the right to basic functionality through study.

## The C/C++ School

C programmers build tools differently. Every option is exposed. Every parameter is required. Nothing is assumed. The tool is a precise instrument that does exactly what you tell it to do — no more, no less — and if you don't tell it enough, it does nothing, or worse, it does something unhelpful and tells you it's your fault.

This is not laziness. It is a different philosophy: the tool should not presume to know what the user wants. The user is an expert. The user will specify exactly what they need. Any assumption the tool makes is a restriction on the expert user's freedom.

The result is tools that are extraordinarily powerful and extraordinarily hostile to anyone who isn't already an expert. GNU `find` is the canonical example. It can do nearly anything. It can also do nearly nothing if you don't already know the specific incantation you need. `find . -name "*.log" -mtime +30 -exec rm {} \;` is a perfectly reasonable thing to want, but you need to know `-name`, `-mtime`, `-exec`, the `{}` substitution syntax, and the `\;` terminator before you can express it. There are no sane defaults. There is no "just do the obvious thing" mode.

Compare that to a Go-native approach to the same problem. You'd have a tool where `cleanup --older-than 30d *.log` does the obvious thing, and if you need the full power of find's predicate system, there are flags for that.

OpenSSL is another masterclass in C-style thinking. It is arguably the most important cryptography tool in the world. It can do everything. Using it for anything requires consulting the documentation for the specific subcommand, the specific flags, the specific order of arguments, the specific format of certificates, and the specific incantation for whatever operation you're performing. Generating a self-signed certificate — one of the most common operations — requires a multi-flag command that nobody memorizes:

```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -nodes
```

Every one of those flags is necessary. Omit any one and you get either an error or something you didn't want. There are no defaults for the common case. The tool treats "generate a self-signed cert for local development" and "generate a production CA with specific key parameters" as equally likely use cases deserving equal ceremony.

## The Deeper Problem

The C-style approach is not wrong in the abstract. Exposing all options gives expert users full control. Not making assumptions prevents the tool from doing something the user didn't intend. These are legitimate engineering values.

The problem is that they optimize for the wrong user. Most users of most tools are not experts in the tool itself. They are experts in their own domain — they are developers who need to deploy something, operators who need to debug something, data engineers who need to move something. The tool is not their destination. It is an obstacle between them and their actual goal.

When a tool demands expertise in itself before it can be used for its intended purpose, it has confused its own complexity with the complexity of the problem it solves. The problem of "I need a self-signed cert for local development" is simple. The problem of "I need to operate OpenSSL" is not. The tool has substituted the second problem for the first.

This is the same fundamental idea as ["Can" vs "Does"](/blog/can-vs-does/) — unnecessary complexity creates unnecessary failure modes. A tool that requires twelve flags to do the common thing is a tool where someone will get flag seven wrong at 2 AM. A tool that requires zero flags for the common thing and twelve flags for the exotic thing concentrates the complexity where the expertise is.

It is also the same idea as [Puppets and Octopi](/blog/puppets-and-octopi/) — the difference between systems that push complexity onto the user and systems that absorb complexity on the user's behalf. An orchestration system that requires you to specify every step is a system that has delegated its job to you. A convergence system that figures out the steps itself has done its job.

## Defaults Are Design Decisions

Choosing good defaults is harder than exposing all options. To choose a default, you must understand your users well enough to predict what most of them will want most of the time. You must accept that the default will be wrong for some users, and design an escape hatch that doesn't punish the common case. You must resist the urge to make the user decide things that don't matter to them.

This is engineering work. It requires understanding the problem domain, not just the solution space. It requires empathy for the person on the other end of the interface — the person who is not you, who does not know what you know, who has a different goal than you had when you built the tool.

C-style thinking skips this work. Exposing all options is easy. Choosing no defaults is easy. Documenting a hundred flags is tedious but straightforward. The hard work — the design work — is deciding which ten of those hundred flags matter for ninety percent of users and setting the other ninety to sensible values.

Go-style thinking does this work. `go build` assumes you want to build the package in the current directory. `go test` assumes you want to test the package in the current directory. These are not limitations. They are design decisions made by people who understood that in the overwhelming majority of cases, the current directory is the right answer, and forcing the user to specify it explicitly is wasted effort that adds no value.

## The Principle of Least Astonishment

The underlying principle is old. It predates Go, predates Perl, predates most of the tools we use today. The Principle of Least Astonishment says that a system should behave in whatever way will astonish its users the least.

For a tool, this means:

- **Default usage should be the most common use case.** If most people who run your tool want behavior X, then running your tool with no arguments should produce behavior X.
- **Flags and options are for the uncommon cases.** The person who needs behavior Y can specify it. The person who needs behavior X should not have to specify it.
- **Error messages should assume the user made a reasonable mistake.** "Missing required flag --output-format" is C-style thinking. "Writing output as JSON (use --format to change)" is Go-style thinking. One demands expertise. The other provides it.

The challenge is that the people building tools are, by definition, experts in the tool. The default behavior is obvious to them because they built it. The flags are intuitive to them because they named them. The documentation makes sense to them because they wrote it. The expert's curse is assuming that what is obvious to you is obvious to everyone.

## Why This Matters for Infrastructure

Infrastructure tools are force multipliers. A well-designed tool makes an entire team more effective. A poorly-designed tool makes an entire team dependent on the one person who understands it.

If your deployment tool requires understanding twelve configuration options before it can deploy the most common workload, you haven't built a deployment tool. You've built a deployment obstacle. One person on the team will become the expert, and everyone else will wait for that person to be available. The tool has created a bottleneck where none needed to exist.

If your monitoring system requires reading a manual before you can create a dashboard for the most common metrics, you haven't made observability accessible. You've made it gatekept. The people who most need to see what's happening — the developers who wrote the code — are the people least likely to invest the time to learn your monitoring system's particular dialect.

The infrastructure tools that succeed at scale are the ones that make the common case trivial. Prometheus succeeded not because it had the most features, but because `scrape_configs` with a list of targets was enough to get started. Grafana succeeded not because it had the best visualization engine, but because you could point it at a data source and have a working dashboard in minutes. Kubernetes succeeded not because it was simple — it is emphatically not simple — but because `kubectl apply -f deployment.yaml` does something useful with a twenty-line YAML file.

The tools that fail at scale are the ones that treat every user as an expert. They are technically superior, infinitely configurable, and practically unused — because the activation energy to do anything with them exceeds the patience of the people who need them.

## The Test

Next time you pick up a tool, run it with no arguments. What happens?

If it does something useful, or at least tells you clearly what it needs, someone thought about you when they built it. They predicted what you probably wanted and tried to give it to you. They chose defaults that serve the common case. They did the design work.

If it dumps a wall of flags, or prints a generic usage message that tells you nothing about what the flags mean or which ones you actually need, someone built it for themselves. They exposed the solution space and left you to navigate it. They skipped the design work.

Both tools might solve your problem. But one of them respects your time, and the other one doesn't. Over a career, across a team, across an organization, that difference compounds.

Build tools for the people who use them, not the people who build them. Make the easy thing easy. Make the complex thing possible. And choose your defaults like someone's sanity depends on them — because it does.
