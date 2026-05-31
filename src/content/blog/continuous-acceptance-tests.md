---
title: 'Continuous Acceptance Tests'
excerpt: "An acceptance test run once before deploy proves the data was correct for one instant. The data does not stay correct because the deploy was green. Stop retiring your best test the moment it passes. Run it forever."
publishDate: 'May 31 2026'
tags:
  - Testing
  - Observability
  - Engineering
  - Architecture
isFeatured: true
---

## The Test You Throw Away

On the systems I build, every deployment is gated by acceptance tests. Not unit tests, not mocks — black-box tests that stand up the service, talk to it over HTTP the way a real consumer would, and assert on what comes back. Not the status code. The *data*. The shape of the JSON, the types of the fields, the sanity of the values. A `200 OK` with a broken body is a failed deployment. The contract is the data, and the test verifies the contract.

Then the deploy goes green, and we throw the test away.

Not literally — it sits in the repo, ready for next time. But operationally we throw it away. It ran once, against one instant, and proved the data was correct *at the moment of deploy*. Then everyone moves on, and the test sleeps until the next release. The single most accurate description of "is this API actually working" that we own, and we run it for one second out of every release cycle.

That is the bug. Not in the test. In how we use it.

## "Can" Was Correct. "Does" Is the Question.

I have written before about the gap between `can` and `does`. A system where the data *can* be wrong is every system. A system where the data *does* go wrong is one you gave enough time. A pre-deploy acceptance test answers the first question: *can* this code produce correct data? Yes — we just watched it. It says nothing about the second.

Code correctness is mostly a deploy-time property. The binary you shipped does not rewrite itself between releases. If the acceptance suite passed, the *code* is going to keep doing what it did, because code is the one part of the system that holds still.

Data correctness is not a deploy-time property. It rots. The code that returned a clean catalog on Tuesday is returning garbage on Thursday and nothing about the binary changed. An upstream partner renamed a field. A migration ran out of order. A batch job seeded a table with nulls. A cache is serving a shape from two versions ago. A dependency that used to return prices in cents started returning them in dollars. None of that is a code bug your acceptance suite could have caught before deploy, because none of it had happened yet.

The acceptance test would catch every one of them. It is just asleep.

So stop letting it sleep. Take the exact test that gates your deploy, and run it against production on a schedule, forever. That is a Continuous Acceptance Test.

## What It Actually Is

A Continuous Acceptance Test is a synthetic monitor that asserts on the *shape and content* of a live API's responses, on a schedule, in perpetuity. Same discipline as the pre-deploy gate. Different lifecycle. Instead of "does the data pass once, so we can ship," it is "does the data still pass, right now, and page me the moment it does not."

Note the gap it fills, because conventional monitoring does not fill it. Uptime and synthetic checks answer "is it up and is it fast?" — they hit an endpoint, look at the status code, maybe match a string, and measure latency. That is necessary. It is nowhere near sufficient. An API can return `200 OK`, in forty milliseconds, with a perfectly valid JSON envelope, and a completely broken payload. Empty array where there should be a catalog. A price of `-1`. A field that used to be a number and is now a stringified number. Every uptime probe on Earth stays green. Every customer is staring at a blank storefront.

`200 OK` is not the contract. The data is the contract. Monitor the contract.

## What It Looks Like

Say we run a storefront behind a handful of services — a catalog, a cart, payments. Here is the kind of assertion that already gates the deploy:

```bash
resp="$(curl -fsS https://api.example.com/v1/catalog)"

# Shape: the envelope and the field types are part of the contract.
test "$(jq -r '.items | type'              <<<"$resp")" = array
test "$(jq -r '.items[0] | type'           <<<"$resp")" = object
test "$(jq -r '.items[0].price_cents|type' <<<"$resp")" = number
test "$(jq -r '.items[0].name | type'      <<<"$resp")" = string

# Content: the values have to make sense, not merely exist.
bad="$(jq '[.items[]
  | select(.price_cents <= 0 or (.price_cents|floor) != .price_cents)]
  | length' <<<"$resp")"
test "$bad" -eq 0   # every price is a positive, whole number of cents
```

There is nothing here you could not have written in CI. The only thing that turns it from an acceptance test into a *Continuous* Acceptance Test is when and how often it runs:

```yaml
# A synthetic monitor, not a CI job. Same assertions, longer time horizon.
monitor: catalog-data-contract
schedule: "* * * * *"          # every minute, against production
assert:
  - jq: '.items | length'                op: ">="  value: 1
  - jq: '.items | type'                  op: "=="  value: "array"
  - jq: '.items[].price_cents | type'    op: "all" value: "number"
  - jq: '[.items[] | select(.price_cents <= 0)] | length'  op: "==" value: 0
alert:
  on_fail: page
  after: 2                       # two consecutive failures, not one blip
```

The pre-deploy run proves the data is acceptable *now*. The monitor proves it is *still* acceptable at 3 AM on a Sunday, when an upstream you do not control shipped a breaking change and did not tell you.

## The Failures That Hide Behind a 200

This is the part that earns its keep. Walk the list of outages that uptime monitoring sails straight past, all of them green on every dashboard you own:

- **Empty-but-successful.** A seed job failed and the catalog query returns `[]`. HTTP 200. Customers see nothing. A length assertion catches it in a minute.
- **Type drift.** A serializer change turns `price_cents: 700` into `price_cents: "700"`. The frontend's math silently produces `NaN`. A type assertion catches it.
- **Upstream shape change.** A partner renames `total` to `amount`. Your gateway faithfully passes through a payload missing the field your clients require. A presence assertion catches it.
- **Value corruption.** A bad migration writes negative or fractional cents. Everything validates as a number; the *values* are nonsense. A content assertion catches it.

Notice what every one of these has in common: your code is fine. Your tests passed. Your deploy was green. And the data is wrong anyway. That is the whole point. The thing your customers consume is the data, so the data is the thing you have to watch — not once, continuously.

## Where It Fits, and Where It Stops

A Continuous Acceptance Test does not replace your SLOs, your metrics, or your logs. It is the layer that tells you *the product is broken* while the rest of your telemetry swears everything is healthy. Wire its failures into the same alerting path as everything else, and give it tolerance for a single blip — page on two consecutive failures, not on one dropped packet.

A few honest limits, because every component you add is a bet and this one is no exception:

- **Do not re-run your whole suite in production.** This is not where you exercise edge cases or mutate real state. Assert on the stable contract — the shape, the types, the invariants that must always hold — not on volatile values that legitimately change minute to minute. A monitor that cries wolf gets muted, and a muted monitor is worse than none.
- **Mind cost and cardinality.** Every minute, forever, across every endpoint adds up. Monitor the surfaces consumers actually depend on, at a frequency matched to how fast the data can credibly go bad.
- **Geographic distribution is optional.** A classic synthetic monitor runs from a dozen regions because *latency and reachability* are location-dependent. The *correctness of the data* usually is not — wrong is wrong from anywhere. Run it from one place by default. Add locations only when the API itself is location-sensitive: geo-fenced inventory, regional pricing, per-region failover you actually need to prove. Do not pay for twelve probes to assert the same field twelve times.

## Acceptance Is a Condition, Not an Event

A deployment is acceptable when the data coming out of the API is correct in shape and content. Read that definition again and find the part that expires when the deploy finishes. It is not there. The condition the acceptance test verifies is supposed to hold the whole time the service is running — so the test should run the whole time the service is running.

We already wrote the hard part. We built the test that talks to the real thing and judges it by the only standard that matters to a consumer: is the data right? Then we scoped it to a single instant and called it a gate. Widen the scope. Let it run until you turn the service off, and let it page you the moment the data stops being acceptable — instead of letting a customer discover it for you.

Acceptance is not something that happened at deploy. It is something that is either true or false right now. Monitor it like the condition it is.
