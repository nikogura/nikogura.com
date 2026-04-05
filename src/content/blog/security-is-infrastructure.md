---
title: 'Security Is Infrastructure'
excerpt: Security and infrastructure are not two disciplines that happen to overlap. They are one discipline that companies have artificially separated because org charts demand clean boxes and job postings demand clean titles.
publishDate: 'Mar 06 2026'
tags:
  - Security
  - Infrastructure
isFeatured: true
---

## You Can't Lock a Door in a Wall That Isn't There

I've blown interviews over this. More than once. The conversation is going well, we're deep into architecture, I'm drawing on a decade of building platforms and securing them, and then the question comes:

"So, do you want to be in security, or in infrastructure?"

As if those are different things.

I understand why people ask it. Org charts have boxes. Boxes have labels. You're either on the infrastructure team or the security team. You write Terraform or you write detection rules. You manage the network or you audit it. Clean lines. Tidy hiring pipelines. Recruiters who can check a box.

The problem is, the systems don't care about your org chart. An attacker doesn't check which team owns the misconfigured load balancer before exploiting it. A compliance auditor doesn't give you credit for having a great WAF if the thing behind it is running unpatched kernels on nodes with public IPs. The wall doesn't care that the door team and the wall team report to different VPs.

It doesn't matter how good your lock is if there's a hole in the wall.

## The False Dichotomy

Here's what I mean. Security without infrastructure knowledge is theater. You can write the most elegant Falco rules in the world, but if you don't understand how Kubernetes networking works, you won't know what "anomalous traffic" looks like because you don't know what normal traffic looks like. You can deploy a WAF, but if you don't understand how the application behind it handles requests, you'll either block legitimate traffic or let attacks through --- and you won't know which until someone complains or someone breaches you.

Infrastructure without security knowledge is negligence. You can build the most beautifully automated, perfectly GitOps'd, fully observable platform in the world, and if you don't think about blast radius, network segmentation, secret management, and least-privilege access, you've built a very efficient machine for getting owned. You've paved a highway with no guardrails and handed out the keys.

These aren't complementary disciplines that occasionally shake hands across a conference table. They're the same discipline viewed from different angles. Every infrastructure decision is a security decision. Every security control is an infrastructure component. You cannot do one well without understanding the other.

## Five Domains, One Practice

I think about this in terms of five domains. Not "five domains of security" or "five domains of infrastructure." Five domains of building and running systems that work and don't get you breached.

### 1. Architecture and Design

This is where most security problems are born and most infrastructure problems become intractable. By the time you're writing code or deploying resources, the big decisions are already made. Network topology. Trust boundaries. Data flow. Identity model. Blast radius.

A system designed with a flat network where every service can talk to every other service is an infrastructure decision that is also a catastrophic security decision. If one service gets compromised, the attacker can reach everything. No amount of runtime detection fixes this. The architecture is the vulnerability.

A system designed with proper segmentation, least-privilege service accounts, and well-defined trust boundaries is simultaneously better infrastructure *and* better security. It's easier to reason about. It's easier to monitor. It's easier to debug. And it's harder to exploit. These aren't separate benefits. They're the same benefit expressed in different vocabularies.

When I design a platform, I'm not thinking "infrastructure first, security later." There is no later. The network topology *is* the security posture. The identity model *is* the access control. The data flow *is* the attack surface. If you're bolting security onto an architecture that wasn't designed with it in mind, you're putting a padlock on a screen door.

### 2. Implementation

Implementation is where the rubber meets the road, and where the infrastructure/security split causes the most day-to-day damage.

I've watched infrastructure teams deploy Kubernetes clusters with default RBAC --- every service account gets more permissions than it needs, because "we'll tighten it up later." Later never comes. I've watched security teams mandate mTLS between all services without understanding the operational cost of certificate rotation, or what happens when the cert-manager pod crashes at 3 AM and suddenly nothing can talk to anything.

Good implementation requires understanding both sides simultaneously. When I write a Terraform module for a VPC, I'm thinking about routing *and* about what traffic should never be routable. When I configure an ingress controller, I'm thinking about request handling *and* about what headers to strip, what rate limits to set, what request patterns indicate an attack versus a legitimate spike.

The person implementing the infrastructure *is* implementing the security controls. If they don't know that, you have a problem. And if you have a separate security team that reviews after the fact, you have a slower version of the same problem, because the architecture is already set and the reviews become a negotiation about how many band-aids to apply.

### 3. Observability

This is where the false dichotomy gets truly absurd, because security monitoring and infrastructure monitoring are not just related --- security monitoring is often a *superset* of infrastructure monitoring.

Think about it. What does a performance anomaly look like? CPU spikes. Memory pressure. Unusual network traffic patterns. Elevated error rates. Increased latency. Disk I/O through the roof.

Now. What does the early stage of a breach look like?

CPU spikes --- from a cryptominer, or from an attacker running recon tools. Memory pressure --- from a process that shouldn't be there. Unusual network traffic --- data exfiltration, lateral movement, C2 callbacks. Elevated error rates --- from an attacker probing for vulnerabilities. Increased latency --- from a man-in-the-middle, or from traffic being redirected. Disk I/O through the roof --- from someone dumping your database.

The first sign of a security incident is almost always a performance anomaly. The metrics are the same metrics. The logs are the same logs. The difference is what you're looking for and what you do when you find it.

I've caught more security issues from Prometheus alerts than from dedicated security tooling. Not because the security tools are bad, but because the infrastructure metrics are *always on*, they cover *everything*, and they don't have the blind spots that come from security tools that only watch what they were configured to watch.

A spike in 403s from your WAF is a security signal. It's also an infrastructure signal --- is the WAF misconfigured? Is a legitimate client sending malformed requests? Is a deploy rolling out a breaking change? You can't answer any of these questions without understanding both domains.

If your infrastructure team monitors performance and your security team monitors threats, and they use different tools, different dashboards, different alerting pipelines --- congratulations, you've built two half-blind systems instead of one that can actually see. The infrastructure team sees the symptom and doesn't recognize the attack. The security team sees the alert and doesn't understand the infrastructure context to know if it's real.

### 4. Response, Recovery, and Remediation

When something goes wrong --- and it will --- the response requires both skill sets in the same room, ideally in the same person.

An incident where a node is compromised requires infrastructure knowledge to isolate it (cordon the node, drain the workloads, rotate the credentials, check the blast radius) *and* security knowledge to investigate it (what got accessed, how did they get in, what did they do, are they still here, where else might they be). If your incident response involves the infrastructure team doing the containment and the security team doing the investigation, and they're working from different mental models of how the system works, you're slower than you need to be at the worst possible time.

Recovery is the same story. Rebuilding from a security incident isn't conceptually different from rebuilding from an infrastructure failure. If you have good GitOps practices, immutable infrastructure, and well-tested disaster recovery, you can recover from a breach the same way you recover from a failed region: rebuild from known good state. If you don't have those things, recovering from a breach is a nightmare for the same reasons recovering from a disk failure is a nightmare --- you don't know what you had, you don't know what changed, and you're reconstructing from memory and prayer.

Good infrastructure *is* good incident response. Immutable infrastructure means you can nuke and rebuild with confidence. GitOps means you have an audit trail. Observability means you can reconstruct what happened. These aren't security features bolted on top. They're infrastructure features that happen to be exactly what you need when everything goes sideways.

### 5. Maintenance

The long tail. The part nobody wants to talk about at the architecture whiteboard, but where most real-world breaches actually happen.

Unpatched systems. Stale credentials. Orphaned resources. Expired certificates. Drifted configurations. Accumulated technical debt that nobody owns because the infrastructure team thinks it's a security problem and the security team thinks it's an infrastructure problem.

Maintenance is where the organizational split between infrastructure and security is most damaging. Neither team owns the gap. The infrastructure team keeps the systems running. The security team audits them periodically. But the slow accumulation of rot --- the service account that still has admin from that one emergency six months ago, the test namespace that's still running with a public endpoint, the Helm chart that hasn't been updated in a year and is three CVEs behind --- that rot lives in no-man's-land between the two teams.

I built the [rbac-expiry-operator](https://github.com/nikogura/rbac-expiry-operator) specifically because of this problem. Kubernetes doesn't natively support time-limited RBAC. So you grant someone `cluster-admin` during an incident, and then it persists forever because nobody remembers to revoke it, or the runbook says "clean up after incident" and nobody does. That's an infrastructure problem (RBAC configuration) and a security problem (excessive persistent privileges) and a maintenance problem (cleanup never happens). It's all three at once because it was always all one thing.

## The Hiring Problem

This false dichotomy doesn't just cause technical problems. It causes organizational dysfunction that starts at the job listing.

Job postings for "Security Engineer" want someone who can write detection rules, manage SIEM pipelines, and conduct threat modeling. Job postings for "Infrastructure Engineer" want someone who can write Terraform, manage Kubernetes, and build CI/CD pipelines. These are described as different roles requiring different skill sets.

But the person who can do threat modeling *and* write the Terraform that implements the mitigations is worth more than one of each. The person who understands Kubernetes networking well enough to both design the network policies *and* detect when something is violating them is not two half-people. They're one whole person who sees the system as it actually is.

I've sat in interviews where I'm talking about building a platform with proper segmentation, OIDC-based identity, time-limited RBAC, comprehensive observability, and GitOps-driven infrastructure, and the interviewer is trying to figure out which box to put me in. "That sounds like security." "That sounds like SRE." "That sounds like platform engineering." It's all of those things because it has to be. The system doesn't know it's supposed to be three different departments.

The worst version of this is when companies hire for one side and expect the other for free. They hire infrastructure engineers and expect them to intuitively make secure decisions without security training. Or they hire security engineers and expect them to implement controls in systems they don't understand. Then they're surprised when the infrastructure is insecure or the security controls break production.

## The Point

Security and infrastructure are not two disciplines that happen to overlap. They are one discipline that companies have artificially separated because org charts demand clean boxes and job postings demand clean titles.

Every infrastructure decision is a security decision. Every security control is an infrastructure component. The five domains --- architecture, implementation, observability, response, and maintenance --- require fluency in both, because they *are* both.

If your security team doesn't understand how the infrastructure works, they'll write policies that are either unimplementable or ignored. If your infrastructure team doesn't understand the security implications of what they're building, they'll build systems that are efficient, well-monitored, beautifully automated, and trivially exploitable.

You can have the best lock in the world. It doesn't matter if there's a hole in the wall. And the person who can tell you about the hole is the same person who built the wall --- if you let them think about locks too.
