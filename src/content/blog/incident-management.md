---
title: 'Incident Management'
excerpt: The role-based incident-response model Jesse Robbins brought from the fire service into web operations, written down from memory as I learned it. Incident Commander, Scribe, SMEs, severity, the CAN format, and the discipline that makes the framework actually work when the page goes off at 3 AM.
publishDate: 'May 20 2026'
tags:
  - Incident Management
  - Operations
  - Engineering
isFeatured: false
---

What follows is the incident-management model as I learned it from Jesse Robbins, written down from memory before I lose any more of it. Any omissions or confusions are mine.  I learned it at the feet of the master, but that doesn't mean I grokked everything he was laying down.

I have run a lot of incidents, I have made every mistake described below at least once, and I have watched this model — applied with discipline — turn 3 AM chaos into something that survives shift change and produces a usable postmortem. It is opinionated. It is rigid. The rigidity is the feature.

## Table of Contents
- [Where this comes from](#where-this-comes-from)
- [The roles](#the-roles)
- [Role combinations for small teams](#role-combinations-for-small-teams)
- [Declaring an incident](#declaring-an-incident)
- [The first ten minutes](#the-first-ten-minutes)
- [The principles behind the roles](#the-principles-behind-the-roles)
- [Status reports: the CAN format](#status-reports-the-can-format)
- [Common antipatterns](#common-antipatterns)
- [After the incident: blameless postmortems and action items](#after-the-incident-blameless-postmortems-and-action-items)
- [Adopting this](#adopting-this)
- [Further reading](#further-reading)

---

## Where this comes from

The framework described here did not start in software. It started in the US fire service, as the **[Incident Command System (ICS)](https://en.wikipedia.org/wiki/Incident_Command_System)** — developed in the 1970s after a series of catastrophic California wildfires in which the failure was not the fire itself but the *coordination between agencies* responding to it. Different departments arrived with different vocabularies, different chains of command, and no shared notion of who was in charge. People died because of organizational confusion, not because the fire was unfightable.

ICS was the response. It is a standardized, role-based command structure that scales from a single-engine response up to a multi-agency, multi-jurisdiction disaster. It is now codified federally as part of the **National Incident Management System (NIMS)**, taught through FEMA's ICS-100 / 200 / 300 / 400 course series, and used by every fire department, EMS service, and emergency management agency in the United States.

**[Jesse Robbins](https://jesserobbins.com/)** brought ICS into web operations during his time at Amazon, where his title was "Master of Disaster" and he was responsible for the availability of every property bearing the Amazon brand. Robbins is a volunteer firefighter and emergency manager — he deployed on the federal task force to Hurricane Katrina — and he distilled the operational discipline of the fire service into a model that the technology industry has been adopting ever since. He went on to co-found the **Velocity Conference** with Tim O'Reilly, where this model was popularized, and to found **Chef** (the configuration-management company). His framework is the upstream source of the incident response processes you now see at PagerDuty, Google SRE, Atlassian, and most mature operations organizations.

What follows is that model. It is opinionated. It is deliberately rigid. The rigidity is the feature. What's more, **it works**.

---

## The roles

The role list below is the web-ops adaptation. The full ICS structure includes additional sections (Planning, Logistics, Finance/Admin) that rarely map to technology incidents — those exist for multi-day, multi-agency physical-world responses.

### Incident Commander (IC)

The single accountable leader of the response. The IC owns the call, sets objectives, allocates resources, makes decisions, and decides when the incident is over.

**The IC does not fix the problem.** This is the most important and most-violated rule in the entire framework. The moment the IC starts typing into a terminal, opening a dashboard, or running a query, they have stopped being IC and no one is. The IC's job is *coordination*, not *execution*. They direct; they do not do.

The IC is also responsible for **declaring the incident**, for **calling severity**, and for **calling resolution**. These are not group decisions. They are IC decisions. The IC may consult, but the IC decides.

The IC role rotates by shift. A long incident has multiple ICs handing off to each other. The hand-off is formal: the outgoing IC briefs the incoming IC on state, open questions, and current objectives. Nothing about the response should depend on a specific human being remaining awake.

### Deputy Incident Commander

The IC's backup and shadow. The Deputy:

- Maintains awareness of the full incident state so they can take over if the IC drops (fatigue, schedule conflict, escalation to a larger incident, etc.).
- Tracks things the IC might be missing — open action items not yet closed, stakeholders not yet informed, decisions that need to be revisited.
- Manages hand-offs cleanly.

In smaller incidents, the Deputy role may be folded into the Scribe. In larger incidents it should be its own person.

### Scribe

Maintains the **authoritative timeline of record** for the incident. Everything else downstream — the postmortem, customer communications, regulatory reporting, legal review — flows from this artifact.

The Scribe records:

- What happened, in chronological order, with timestamps.
- Who did what, when.
- What was decided, by whom, and on what information.
- Action items requested and their disposition.
- Severity changes and their justification.

The Scribe does not interpret. The Scribe records. Interpretation happens later, in the postmortem, with the timeline as evidence.

The Scribe role is often given to a newer engineer as a way to expose them to incident response without putting them on the hook for decisions. This is a legitimate use of the role, but the Scribe must still be trained — bad timekeeping during an incident produces a useless postmortem.

### Subject Matter Expert (SME) / Operations Lead

The person actually working on the problem. The hands on the keyboard. There can be multiple SMEs in a single incident, one per affected domain (database, network, application, third-party, etc.).

The SME's responsibilities:

- Diagnose and remediate within their area of expertise.
- Report findings *to the IC*, not to the channel at large. The IC is the routing point.
- Do not freelance. Do not start independent investigation tracks without telling the IC. If the IC is unaware of what you're doing, it isn't happening.
- Surface what you need from the IC: more hands, access, decisions, escalations.

SMEs should not be the IC simultaneously. The cognitive load of fixing the problem is incompatible with the cognitive load of coordinating the response.

### Communications Lead (Customer Liaison)

External-facing communications. Owns the status page, customer email notifications, social media posts, and any other channel by which customers and the public learn what is happening.

The Communications Lead:

- Translates engineering reality into customer-readable language.
- Posts updates on a defined cadence (typically every 30 minutes for an active incident, set by the IC), even when there is no progress — "we are still investigating" is itself a status.
- Coordinates with Legal, Marketing, and Support on wording for high-severity incidents.
- Does not invent. Every external statement is grounded in what the IC has confirmed.

This role exists so that the IC and the SMEs do not have to context-switch between fixing the problem and explaining the problem.

### Internal Liaison

Internal-facing communications. Updates executives, posts in internal channels, pages additional responders when the IC asks, and mobilizes adjacent teams.

Like the Comms Lead, the Internal Liaison posts on a defined cadence — typically every hour, set by the IC, more often during active escalation. The audience is different (executives, support, adjacent engineering teams rather than customers) but the discipline is the same: regular heartbeat updates so the audience does not need to ping the response team for status.

The Internal Liaison's most important function: **insulating the IC from "what's going on?" pings.** When a VP DMs the IC during a Sev-1, the IC should not be answering. The Internal Liaison handles it, refers the VP to the appropriate channel or status update, and lets the IC keep coordinating.

### A note on the three "writing" roles

Three of the roles above involve writing things down during an incident, and the distinction between them is deliberate and important. They are not the same person and they are not the same artifact.

- The **Scribe** writes the **internal timeline of record**. Not customer-facing. This is the durable evidentiary artifact that feeds the postmortem, legal review, and any regulatory or contractual reporting downstream. It is comprehensive and factual: everything that happened, when, who did it, what was decided.
- The **Communications Lead** writes the **external messaging**. Customer-facing. Status page, customer emails, social media. Translated into customer-readable language, posted on a cadence, grounded in what the IC has confirmed.
- The **Internal Liaison** writes the **internal stakeholder updates**. Employee-facing but not response-team-facing. Executive briefings, internal Slack channel updates, paging adjacent teams. Different audience, different format, different cadence than either of the other two.

Same act in the abstract — write things down — but three different audiences, three different artifacts, three different people. Collapsing any two of them into one role is a common antipattern: the Scribe ends up drafting customer messaging instead of recording the timeline, or the Comms Lead gets pulled into briefing an executive and stops posting to the status page. Keep them separate.

---

## Role combinations for small teams

The six-role model is what you grow into. A team of five engineers cannot field six distinct responders on a Tuesday afternoon, and a Sev-3 doesn't require it. This section is placed here because "how do we do this with our small team?" is the first question every team asks after seeing the roles.

The severity terms used below (Sev-1 through Sev-4) are formally defined in the next section. For now, read them as a rough scale: Sev-1 is catastrophic, Sev-4 is minor.

### What can legitimately be combined

- **Deputy + Scribe.** Common and safe. The Deputy is shadowing the IC for hand-off purposes; the Scribe is documenting the same flow of events. One person can do both at Sev-2 and below. In long Sev-1s, separate them — fatigue compounds and the timeline suffers first. Never combine at Sev-0.
- **Comms Lead + Internal Liaison.** Common in smaller orgs. Same writing-things-down skill set, both work off what the IC has confirmed. The risk is audience confusion — make sure the combined person is explicitly tracking which message goes to which audience on which cadence. If both audiences need updates simultaneously and the combined person can't keep up, split the role.
- **IC + Deputy.** Acceptable for Sev-3 and Sev-4 only. The IC carries Deputy responsibility themselves; if they need backup, they declare one then. Not acceptable for Sev-0, Sev-1, or Sev-2 — fatigue and single-point-of-failure risk are too high.
- **Internal Liaison + Scribe.** Tolerable for short, low-severity incidents. Same person updates internal channels and keeps the timeline. The risk is that internal-update writing crowds out timeline-keeping. If the timeline starts to thin out, separate immediately.

### What must never be combined

- **IC + SME.** This is the cardinal rule of the entire framework. The IC who is also debugging is no longer IC. Even in a team of two, the IC stays the IC and the SME stays the SME. If there is genuinely only one person available, that person is the SME and someone else gets paged in to be IC. There is no shortcut around this rule, and violating it is the most common cause of failed incident response.
- **IC + Scribe.** The IC writing their own timeline is the same problem at lower intensity — they will miss things because their cognitive load is on coordination, not record-keeping. Pulling a non-responder in (a PM, a manager, someone from an adjacent team) to be Scribe is better than the IC trying to do both.
- **Comms Lead + SME.** The person fixing the database does not write the customer-facing status update. The SME's job is execution; the Comms Lead's job is translation. Combining them produces either bad messaging (because the SME is busy) or bad fixes (because they're context-switching to write).
- **IC + Comms Lead.** The IC is not the public voice of the incident. The IC's audience is the response team; the Comms Lead's audience is the customer base. Combining them means either external communication stops while the IC coordinates internally, or coordination stops while the IC writes externally. Both failure modes hurt.

### Minimum staffing by severity

- **Sev-4:** IC + SME. The IC can carry Deputy/Scribe responsibilities. Comms optional if no customer impact. **Total: 2 people.**
- **Sev-3:** IC + SME + Scribe (or IC + SME with Scribe role combined into one of them). Comms Lead if customer-visible. **Total: 2–3 people.**
- **Sev-2:** IC + Deputy/Scribe (combined) + SME(s) + Comms Lead/Internal Liaison (combined). **Total: 4–5 people.**
- **Sev-1:** All six roles, distinct people. If you cannot field six, you have a staffing problem that pre-dates the incident, and the IC's first action is to page additional responders from adjacent teams or escalate to management to mobilize them. **Total: 6 people.**
- **Sev-0:** All six roles distinct *plus* a designated executive sponsor, Legal counsel on call, and PR/communications principal engaged. No role combinations of any kind. Shift rotation prepared from the start — Sev-0s last days, not hours. **Total: 6 engineering + 3+ business stakeholders.** If you cannot field this, the IC's first call is to the CEO to mobilize what is missing.

### The realistic adoption path

A team starting from zero rarely lands all six roles on day one. Trying to is the surest way to get the framework rejected as "too heavy." Roll out in stages:

1. **Stage 1 (week 1):** IC + SME, declared and explicit. Even badly-done IC + SME is better than nothing. The team learns the cardinal rule first: the IC does not fix.
2. **Stage 2 (month 1):** Add Scribe. The first time the team writes a postmortem from chat scrollback because there was no Scribe, they will understand why this role exists. That experience is more persuasive than any written argument.
3. **Stage 3 (months 2–3):** Add Comms Lead for customer-visible incidents. The team will know it is time when the IC has been pulled away from coordination one too many times to write a status page update.
4. **Stage 4 (months 3–6):** Add Internal Liaison and Deputy as separate people for higher severity. By this point the team has incident-response muscle memory and can absorb the additional structure without resentment.

Each stage builds on the previous one. Skipping ahead — declaring on day one that the team will adopt all six roles — produces a framework that exists on paper but isn't followed in practice, which is worse than no framework at all.

---

## Declaring an incident

The first failure of most teams new to incident management is not the response — it's the declaration. People work a problem in their team channel for two hours without ever acknowledging that an incident is in progress. No IC, no Scribe, no cadenced updates, no externally-visible response. By the time anyone formally declares, the response has already failed: the timeline is incomplete, customers have been silent for hours, executives find out from outside the company.

Declaration is cheap. Not declaring is expensive. The default is to declare and downgrade if wrong, not to wait and upgrade when forced.

### Severity scale

The IC sets severity at declaration and updates it as scope clarifies. Use the highest severity supported by current evidence; downgrade as facts emerge, not as hope emerges. A team-specific severity rubric is mandatory — without one, the IC has no anchor and severity calls become political.

A starting template, to be customized to your business:

| Sev | Trigger | Response posture |
|---|---|---|
| **Sev-0** | Company-existential event. Active data breach, ransomware, or exfiltration in progress. Total platform outage with no workaround and no ETA. Imminent regulatory disclosure clock running. Active safety event affecting customers or employees. | Full company mobilization. CEO, Legal, and PR engaged from minute one. Every external statement legal-reviewed. Regulatory and disclosure clocks tracked explicitly by the IC. Engineering is one function in a multi-function response, not the lead. |
| **Sev-1** | Major customer-visible outage. Significant revenue impact. Multiple regions or business units affected. Material but not company-existential. | Full role assignment, all six roles distinct people. Executive notification immediately. Round-the-clock response until resolved. |
| **Sev-2** | Significant customer-visible degradation affecting a meaningful share of users, OR a critical internal system down. | Full role assignment, some combinations acceptable. Executive notification within an hour. Business-hours-plus response. |
| **Sev-3** | Limited customer impact (specific feature, geography, or customer segment) OR significant internal degradation not blocking customer-facing systems. | IC + SME minimum, plus Scribe. Executive notification at next regular cadence. Business-hours response. |
| **Sev-4** | Minor degradation, mostly internal, low or no customer impact. | IC + SME. Async response. Documented and tracked, but no urgent paging. |

The severity table is the most context-dependent artifact in the framework. What counts as Sev-1 at a payments company is different from what counts as Sev-1 at an internal tooling company. Set yours explicitly, document it, post it where on-call can see it without searching.

**On Sev-0 specifically.** The defining feature of Sev-0 is not "really bad" — Sev-1 already covers really bad. It is that the *response posture is qualitatively different*: CEO, Legal, and PR are engaged from minute one; external statements are legal-reviewed before they go out; regulatory disclosure clocks (GDPR breach notification, SEC material-event disclosure, contractual customer notification windows) are running and tracked. Engineering is no longer driving the response — it is one team in a multi-function company-wide response, with the IC coordinating against a designated executive sponsor. Sev-0 exists as its own tier because the playbook is fundamentally different from any other severity, not because the impact is fractionally larger. If your org doesn't have customer data, regulatory exposure, or safety obligations that would trigger this posture, you may not need Sev-0 — but most production businesses do.

### When to declare

Declare an incident when any of the following is true:

- Customer-visible service is degraded or unavailable beyond your error budget.
- Internal critical systems are degraded in a way that blocks engineering, support, or other business functions.
- A security event is suspected — breach, unauthorized access, exfiltration, malware.
- Data loss, corruption, or integrity is suspected.
- Regulatory or contractual obligations may be at risk.
- You don't yet know whether any of the above is true. Investigating *is* a reason to declare.

The first responder declares. Anyone can declare. Declaring is not an admission of fault and does not require IC approval — you declare *because* you need an IC.

### When *not* to declare

Bug reports that don't meet the criteria above are bugs, not incidents. Performance reports without measurable impact are tickets, not incidents. A single customer complaint about an isolated issue is a support case, not an incident. The discipline of *not* declaring for non-incidents is what keeps the team responsive when a real one hits — incident fatigue is real, and declaring too liberally trains people to ignore the page.

---

## The first ten minutes

Where does the incident actually happen? This is the most boring part of the discipline and the one that determines whether the framework survives contact with reality. A team without explicit operational mechanics will try to run a Sev-1 in their normal `#engineering` channel with PMs asking unrelated questions and executives interrupting — and the response will fail accordingly.

### A runbook for the first ten minutes

1. **Declare.** First responder says "I am declaring an incident: \<one-line description\>" in whatever channel surfaced the problem.
2. **Create the incident channel.** Naming convention: `#inc-YYYY-MM-DD-short-description`. Examples: `#inc-2026-05-20-db-degraded`, `#inc-2026-05-20-auth-outage`. Dated and descriptive names are searchable and unambiguous later.
3. **Assign IC.** The first responder either declares themselves IC ("I'm IC") or explicitly designates one ("@person, can you take IC?"). If no one volunteers, the first responder is IC by default.
4. **Page roles.** IC pages SME(s) for the affected domain. For Sev-0/Sev-1/Sev-2, IC pages Scribe and Comms Lead immediately. For Sev-0, IC additionally pages the executive sponsor, Legal, and PR. For Sev-3/Sev-4, IC pages roles as needed.
5. **Set initial severity.** IC declares severity in the incident channel: "Calling this a Sev-2 pending more info."
6. **Start the timeline.** Scribe (or IC, if no Scribe yet) posts the first timeline entry: "T+0: Incident declared. Initial reports: \<summary\>."
7. **Open a bridge if needed.** For Sev-0/Sev-1/Sev-2, open a voice/video bridge in parallel with the channel. The channel is the durable record; the bridge is the high-bandwidth coordination. Both are needed. Sev-0 typically requires a *second* bridge for the cross-functional response (Legal, PR, Exec) so engineering coordination is not interrupted by stakeholder briefings.
8. **First CAN.** Within 10 minutes of declaration, IC posts the first CAN report to the channel: current Conditions, Actions, Needs.
9. **First external update.** Comms Lead posts the initial customer-facing status if applicable: "We are investigating reports of \<symptom\>. Next update at \<time\>."
10. **First internal update.** Internal Liaison posts initial executive and stakeholder update.

If those ten steps happen in the first ten minutes, the response is on rails. If they don't, the response is improvising under pressure — which is exactly the failure mode the framework exists to prevent.

### Channels, bridges, pages, and status pages

- **Incident channel** is the durable record. Everything significant goes here. The Scribe's timeline is posted here. CAN reports are posted here. The channel is *archived* (not deleted) at incident closure and remains searchable.
- **Voice or video bridge** is for high-bandwidth coordination during active response. It is *not* a substitute for the channel — anything decided on the bridge gets posted to the channel by the Scribe. Bridges leave no trace; channels do.
- **Status page** is the external record. Posted by Comms Lead, on cadence. Status page entries are public and lasting; treat them with the same care as any other customer-facing communication.
- **Paging system** is how roles get filled. Every role above must be pageable in your paging system, with documented escalation paths and rotation schedules.

### Pre-requisites a team needs before any of this works

The framework assumes a baseline of scaffolding exists. A team starting from zero should put these in place in parallel with adopting the role model — without them, the framework cannot function:

- **On-call rotation.** Someone is responsible at all times. There is a documented schedule. There is a paging mechanism that reaches them. Without this, "the first responder declares" has no first responder.
- **Status page.** A customer-facing channel for incident updates, separate from your normal product surfaces. Free or low-cost options exist (Statuspage, Instatus, self-hosted alternatives); the specific tool matters less than having one.
- **Paging system.** PagerDuty, Opsgenie, VictorOps, anything that supports role-based paging (page the IC on call, page the database SME on call, etc.) and escalation policies.
- **Runbooks.** Even rudimentary ones. The SME's job during an incident is much harder if every diagnostic has to be reinvented under pressure. A team that has never written a runbook should start with the most-frequently-triggered alerts and work downward.
- **Documented severity rubric.** See above. Without this, the IC has no anchor for declaring severity, and severity becomes a political call.

You do not need expensive tooling. You do need *some* tooling. The minimum viable stack — Slack workspace, a paging tool, a status page service — costs a few hundred dollars a month for a small team. The cost of not having it is measured in incidents that go undeclared, customers who learn about outages from Twitter, and postmortems that nobody can write because the timeline is gone.

---

## The principles behind the roles

### One IC, always

There is exactly one Incident Commander at any moment. Not two. Not "co-ICs." If the IC needs to hand off, the hand-off is explicit and announced: "Acknowledging hand-off. I am now IC. Confirm." The previous IC confirms, and from that moment forward the new IC is in charge.

This sounds bureaucratic. It exists because in real incidents, fatigue, time zones, and escalation paths mean ICs do change hands, and ambiguity about who is in charge is a known cause of bad outcomes. The fire service learned this lesson at terrible cost. The discipline transfers directly.

### Command and execution are separate

The IC commands. The SMEs execute. The IC does not execute and the SMEs do not command. This separation is what allows the response to scale beyond a single very-smart person heroically holding everything in their head.

When command and execution collapse into one person, two failure modes become inevitable:

1. The "IC" gets absorbed in debugging and stops coordinating, at which point the other responders lose situational awareness and start working at cross-purposes.
2. The "IC" keeps coordinating but cannot meaningfully command because they don't have the cycles to think about strategy — they become a status-meeting facilitator instead of a decision-maker.

Neither of these is what you want during a real outage.

### The Scribe's timeline is the source of truth

If it is not in the Scribe's timeline, it did not happen. This is a forcing function. It pushes responders to surface their actions through the chain — "telling the Scribe" is functionally the same as "telling the IC" — and it produces an artifact that survives the incident.

Postmortems written from chat-log scrollback are bad postmortems. Postmortems written from a Scribe's timeline are good postmortems. The difference is the quality of the next incident's prevention.

### Communicate on a cadence, not on demand

Cadenced posting is a discipline that applies to every role whose job is keeping an audience informed — not just the Comms Lead. The IC sets the cadence for each audience, and the cadences are different:

- **Comms Lead** → external customers — typically every 30 minutes.
- **Internal Liaison** → executives, support, adjacent teams — typically every hour, sometimes faster during active escalation.
- **IC** → the response channel itself, "top of the hour" briefing to the responders so SMEs and Scribe share a current picture.

None of these posters stop posting when "nothing has changed." A heartbeat of "still investigating, no new information, next update in 30 minutes" is itself a piece of information: it tells the audience that the response is active and they do not need to ping the response team for status. The Scribe is the only documentation role that does *not* operate on a cadence — they write continuously as events occur, because their job is the timeline of record, not audience messaging.

### The IC owns severity and resolution

Severity is not a vote. Resolution is not a vote. The IC declares them based on impact and information. The IC may be wrong; the IC is still the one who declares. Disagreement gets surfaced *to the IC*, who decides. This is faster than consensus and almost always at least as accurate.

---

## Status reports: the CAN format

Every cadenced update and every status report — from an SME to the IC, from the outgoing IC to the incoming IC at hand-off, from the IC to the response channel at the top of the hour — should follow the **CAN** format. CAN is another direct lift from the fire service: it stands for **Conditions, Actions, Needs**, and it forces a complete, concise status into three slots.

### The format

**Conditions** — what is the situation right now, in observed facts? Not what you think is happening. Not what might be happening. What is measurably true at this moment. Metrics, error rates, customer reports, affected systems, scope of impact.

**Actions** — what are you currently doing about it? Not what you plan to do, not what you considered. What is in flight right now. What has already been completed.

**Needs** — what do you need to keep going? Resources, decisions, access, information, additional responders, IC approval for a specific action. This is the slot responders most often skip, and it is the slot that most often determines whether the response moves forward or stalls.

### Why it works

Each slot exists because it addresses a known failure mode in status reporting:

- **Conditions** forces the reporter to ground the report in observation rather than interpretation. "I think the database is overloaded" becomes "CPU 95%, replication lag 4 minutes, p99 latency 8 seconds against a 200ms baseline."
- **Actions** forces the reporter to distinguish between work in progress and work being contemplated. The IC can only coordinate around things that are actually happening.
- **Needs** forces the reporter to surface blockers explicitly. Responders chronically assume the IC already knows what they need; the IC chronically does not. Putting Needs in a dedicated slot makes the implicit explicit.

The three slots together produce a status report that the IC can act on immediately — they know the situation, they know what's being done, and they know what decisions they're being asked to make.

### Example

> **C:** Database primary CPU at 95% sustained, replication lag at 4 minutes and growing, p99 latency 8 seconds against 200ms baseline. Customer-facing impact confirmed in EU region; US still nominal. Started 14:32 UTC, correlates with deploy at 14:30.
>
> **A:** Provisioning a read replica, ETA 6 minutes. Pulling query log for the window around the deploy to identify the offender. Paged the application team for a deploy-side rollback option.
>
> **N:** Need IC approval to fail over to the secondary if the read replica does not reduce primary load. Need someone from the application team to confirm whether the 14:30 deploy added new query patterns — Jeff is on the page but hasn't responded yet.

This takes about ninety seconds to deliver verbally. The IC now has everything they need: situational awareness, knowledge of work in flight, and a clear list of decisions they own.

### When to use it

CAN reports are the default format for:

- **SME-to-IC status updates** on the IC's cadence (typically every 15–30 minutes during active response, or whenever a material change occurs).
- **IC-to-channel briefings** at the top of the hour — the IC consolidates the SME CANs into a unified incident CAN for the response team.
- **IC-to-IC hand-offs** at shift change — the outgoing IC briefs the incoming IC in CAN format, and the incoming IC confirms back in CAN format ("Here's the C, A, and N as I understand it — correct?").
- **Escalation briefings** to executives or external partners — same format, language adjusted for audience.

### Common CAN failure modes

- **All C, no A or N.** Long situation report, no statement of what's being done or what's needed. The IC cannot act on this. Push back: "What are you doing about it? What do you need?"
- **All A, no C.** A list of activity with no grounding in the current situation. The IC cannot evaluate whether the activity is appropriate. Push back: "Tell me what you're seeing first."
- **No N.** Responder assumes the IC knows what they need. Almost always wrong. Push back: "What do you need to keep going?" If the honest answer is "nothing," the responder says so — empty Needs is fine, *implicit* Needs is not.
- **Speculation in Conditions.** "I think it's a memory leak" belongs in Actions ("I am investigating a possible memory leak") or Needs ("I need eyes on the memory profile"). Conditions is for facts only.
- **Promises in Actions.** "I'm going to fail over the database" belongs in Needs ("I need approval to fail over") until the IC has approved it. Actions is for things actually in flight.

The discipline is small. The payoff is that every status update is immediately actionable, every hand-off is complete, and the Scribe's timeline captures structured information rather than ad-hoc chatter.

---

## Common antipatterns

These are the failure modes you'll see most often in organizations that haven't adopted ICS — and, frankly, in many that have.

- **The IC is also the best debugger, so the IC is debugging.** Already covered. This is the #1 violation. The fix is cultural: senior engineers must be willing to step *back* from the keyboard during an incident and let less-senior people drive the actual fix, while they coordinate. This is harder than it sounds and is the single biggest skill that distinguishes mature incident response from immature.

- **No declared IC.** A bunch of engineers in a channel typing furiously, with no one explicitly in charge. Symptoms: duplicated investigation, missed escalations, no timeline, no external communication, a postmortem written from chat scrollback. Fix: the first responder declares themselves IC ("I'm IC for this incident") and immediately starts assigning roles. Anyone can be IC; the role just has to exist.

- **The IC is taking notes themselves.** No Scribe assigned, so the IC tries to do both. The notes are bad and the coordination is bad. Fix: assign a Scribe within the first five minutes, even if it's the most junior person on the call.

- **Engineers freelancing.** SMEs investigating independently, not surfacing findings to the IC, running fixes without authorization. Symptoms: contradictory mitigations, services restarted twice, hypothesis disproven by one engineer being re-investigated by another an hour later. Fix: IC explicitly recognizes each SME, asks for explicit status, and routes work.

- **Executives in the response channel.** VP shows up in the incident channel and starts asking questions. The IC tries to answer and stops being IC. Fix: Internal Liaison redirects the executive to an exec-updates channel or to the cadenced status updates. The IC is unreachable to anyone except the response team.

- **No formal hand-off.** Shift change happens by osmosis. The new on-call shows up and starts firefighting; the old on-call drifts away. State is lost. Fix: explicit hand-off briefing, even if it takes ten minutes. Outgoing IC briefs incoming IC on state, open actions, current objectives, and pending decisions.

- **"All-clear" called too early.** Symptoms go away, IC declares resolution, problem recurs an hour later, second incident is opened. Fix: the IC distinguishes between *mitigation* (the immediate symptom is gone) and *resolution* (the root cause is understood and addressed). Mitigation may end the customer-facing incident; resolution is what ends the work.

---

## After the incident: blameless postmortems and action items

The incident response framework is half of incident management. The other half is the learning loop: every incident produces a postmortem, every postmortem produces action items, and every action item gets tracked to completion. A team that responds well to incidents but never learns from them will keep incidenting on the same root cause indefinitely.

### Blameless postmortems

A postmortem is a structured document and review process that turns the incident into organizational learning. **Blameless** is the operating principle: the goal is to understand what happened and prevent recurrence, not to identify whom to punish.

Blameless does *not* mean "no accountability." Engineers remain accountable for their work and for following process. Blameless means that the postmortem assumes good faith and competence on the part of every responder, and asks what about the *system* — tools, alerts, runbooks, documentation, process, training — allowed the incident to occur or escalated its impact. The question is "why did this make sense to a competent person at the time?" not "who screwed up?"

The reasoning is operational, not sentimental. In an organization where postmortems are punitive, people hide information, contest findings, and refuse to participate honestly. In an organization where postmortems are blameless, people surface near-misses, admit confusion, and contribute fully. The blameless organization learns faster and incidents less. This is well-established in the SRE literature and is not optional in any team serious about reliability.

### Postmortem structure

A postmortem document contains, at minimum:

- **Summary.** One paragraph: what happened, when, what was impacted, how long it lasted, what was done. Written for an executive who will read this paragraph and nothing else.
- **Timeline.** Derived from the Scribe's record. The authoritative sequence of events. Times in UTC. Evidence, not interpretation.
- **Impact.** Customer impact (count, geography, severity). Internal impact. Revenue impact if calculable. Regulatory or contractual exposure if any.
- **Root cause analysis.** The chain of causation. What broke, why it broke, why the safeguards that should have caught it didn't. "Five whys" is a common technique but not mandatory — what matters is depth. Surface causes are not root causes. "The deploy went out" is not a root cause; "our deploy gating did not catch this class of regression because we have no integration tests covering this code path" is closer.
- **What went well.** Do not skip this. The response will have done things right, and naming them is how those things get repeated.
- **What went poorly.** Where the response failed. Tools that didn't work, information that was missing, decisions that were slower than they should have been. Blameless framing applies.
- **Action items.** See below. Each one has a single named owner and a specific due date.

### Postmortem vs. timeline

The Scribe's timeline and the postmortem are different artifacts and the distinction matters. The timeline is **evidence** — comprehensive, factual, untouched by interpretation. The postmortem is **interpretation** — selective, analytical, drawing conclusions from the timeline. A good postmortem cites the timeline; it does not replace it. Both artifacts get preserved. If the postmortem is ever contested — by Legal, by a customer, by a regulator — the timeline is what defends it.

### Action items and follow-through

Postmortems produce action items. Action items go to die.

This is the single most common failure mode of mature-looking incident response programs: the response is well-run, the postmortem is well-written, and then the action items languish in a backlog that nobody owns until the next incident proves they were never done. The discipline of follow-through is what closes the loop, and without it, the framework is theater.

The mechanics:

- **Every action item has a single named owner.** Not a team. A person. Teams do not get pages; people do.
- **Every action item has a specific due date.** "Q3" is not a due date; "2026-08-15" is.
- **Every action item is tracked in a system the team already uses** — Jira, Linear, GitHub issues, whatever. *Not* a postmortem document that nobody opens again. The action item must live where the team's other work lives, with the team's other priorities visible alongside it. If it isn't on the same board as the feature work, it loses every prioritization fight by default.
- **Overdue action items get surfaced.** A weekly or biweekly review of open incident action items, with the engineering manager present, keeps them from drifting. Overdue items get re-estimated and re-prioritized, not silently ignored.
- **Severity-1 action items are non-negotiable.** If the postmortem identifies a fix that would have prevented a Sev-1, that fix happens. It does not get traded against feature work in the next sprint. This requires management buy-in, and it is the test of whether the org genuinely values reliability or just talks about valuing it.

A team that runs three good incident responses and lets the action items rot has gained nothing. A team that runs three mediocre responses and closes every action item from the postmortems will, in six months, be running good responses *and* incidenting less.

---

## Adopting this

Adoption is not a tool purchase. It is a cultural change, and it takes practice. The fire service spends a significant portion of its training time drilling on ICS specifically because the discipline does not survive contact with a real fire unless it has been rehearsed.

The technology analog is **Game Days** — Robbins' other contribution to the field. A Game Day is a planned, controlled incident. You break something in a non-production environment (or a carefully chosen production component) and you run the full response — IC, Deputy, Scribe, SMEs, Comms, Internal Liaison — as if it were real. You write a real timeline. You write a real postmortem. You evaluate the response, not the technical fix.

Game Days are how the muscle gets built. Without them, the first time the team uses ICS will be at 3 AM during a real Sev-1, which is the worst possible time to be learning role discipline. Run Game Days. Run them often. Rotate roles so that everyone has been IC and everyone has been Scribe.

---

## Further reading

- **[Incident Management for Operations](https://www.oreilly.com/library/view/incident-management-for/9781491917619/)** — Schnepp, Vidal, Hawley (O'Reilly, 2017). Robbins wrote the foreword. This is the closest thing to a definitive written treatment of his approach. If you read one thing, read this.

- **[Google SRE Book, Chapter 14: Managing Incidents](https://sre.google/sre-book/managing-incidents/)** — Free online. Same lineage, Google's naming and operational specifics. Worth reading alongside the O'Reilly book to see how the model adapts to different organizational shapes.

- **[Google SRE Book, Chapter 15: Postmortem Culture: Learning from Failure](https://sre.google/sre-book/postmortem-culture/)** — The canonical statement of blameless postmortem culture in the SRE tradition. Read this alongside the postmortems section above.

- **[John Allspaw — "Blameless PostMortems and a Just Culture"](https://www.etsy.com/codeascraft/blameless-postmortems/)** — The 2012 Etsy essay that established blameless postmortems as a discipline in web operations. Short, foundational, still relevant. Allspaw and Robbins were both at Velocity during the same window and the two threads (incident response + blameless review) developed in parallel.

- **[PagerDuty Incident Response Documentation](https://response.pagerduty.com/)** — PagerDuty was an early adopter of the Robbins-flavored model and open-sourced their full process. This is the most accessible public codification.
  - [Different Roles](https://response.pagerduty.com/before/different_roles/)
  - [Scribe Training](https://response.pagerduty.com/training/scribe/)
  - [Incident Commander Training](https://response.pagerduty.com/training/incident_commander/)

- **[Atlassian: Incident Response Roles and Responsibilities](https://www.atlassian.com/incident-management/incident-response/roles-responsibilities)** — Atlassian's variation, also Robbins-influenced.

- **[FEMA ICS-100 Course Material (PDF)](https://www.usda.gov/sites/default/files/documents/ICS100.pdf)** — The upstream source. Free, federal, comprehensive. Worth understanding if you want to know *why* the roles are shaped the way they are.

- **[Incident Command System — Wikipedia](https://en.wikipedia.org/wiki/Incident_Command_System)** — Overview of the full ICS structure, including the sections (Planning, Logistics, Finance) that the web-ops adaptation typically omits.

- **[Jesse Robbins's site](https://jesserobbins.com/)** and his **[Topics page](https://jesserobbins.com/topics/)** — Robbins's personal site (bio, portfolio, mentions) and his topical writing on Master-of-Disaster work, Game Days, DevOps history, and the ops culture lineage this framework comes from.

- **[Jesse Robbins — Wikipedia](https://en.wikipedia.org/wiki/Jesse_Robbins)** — Background on Robbins himself: Amazon "Master of Disaster," Chef co-founder, Velocity co-founder, volunteer firefighter, Katrina task force.

- **Robbins' Velocity Conference talks** — Available through the O'Reilly Velocity channel. His talks on operations culture and the fire-service-to-IT translation are the original source material in spoken form.
