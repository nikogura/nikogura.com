# Engineering Standards

## Table of Contents
- [Core Philosophy](#core-philosophy)
- [Code Quality & Linting](#code-quality--linting)
- [Golang Best Practices](#golang-best-practices)
- [Repository Structure](#repository-structure)
- [Error Handling](#error-handling)
- [External Connections](#external-connections)
- [Kubernetes & GitOps](#kubernetes--gitops)
- [Security & Compliance](#security--compliance)
- [Documentation](#documentation)
- [Investigation Methodology](#investigation-methodology)

---

## Core Philosophy

Security, reliability, and compliance are non-negotiable. Every line of code is a potential attack vector or compliance violation. Move deliberately, not fast. Test all assumptions.

### The Master's Approach

Excellence is a muscle. The more you exercise it, the stronger it becomes. "Doing it right" gets faster with practice, and faster work becomes better with repetition. That's mastery: producing master-level work with less effort than it takes an apprentice to pick up the tools.

Write every line of code as if you'll publish it under your own name. Even if a repo will "never see the light of day," we owe it to ourselves and our successors to maintain excellence. Git is forever. If your name is on it, make it a lesson in coding excellence.

### Code Reusability

Design your code so it can be reused and refactored quickly. This isn't about perfection—it's about making it easy for your future self to swap out clunky implementations in 5-10 minutes of free time.

Technical debt doesn't get paid down due to lack of desire; it persists due to lack of time. Front-load your pain by writing tests and modular code. If refactoring is easy and provable through tests, it will get done. Make refactoring easy.

---

## Golang Best Practices

### Go Proverbs

The language's author said it best: https://go-proverbs.github.io/

Key proverbs we emphasize:
- **interface{} says nothing** - Use real interfaces with actual types
- **Clear is better than clever** - Your 3AM self will thank you
- **Errors are values** - Use them, don't just check them
- **Don't panic** - Handle errors gracefully
- **A little copying is better than a little dependency**

### Write Golang as Golang

Golang is interface-oriented, not object-oriented. This is subtle but fundamental. Each language has syntax, but also idiom. Learn both, or you're missing out on what makes the language worth using.

**Keep packages flat.** Labyrinthine package trees get complicated quickly. If you really need a different package, make it a totally different module with its own lifecycle in a different repo.

### SOLID/MVC Principles in Golang

While SOLID was written for OOP (and Golang isn't OO), the principles remain the same:

- **Single Responsibility** - Do one thing well (The Unix Way)
- **Don't half-ass two things. Whole-ass one thing.** - Ron Swanson

#### Libraries (Models)
- Write general-purpose, exhaustively tested libraries
- Libraries should consume data and emit data
- No assumptions about how or where data will be used
- Libraries don't change much unless business fundamentals change
- One library can serve CLI, web, API, and other programs

#### Views
- Views change frequently
- One Model to many Views relationship
- A CLI is just a view—one way to interact with the Model
- Web pages, APIs, CLIs are all just different views

#### Tests
- No such thing as a "stupid test"
- Simple tests take 90 seconds to write and live forever
- Little tests add up—no raindrop feels responsible for the flood
- Teach the machine to verify your expectations

### Code Layout

Follow https://github.com/golang-standards/project-layout

**Key points:**
- Put library code in `/pkg` (reusable by other programs)
- Avoid `/internal` unless you have an astoundingly good reason
- Put CLI/main code in `/cmd`
- Never mix the two

**Generate standardized repos:**
```bash
dbt boilerplate gen
```

### Public vs Private

**Default to public** unless you can articulate why something needs to be private. Don't impose restrictions on your future self without good reason.

In Golang:
- Public: starts with capital letter (accessible outside package)
- Private: starts with lowercase letter (internal only)

This is especially important for Golang beginners. Some error messages are esoteric, and words are used in slightly different ways that will bite you.

### Building Code

Use standard conventions:

```bash
go build  # Produces binary named after directory
```

**Don't do this:**
```bash
go build -o main .  # Binary named "main" is meaningless
```

Seeing `/app/main` in a container tells you nothing. Seeing `/app/curator-bybit` provides information.

Generally, a single repository should build a single binary and be buildable with simply `go build`. If the repo is laid out differently or contains multiple binaries, perhaps you're being overly clever. Clear is better than clever. Simple is easier to debug in a crisis.

---

## Code Quality & Linting

### Golang Linting is Law

**golangci-lint** is the standard. All Go code must pass golangci-lint with the project's standardized configuration.

- Zero tolerance for linting violations. If the linter complains, the code is wrong.
- When suggesting code changes, verify they comply with the project's golangci-lint configuration.
- Reference configuration: [.golangci.yml](.golangci.yml) (included in this repository)

### Named Returns Are Mandatory

The `namedreturns` linter [https://github.com/nikogura/namedreturns](https://github.com/nikogura/namedreturns) enforces named return values. Named returns provide critical information to both engineers and compilers.

**Why Named Returns Matter:**

```go
// WRONG - Unnamed returns lack context.  You're missing an opportunity to make your code self-documenting here.
func Foo() (string, error) {
    return "", nil
}

// WRONG - Named returns, but returning something different from what's promised - this leads to confusion and surprises.  In a big, complex function you might be returning something unexpected. Better to be explicit than surprised.
func Foo() (output string, err error) {
    return "", nil
}

// RIGHT - Named returns document your intent, and makes the code clear, and easy to review.
func Foo() (output string, err error) {
    output = "bar"
    return output, err
}
```

**Honor the Function Contract:**
- Name your return values descriptively
- Return what you promise, not something "just as good"
- Every return statement must explicitly use the named return variables

### Common Lint Patterns

#### 1. Globals and Init fuctions.  Cobra and Prometheus both make heavy use of global variables and init().  In the case of Prometheus, this is part of what makes Prometheus so easy to implement.  We need to allow this to use these common modules. However, if you haven't thought it through to the level that the Prometheus authors have, globals and init functions are probably something to avoid.

```go
//nolint:gochecknoglobals // Cobra boilerplate 
var rootCmd = &cobra.Command{...}

//nolint:gochecknoinits // Cobra boilerplate
func init() {...}
```

#### 2. Avoid Nested Closures with Returns
```go
// ANTI-PATTERN - causes namedreturns issues
func Outer() (result string, err error) {
    token, err := jwt.Parse(str, func(t *jwt.Token) (interface{}, error) {
        if check { return nil, errors.New("bad") }
        return key, nil
    })
}

// CORRECT - extract to top-level function.  It's just clearer, and clear is better than clever.
func lookupKey(token *jwt.Token, config Config) (key interface{}, err error) {
    return key, err
}

func Outer() (result string, err error) {
    token, err := jwt.Parse(str, func(t *jwt.Token) (interface{}, error) {
        return lookupKey(t, config)
    })
}
```

#### 3. Reduce Cognitive Complexity
Extract helper functions instead of deeply nested logic:
```go
func validateAudience(claims jwt.MapClaims, expected string) bool {...}
func extractGroups(claims jwt.MapClaims) []string {...}
func validateGroupMembership(userGroups, allowedGroups []string) bool {...}
```

#### 4. Avoid Inline Error Handling - it's easier to read, and are you really worried about the extra newline?
```go
// WRONG
if err := doSomething(); err != nil {...}

// RIGHT
err := doSomething()
if err != nil {...}
```

#### 5. Proto Field Access
```go
req.GetSourceBucket()  // CORRECT
req.SourceBucket       // WRONG
```

---

## Repository Structure

### Standard Dockerfile

Use multi-stage builds with distroless images for minimal attack surface and image size:

```dockerfile
FROM golang:1.23.4 AS builder

WORKDIR /app

# Setup Git for SSH access to private repos
RUN git config --global url."git@github.com:".insteadOf "https://github.com/"
RUN mkdir -p ~/.ssh && ssh-keyscan -H github.com >> ~/.ssh/known_hosts
RUN go env -w GOPRIVATE="github.com/<YOUR_ORG>/*"

# Copy dependency files first for layer caching
COPY go.mod go.sum ./
RUN --mount=type=ssh go mod download

# Copy source code
COPY . .

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux go build .

# Use distroless for minimal runtime
FROM gcr.io/distroless/base-debian12:nonroot

# Copy binary with correct ownership
COPY --from=builder --chown=nonroot:nonroot /app/<binary-name> /app/

ENTRYPOINT ["/app/<binary-name>"]
```

**Key points:**
- Multi-stage builds keep images small (distroless base is ~20MB vs ~1GB for full golang image)
- `CGO_ENABLED=0` produces static binaries that work in distroless
- Distroless images contain only your app and runtime dependencies (no shell, package managers)
- `nonroot` user runs as UID 65532 for security
- Layer caching: copy `go.mod`/`go.sum` before source code
- SSH mount (`--mount=type=ssh`) provides access to private repositories during build
- Distroless images handle signals properly - the binary runs as PID 1 and receives signals directly

**Building with SSH:**
```bash
docker build --ssh default .
```

### Container Consistency

Use the same container for all stages:
- If you plan to run on Ubuntu, build with Ubuntu
- If you plan to run on Debian, build and test with Debian
- **Never** build or test with Alpine if running on Debian/Ubuntu

Alpine uses Musl-C instead of GlibC. Binaries compiled on Alpine won't run on Debian. These errors require large amounts of debugging hours. Avoid them entirely.

---

## Error Handling

### Errors Are Values

Don't just check errors to satisfy the compiler. Use the value. When constructing error handling routines, make them useful.

### Always Do This

```go
thing := "foo"
err := DoSomethingWith(thing)
if err != nil {
    err = errors.Wrapf(err, "failed to do something with %s", thing)
    return err
}
```

Add context to errors. Make it easy to `grep` the code for the error message.

### Never Do This

**Don't ignore errors:**
```go
thing, _ := SomethingThatReturnsThingAndErr()  // WRONG - errors are hidden
```

**Don't use boilerplate error messages:**
```go
const SOME_ERROR = "something went wrong"
return errors.New(SOME_ERROR)  // WRONG - can't grep for it
```

**Don't compress error handling:**
```go
// WRONG - hard to read
if err := priceConverter.Start(ctx); err != nil {
    return fmt.Errorf("could not start price converter: %w", err)
}

// RIGHT - clear and readable
err := priceConverter.Start(ctx)
if err != nil {
    err = errors.Wrapf(err, "could not start price converter for %s", thing.Name())
    return err
}
```

### Don't Panic

`panic()` and `recover()` are built into Golang, but we should never use them. Simply put, there are better mechanisms to handle errors. Most of the time, panicking is a sign of laziness or lack of concern for maintainability.

**Especially avoid deferred panic recovery:**
```go
// HORRIBLE - don't do this
defer func() {
    if err := recover(); err != nil {
        logrus.WithField("err", err).Error("panic-discovered")
        sentry.CaptureException(err.(error))
        panic(err)  // Re-panicking is even worse
    }
}()
```

This gives you no information about where the error came from. In a 775-line function, good luck finding the error point quickly.

### Exit with Logs and Return Codes

Services should not exit unless they cannot continue. When you must exit:

- Use `exit()`, not `panic()`
- Log useful information before exiting
- Return an error code (0 = success, non-zero = failure)
- Prefer `exit(100)` over `exit(1)` for deliberate exits

Standardized error codes are an eventual goal. In the short term, even `exit(1)` is preferable to panic or no exit at all.

Don't leave us hanging. Getting paged for a CrashLoopBackoff is not how we should learn about problems.

### Return Early

Check errors and bail out of functions as soon as you find one you can't handle. Golang generally avoids `else` and prefers early returns.

---

## External Connections

Every system making external connections must support:

1. **Rate limits** that default to 0 (no limit)
2. **Retries with exponential backoff**
3. **Clear logging** - we should always know what's happening
4. **Metrics** on:
   - Number of calls by method
   - Number of errors
   - Durations
   - Backoff period
   - All broken down by method
5. **Never exit or panic** on failed connection - workload should continue to self-heal

Pods entering crashloop due to connection errors is an anti-pattern to avoid at all costs.

### Retries and Exponential Backoff

We live in an imperfect world. Code the assumption that things won't always work into your services.

In Kubernetes, **pods are mortal**. This means the fundamental unit of work is expected to run, die, and be replaced at any time. A CrashLoopBackoff is not an error in itself. Something stuck in CrashLoopBackoff for too long is.

Assume whatever you're connecting to may not be there or may not answer. Incorporate retry logic, but endless retries become the cause of further errors. Retries need exponential backoff.

---

## Kubernetes & GitOps

### GitOps Principles

GitOps, coined by Weaveworks, is the practice of controlling infrastructure declaratively through Git.

**In short:**
1. Everything is applied via IaC through Git
2. Nothing is applied outside of IaC through Git
3. If something is added/removed in Git, it's added/removed from the environment
4. If something is changed outside of Git, automation changes it back

**Never:**
- Propose or attempt direct kubectl applies to managed systems
- Modify resources in managed systems without explicit instruction
- Commit or push to git without explicit instruction

### No Blind Application of Resources

One of the biggest anti-patterns is blindly downloading and applying resources to clusters. Examples to avoid:

```bash
# DON'T do this
kubectl apply -f https://raw.githubusercontent.com/.../deploy.yaml
helm install my-release some-chart
kubectl apply -k <url>
```

Under no circumstances should anyone apply unevaluated resources to clusters. Read through every line and understand how they apply to your infrastructure and affect your security posture.

### Control Repositories

Control Repositories contain Infrastructure as Code configuration. The main controls needed:
- What change was made?
- Who made the change?
- When did the change happen?
- How do we roll back?

All of the above is given for free with VCS, so code reviews and pull requests can cause unnecessary burden and slow down delivery velocity.

That's not to say there shouldn't be PR's and code reviews.  We use the same tools (Git, etc) for control repositories and code repositories, but we don't necessarily need to use the tools in the same way.  

Much of the time, ceremonies on a control repository can be reduced or abbreviated.  It's not that we don't want reviews or communication, but we also don't want to needlessy distract or get into a pattern where people don't read or understand the changes and just 'rubber stamp' approvals.

### Kubernetes Resource Approaches

There are 4 main ways of managing resources in Kubernetes:
- Bare YAML Files
- [Helm](https://helm.sh/)
- [Kustomize](https://kustomize.io/)
- [Jsonnet](https://jsonnet.org/)

You'll encounter all four eventually. You can't really work in Kubernetes without uderstanding all 4.  Among them, Jsonnet is the author's preferred solution due to its flexibility and resistance to blind application.  Having everything explicitly laid out in code that is checked in also makes it really easy for an agent to read/understand/diagnose problems, and better yet, fix them.

---

## Proto Files: Interface Definitions, Not Data Authorities

Proto files define **interfaces between services**, not authoritative data types. Their primary function is to define message structures for communication, ensuring consistency in API contracts.

### Why This Matters

Your application logic should dictate data types—not proto files. Proto messages are **transport representations**, optimized for serialization. They're not designed to be the authoritative source of core data structures.

### Pitfalls of Using Proto Messages as Core Types

- **Conflicting imports & type mismatches** - Multiple services with different expectations
- **Code coupling** - Changes to proto files ripple across unrelated parts
- **Unnecessary complexity** - Proto dependencies in utility libraries
- **Serialization vs. business logic** - Blurred concerns lead to performance bottlenecks

### A Better Approach

1. **Define your own structs** - Domain-driven structs that fit your application
2. **Convert between internal structs & proto messages** - Map when communicating
3. **Keep protos focused on API contracts** - Define how services interact, nothing more
4. **Never reuse tags** - Changing a field? Use a new tag number

**Example:**

```go
// WRONG - Proto-centric
import "github.com/myorg/protos/common"

func GetBlockchainID() common.Blockchain {
    return common.Blockchain_ETH  // Hard-coupled to proto
}

// RIGHT - Decoupled
type Blockchain int

const (
    Ethereum Blockchain = 1
    Bitcoin  Blockchain = 2
)

func GetBlockchainID() Blockchain {
    return Ethereum
}

// Convert only when needed
func ToProtoBlockchain(b Blockchain) common.Blockchain {
    return common.Blockchain(b)
}
```

Think of proto files like blueprints for service contracts—not laws governing your entire codebase.

---

## Observability

### Understand the Difference between Metrics and Logs 

Logs are expensive. Absent complicated log parsing mechanisms, they're a stream of noise nobody reads.

Metrics, being essentially numbers, are easy for machines to parse, store, and understand. We prefer to expose critical information via metrics since it's easy to:
- Perform actions based on them
- Track changes over time
- Look back when incidents happen

Logging "all the things, all the time" is not sustainable. Metrics are much cheaper and easier to handle.

That's not to say that logs are unimportant.  Metrics in systems like Prometheus scale with the cardinality of labels.  Cardinality is a huge concern with metrics systems.

Logs on the other hand, allow near infinite cardinality.  Some data, like say requests are better captured by logs.

Any real system will incorporate both.

### Real-World Example: WAF Security Logs

Web Application Firewall (WAF) logs demonstrate the complementary nature of metrics and logs.

**The Problem:** WAF systems like ModSecurity generate structured JSON logs for every blocked request. Each log contains:
- Client IP address (potentially millions of unique values)
- Full request URI (infinite possible values)
- Request headers and cookies (high cardinality)
- Matched rule details and attack patterns
- Timestamp and geographic data

Storing this in Prometheus would be impossible - the cardinality would explode the metrics database.

**The Solution: Hybrid Approach**

**Metrics for Aggregates:**
```prometheus
# Track overall block rate
rate(modsec_requests_blocked_total[5m])

# Alert on anomalies
modsec_requests_blocked_total > 100/min

# Track by attack type (low cardinality)
modsec_blocks_by_type{type="SQLi"}
modsec_blocks_by_type{type="XSS"}
```

**Logs for Details:**
- Ship structured ModSecurity logs to Elasticsearch via Filebeat/Fluent Bit
- Use ingest pipelines to enrich with GeoIP data
- Extract attack types from rule IDs (930=LFI, 941=XSS, 942=SQLi)
- Create searchable indices for investigation

**Example Elasticsearch Ingest Pipeline:**
```json
{
  "processors": [
    {
      "geoip": {
        "field": "client",
        "target_field": "geoip"
      }
    },
    {
      "script": {
        "source": "
          if (ctx.transaction?.messages != null) {
            def ruleId = ctx.transaction.messages[0]?.details?.ruleId;
            if (ruleId?.startsWith('930')) ctx.attack_type = 'Path Traversal/LFI';
            else if (ruleId?.startsWith('941')) ctx.attack_type = 'XSS';
            else if (ruleId?.startsWith('942')) ctx.attack_type = 'SQLi';
          }
        "
      }
    }
  ]
}
```

**Query Pattern:**
```bash
# Metrics: "Are we under attack right now?"
curl prometheus:9090/api/v1/query?query=rate(modsec_blocks[1m])

# Logs: "Who attacked us and what did they try?"
curl elasticsearch:9200/modsec-*/_search -d '{
  "query": {"range": {"@timestamp": {"gte": "now-1h"}}},
  "aggs": {
    "by_country": {"terms": {"field": "geoip.country_name"}},
    "by_attack": {"terms": {"field": "attack_type"}}
  }
}'
```

**Investigation Automation:**

The [diagnostic-slackbot](https://github.com/nikogura/diagnostic-slackbot) project demonstrates automated WAF analysis:
- Slack users trigger investigations via slash commands
- Bot queries Loki for recent ModSecurity blocks
- Claude AI analyzes logs and categorizes threats
- Automated reports identify false positives vs. real attacks
- Generates whitelisting recommendations for legitimate traffic

**Key Insight:** Use metrics for real-time alerting and dashboards. Use logs for forensic analysis and investigation. Neither is sufficient alone.

### Prefer Continuous Systems to Jobs

When possible, prefer services that run continuously over Jobs and CronJobs.

If you need a periodic task, code the period into the service itself with internal timers. This provides easier monitoring via Prometheus rather than using a PushGateway.

Prometheus supports the PushGateway, but the support is limited.  Prometheus was designed to periodically scrape a long running service.  Pushing metrics is opposite to the basic Prometheus design philosophy, and therefore it's not always as reliable as scraping.  The last thing we want is to lose information.

**Services with internal cron-like tasks must:**
- Run once on server start (so "kick off now" means "delete the pod")
- Expose metrics:
  - Counter for number of runs (with timestamp label)
  - Counter for failed runs
  - Counter for successful runs
  - Gauge showing run duration

### List All Metrics in the README

The README alone should be sufficient to set up dashboards and alerts. List all metrics and labels.

---

## Security & Compliance

### Non-Negotiables

- Security, compliance, and reliability are non-negotiable
- Never suggest sharing data with third-party vendors without explicit approval
- Access controls and audit trails are critical
- Assume every query is logged and auditable
- Never suggest turning off security controls globally
- All modifications to security controls must be minimal and closely targeted
- Read-only operations only unless explicitly authorized

### Investigation Methodology

**Critical: Don't Assume, Investigate**

- Read the actual code—don't pattern-match to common scenarios
- If told to examine specific code, READ IT FIRST
- Organizations often have custom implementations that don't follow typical patterns
- Stop and examine actual implementation before assuming standard patterns

**Systematic Debugging Process:**
1. Start with the obvious: recent deployments, known incidents
2. Check metrics for anomalies
3. Correlate with logs
4. Cross-reference with system events
5. Be systematic—don't jump to conclusions
6. Document your investigation path

**For security tool blocks (WAF, etc.):**
- Query security logs to understand what triggered
- Identify the rule ID
- Correlate with the upstream request in application logs
- Understand the legitimate use case before suggesting rule changes

---

## Documentation

### Documentation Must

1. Reside in the repo for the code it describes
2. Be written in Markdown
3. Be accessible via link from Notion
4. Be stored in top-level `/docs` directory
5. Be renderable in any format from Markdown source
6. Be rendered in PDF format
7. Be named clearly in CamelCase (e.g., `ServiceArchitecture.pdf`)

### Documentation Must Not

1. Be located in multiple places
2. Be stored in dead-end formats where they can't be easily extracted or re-rendered

### Rendering

Use [pandoc](https://pandoc.org/) to render Markdown to nearly any format:

```bash
pandoc -f markdown -t pdf -o NameOfDoc.pdf <source file>
```

**Warning:** LaTeX project is huge. Be prepared for a large download.

Documentation examples should follow this pattern, with PDFs generated from Markdown source.

---

## Communication Style

- Be direct and technical
- Don't sugar-coat problems
- Assume the user understands the technology
- Skip pleasantries, focus on substance
- If you don't know something, say so clearly

---

## What NOT to Do

- **Don't** propose "quick fixes" that bypass established processes
- **Don't** suggest disabling linters or tests to make code pass
- **Don't** make assumptions about what's acceptable in production
- **Don't** auto-apply changes without review
- **Don't** treat compliance requirements as negotiable
- **Don't** propose changes requiring manual intervention in production

---

## Remember

Every decision has security, compliance, and reliability implications. When uncertain about whether something meets standards, err on the side of caution and ask.

Excellence is not optional. It's a practice, a discipline, and ultimately, a habit. Make it yours.

---

*"I will find a way, or I will make one."* - Hannibal Barca
