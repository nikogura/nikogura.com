# Engineering Standards

## Table of Contents
- [Philosophy](#philosophy)
- [Golang](#golang)
- [Testing](#testing)
- [Repository & Build](#repository--build)
- [API Design](#api-design)
- [Infrastructure](#infrastructure)
- [Observability](#observability)
- [Security & Compliance](#security--compliance)
- [Documentation](#documentation)
- [CI/CD](#cicd)
- [For AI Agents](#for-ai-agents)

---

## Philosophy

Security, reliability, and compliance are non-negotiable. Every line of code is a potential attack vector or compliance violation. Move deliberately, not fast. Test all assumptions.

### Craftsmanship

Excellence is a muscle. The more you exercise it, the stronger it becomes. "Doing it right" gets faster with practice, and faster work becomes better with repetition. That's mastery: producing high-quality work with less effort than it takes a beginner to pick up the tools.

Write every line of code as if you'll publish it under your own name. Even if a repo will "never see the light of day," you owe it to yourself and your successors to maintain excellence. Git is forever. If your name is on it, make it count.

### Reusability

Design code so it can be reused and refactored quickly. This isn't about perfection—it's about making it easy for your future self to swap out clunky implementations in 5-10 minutes of free time.

Technical debt doesn't get paid down due to lack of desire; it persists due to lack of time. Front-load your pain by writing tests and modular code. If refactoring is easy and provable through tests, it will get done.

---

## Golang

### Go Proverbs

The language's author said it best: https://go-proverbs.github.io/

Key proverbs:
- **interface{} says nothing** — Use real interfaces with actual types
- **Clear is better than clever** — Your 3AM self will thank you
- **Errors are values** — Use them, don't just check them
- **Don't panic** — Handle errors gracefully
- **A little copying is better than a little dependency**

### Idiom

Go is interface-oriented, not object-oriented. This is subtle but fundamental. Each language has syntax, but also idiom. Learn both, or you're missing out on what makes the language worth using.

**Keep packages flat.** Labyrinthine package trees get complicated quickly. If you really need a different package, make it a separate module with its own lifecycle in a different repo.

### Single Responsibility

While SOLID was written for OOP (and Go isn't OO), the principles apply:

- **Do one thing well** (The Unix Way)
- **Don't half-ass two things. Whole-ass one thing.** — Ron Swanson

**Libraries (Models):**
- Write general-purpose, exhaustively tested libraries
- Libraries consume data and emit data
- No assumptions about how or where data will be used
- Libraries don't change much unless business fundamentals change
- One library can serve CLI, web, API, and other programs

**Views:**
- Views change frequently
- One Model to many Views relationship
- A CLI is just a view—one way to interact with the Model
- Web pages, APIs, CLIs are all different views

### Code Layout

Follow https://github.com/golang-standards/project-layout

- Put library code in `/pkg` (reusable by other programs)
- Avoid `/internal` unless you have an astoundingly good reason
- Put CLI/main code in `/cmd`
- Never mix the two

Use something like [boilerplate](https://github.com/nikogura/boilerplate) to generate standardized repos. The more familiar code looks, the easier it is to onboard or contribute.

### Public vs Private

Default to public unless you can articulate why something needs to be private. Don't impose restrictions on your future self without good reason.

In Go:
- Public: starts with capital letter (accessible outside package)
- Private: starts with lowercase letter (internal only)

### Building

Use standard conventions:

```bash
go build  # Produces binary named after directory
```

Avoid:
```bash
go build -o main .  # Binary named "main" is meaningless
```

Seeing `/app/main` in a container tells you nothing. Seeing `/app/my-cool-program` provides information.

A single repository should build a single binary with simply `go build`. If the repo contains multiple binaries, consider whether you're being overly clever. Clear is better than clever.

### Linting

All Go code must pass `golangci-lint` with the project's configuration. Zero tolerance for linting violations—if the linter complains, the code is wrong.

Reference configuration: [.golangci.yml](.golangci.yml)

### Named Returns

We recommend use of the `namedreturns` linter. This is a custom linter, not included in golangci-lint.  

Code should be self-documenting and clear.  Named returns go a long way towards achieving this goal.

- Repository: `github.com/nikogura/namedreturns`
- Install: `go install github.com/nikogura/namedreturns@latest`
- All code must use named returns (except generated code)
- Test code must comply (`-test=true` flag, which is the default)

Named returns provide critical information to both engineers and compilers.

```go
// Wrong — unnamed returns lack context
func Foo() (string, error) {
    return "", nil
}

// Wrong — named returns but returning something different
func Foo() (output string, err error) {
    return "", nil  // Promising "output" but returning empty string literal
}

// Right — named returns documenting intent
func Foo() (output string, err error) {
    output = "bar"
    return output, err
}
```

**Honor the function contract:**
- Name return values descriptively
- Return what you promise, not something "just as good"
- Every return statement must explicitly use the named return variables

### Common Lint Problems

**1. Globals and init functions**

Cobra and Prometheus use global variables and `init()`. This is acceptable for well-designed libraries, but avoid in your own code unless you've thought it through carefully.

```go
//nolint:gochecknoglobals // Cobra boilerplate
var rootCmd = &cobra.Command{...}

//nolint:gochecknoinits // Cobra boilerplate
func init() {...}
```

**2. Nested closures with returns**

Extract to top-level functions for clarity:

```go
// Avoid — harder to read and trace
func Outer() (result string, err error) {
    token, err := jwt.Parse(str, func(t *jwt.Token) (interface{}, error) {
        if check { return nil, errors.New("bad") }
        return key, nil
    })
}

// Prefer — extract to top-level function
func lookupKey(token *jwt.Token, config Config) (key interface{}, err error) {
    return key, err
}

func Outer() (result string, err error) {
    token, err := jwt.Parse(str, func(t *jwt.Token) (interface{}, error) {
        return lookupKey(t, config)
    })
}
```

**3. Cognitive complexity**

Extract helper functions instead of deeply nested logic:

```go
func validateAudience(claims jwt.MapClaims, expected string) bool {...}
func extractGroups(claims jwt.MapClaims) []string {...}
func validateGroupMembership(userGroups, allowedGroups []string) bool {...}
```

**4. Inline error handling**

Separate error checks for readability:

```go
// Avoid
if err := doSomething(); err != nil {...}

// Prefer
err := doSomething()
if err != nil {...}

```
That being said, sometimes the inline handling _is_ the clearest way to express the idea behind the code.  There are exceptions to every rule, but unless you can articulate why the exception applies, follow the rule.

**5. Proto field access**

Always use getter methods:

```go
req.GetSourceBucket()  // Correct
req.SourceBucket       // Wrong
```

### Integrating namedreturns

Add `namedreturns` to your `make lint` target.

**Simple projects:**

```makefile
lint:
	@echo "Running namedreturns linter..."
	namedreturns ./...
	@echo "Running golangci-lint..."
	golangci-lint run
```

**Projects with generated code:**

```makefile
lint:
	@echo "Running namedreturns linter..."
	@for pkg in $(shell go list ./pkg/... ./cmd/... | grep -v 'generated/path$$'); do \
		namedreturns -test=true $$pkg || exit 1; \
	done
	@echo "Running golangci-lint..."
	golangci-lint run --timeout=5m
```

Run `namedreturns` before `golangci-lint`. Fail fast.

### Error Handling

**Errors are values.** Don't just check errors to satisfy the compiler. Use the value.

**Always add context:**

```go
thing := "foo"
err := DoSomethingWith(thing)
if err != nil {
    err = errors.Wrapf(err, "failed to do something with %s", thing)
    return err
}
```

Make it easy to grep the code for error messages.

**Don't ignore errors:**

```go
thing, _ := SomethingThatReturnsThingAndErr()  // Wrong — errors are hidden
```

**Don't use generic error messages:**

```go
const SOME_ERROR = "something went wrong"
return errors.New(SOME_ERROR)  // Wrong — can't grep for it
```

**Don't panic.** `panic()` and `recover()` exist, but almost never use them. Panicking is usually a sign of laziness. Especially avoid deferred panic recovery—it gives you no information about where the error originated.

**Exit gracefully:**

- Use `exit()`, not `panic()`
- Log useful information before exiting
- Return an error code (0 = success, non-zero = failure)
- Prefer `exit(100)` over `exit(1)` for deliberate exits

Don't leave pods in CrashLoopBackoff as the way to learn about problems.

**Return early.** Check errors and bail out as soon as you find one you can't handle. Go prefers early returns over nested else blocks.

---

## Testing

All new features and changes must include test coverage.

If someone finds a bug in your software and it's not exposed in your test suite, that's your first problem.

### The TDD Cycle

1. **Red:** Write a test that exposes the flaw. Teach your test suite to recognize the problem.
2. **Green:** Fix the problem. The test now passes and lives in the codebase, protecting you from this mistake forever.

Tests build up over time. What's a functional test today becomes a regression test tomorrow. Over time, you can ship more complex changes with confidence.

### Requirements

| Change Type | Test Requirement |
|-------------|------------------|
| New functions/methods | New unit tests |
| New feature flags/config | Tests for all code paths |
| Bug fixes | Regression tests |
| Refactoring | Tests verifying behavior unchanged |
| API changes | Tests covering new signatures and edge cases |

### Quality Standards

- Tests must be deterministic (no flaky tests)
- Use table-driven tests for multiple scenarios
- Test both happy paths and error conditions
- Run tests in parallel when possible (`t.Parallel()`)
- Test names must clearly describe what's being tested
- Tests must be isolated (no shared state)

### Workflow

1. Write tests for the new feature
2. Implement the feature
3. Run tests: `go test ./...`
4. Run linters: `golangci-lint run`
5. Only then is the feature complete

Code without tests is incomplete.

---

## Repository & Build

### Code Layout

Follow https://github.com/golang-standards/project-layout

### Standard Dockerfile

Use multi-stage builds with distroless images:

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
- Multi-stage builds keep images small (~20MB vs ~1GB)
- `CGO_ENABLED=0` produces static binaries
- Distroless images contain only your app (no shell, no package managers)
- `nonroot` user runs as UID 65532
- Copy `go.mod`/`go.sum` before source for layer caching

**Build with SSH:**
```bash
docker build --ssh default .
```

### Container Consistency

Use the same OS for all stages:
- Build on Ubuntu → Run on Ubuntu
- Build on Debian → Run on Debian
- **Never** build on Alpine if running on Debian/Ubuntu

Alpine uses musl libc instead of glibc. Binaries compiled on Alpine won't run on Debian. This causes debugging nightmares. Use the same containers for build, test, and deployment.

---

## API Design

### Proto Files Are Interface Definitions

Proto files define **interfaces between services**, not authoritative data types. They define message structures for communication and API contracts.

Your application logic should dictate data types—not proto files. Proto messages are transport representations optimized for serialization.

### Pitfalls of Proto-Centric Design

- **Conflicting imports & type mismatches** across services
- **Code coupling** — proto changes ripple everywhere
- **Unnecessary complexity** — proto dependencies in utility libraries
- **Blurred concerns** — serialization mixed with business logic

### Better Approach

1. Define your own domain structs
2. Convert between internal structs and proto messages at boundaries
3. Keep protos focused on API contracts
4. Never reuse tag numbers

```go
// Wrong — proto-centric
import "github.com/myorg/protos/common"

func GetBlockchainID() common.Blockchain {
    return common.Blockchain_ETH  // Hard-coupled to proto
}

// Right — decoupled
type Blockchain int

const (
    Ethereum Blockchain = 1
    Bitcoin  Blockchain = 2
)

func GetBlockchainID() Blockchain {
    return Ethereum
}

// Convert only at boundaries
func ToProtoBlockchain(b Blockchain) common.Blockchain {
    return common.Blockchain(b)
}
```

Proto files are blueprints for service contracts, not laws governing your codebase.

---

## Infrastructure

### External Connections

Every system making external connections must support:

1. **Rate limits** defaulting to 0 (no limit)
2. **Retries with exponential backoff**
3. **Clear logging**
4. **Metrics:** calls by method, errors, durations, backoff periods
5. **No exit or panic on failed connections** — workloads should self-heal

Kubernetes pods in CrashLoopBackoff due to connection errors is an anti-pattern.

### Retries and Exponential Backoff

Assume whatever you're connecting to may not be there or may not answer. Incorporate retry logic, but endless retries cause further errors. Retries need exponential backoff.

In Kubernetes, pods are mortal. They're expected to run, die, and be replaced. A CrashLoopBackoff is not an error in itself—something stuck in CrashLoopBackoff for too long is.

### GitOps

GitOps is the practice of controlling infrastructure declaratively through Git.

`kubectl apply` and `helm install` are not GitOps. If you're using these commands directly against a cluster, you're manually managing infrastructure and losing the audit trail, reproducibility, and drift correction that GitOps provides.

**Core tenets:**
1. Git is the single source of truth for desired state
2. Changes to Git trigger changes to infrastructure
3. Drift from desired state is automatically corrected
4. Every change is auditable through commit history

### Evaluate Before You Apply

Never apply unevaluated resources to clusters:

```bash
# Avoid
kubectl apply -f https://raw.githubusercontent.com/.../deploy.yaml
helm install my-release some-chart
kubectl apply -k <url>
```

Instead:
1. Download and review manifests locally
2. Use `helm template` to render charts, not `helm install`
3. Understand how each resource affects your security posture
4. Commit evaluated resources to Git
5. Let a GitOps controller like [FluxCD](https://fluxcd.io) apply them

This isn't bureaucracy—it's the difference between knowing what runs in your cluster and hoping for the best.

### Control Repositories

Control repositories contain Infrastructure as Code. VCS provides:
- What change was made
- Who made it
- When it happened
- How to roll back

Code reviews on control repositories can be abbreviated compared to application code. The goal is communication and understanding, not rubber-stamp approvals.

### Kubernetes Resource Management

Four main approaches:
- Bare YAML files
- [Helm](https://helm.sh/)
- [Kustomize](https://kustomize.io/)
- [Jsonnet](https://jsonnet.org/)

You'll encounter all four. Jsonnet is preferred for its flexibility and resistance to blind application. Having everything explicitly laid out in checked-in code makes it easy for humans and AI agents to diagnose and fix problems.

---

## Observability

### Metrics vs Logs

Logs are expensive. Without parsing, they're noise nobody reads.

Metrics are numbers—easy for machines to parse, store, and understand. Expose critical information via metrics:
- Perform actions based on them
- Track changes over time
- Look back during incidents

Logging "all the things, all the time" is unsustainable. Metrics are cheaper.

That said, metrics scale with label cardinality, which is a concern in systems like Prometheus. Logs allow near-infinite cardinality. Some data (like individual requests) is better captured by logs.

Real systems incorporate both.

### Example: WAF Security Logs

WAF logs demonstrate the complementary nature of metrics and logs.

**The problem:** ModSecurity generates structured JSON logs for every blocked request containing client IPs (millions of unique values), request URIs (infinite values), headers, cookies, and attack patterns. Storing this in Prometheus would explode the metrics database.

**Metrics for aggregates:**
```prometheus
rate(modsec_requests_blocked_total[5m])
modsec_blocks_by_type{type="SQLi"}
modsec_blocks_by_type{type="XSS"}
```

**Logs for details:**
- Ship structured logs to Elasticsearch via Filebeat
- Enrich with GeoIP data
- Extract attack types from rule IDs
- Create searchable indices

**Query patterns:**
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

Use metrics for real-time alerting and dashboards. Use logs for forensic analysis. Neither is sufficient alone.

### Prefer Continuous Services to Jobs

Prefer services that run continuously over Jobs and CronJobs.

If you need periodic tasks, code the period into the service with internal timers. This enables easier Prometheus monitoring without PushGateway.

Prometheus was designed to scrape long-running services. Pushing metrics is opposite to its design philosophy and less reliable.

**Services with internal cron-like tasks must:**
- Run once on server start (so "kick off now" means "delete the pod")
- Expose metrics: run counter, failed runs, successful runs, duration gauge

### Document Metrics

The README should be sufficient to set up dashboards and alerts. List all metrics and labels.

---

## Security & Compliance

### Principles

- Security, compliance, and reliability are non-negotiable
- Never share data with third-party vendors without explicit approval
- Access controls and audit trails are critical
- Assume every query is logged and auditable
- Never disable security controls globally
- All security modifications must be minimal and targeted
- Default to read-only operations

### Investigation Methodology

**Don't assume, investigate.**

- Read the actual code—don't pattern-match to common scenarios
- Examine specific code before making suggestions
- Organizations have custom implementations that don't follow typical patterns

**Systematic debugging:**
1. Start with the obvious: recent deployments, known incidents
2. Check metrics for anomalies
3. Correlate with logs
4. Cross-reference with system events
5. Be systematic—don't jump to conclusions
6. Document your investigation path

**For security tool blocks (WAF, etc.):**
1. Query security logs to understand what triggered
2. Identify the rule ID
3. Correlate with the upstream request in application logs
4. Understand the legitimate use case before suggesting rule changes

---

## Documentation

### Requirements

Documentation must:
1. Reside in the repo for the code it describes
2. Be written in Markdown
3. Be accessible via link from knowledge management systems
4. Be stored in top-level `/docs` directory
5. Be renderable in any format from Markdown source
6. Use clear CamelCase naming (e.g., `ServiceArchitecture.md`)

Documentation must not:
1. Be located in multiple places
2. Be stored in formats that can't be easily extracted or re-rendered

### Rendering

Use [pandoc](https://pandoc.org/) to render Markdown:

```bash
pandoc -f markdown -t pdf -o NameOfDoc.pdf <source file>
```

Note: LaTeX is a large dependency.

---

## CI/CD

Every repository should have automated testing, linting, and release management.

### Requirements

Every Go project needs a `.github/workflows/ci.yml` that:

1. Runs tests (`make test`)
2. Runs linting (both `golangci-lint` and `namedreturns`)
3. Caches dependencies (Go modules and Docker layers)
4. Enforces branch protection (tests must pass before merge)
5. Automates releases (tag and publish on main branch)

### Essential Makefile Targets

```makefile
.PHONY: test lint

test:
	go test -v ./... -count=1 --cover

lint:
	@echo "Running namedreturns linter..."
	namedreturns ./...
	@echo "Running golangci-lint..."
	golangci-lint run
```

### Reference Implementation

See [GitHub Actions Reference Implementation](GitHubActionsReference.md) for:
- Automated testing on every push and PR
- Linting with both golangci-lint and namedreturns
- Semantic versioning with automatic tag creation
- Automatic GitHub releases on main branch
- Docker layer and Go module caching
- Proper permissions management

---

## For AI Agents

This section contains instructions for AI coding assistants working with this codebase.

### Communication

- Be direct and technical
- Don't sugar-coat problems
- Assume the user understands the technology
- Skip pleasantries, focus on substance
- If you don't know something, say so clearly

### Constraints

- Don't propose "quick fixes" that bypass established processes
- Don't suggest disabling linters or tests to make code pass
- Don't make assumptions about what's acceptable in production
- Don't auto-apply changes without review
- Don't treat compliance requirements as negotiable
- Don't propose changes requiring manual intervention in production
- Don't commit or push to git without explicit instruction

### Code Changes

- Read existing code before suggesting modifications
- Verify changes comply with the project's golangci-lint configuration
- Always include tests with new functionality
- Add tests proactively, even if not explicitly requested

### Investigation

- Read the actual code—don't pattern-match to common scenarios
- If told to examine specific code, read it first before making suggestions
- Organizations often have custom implementations that don't follow typical patterns

---

Every decision has security, compliance, and reliability implications. When uncertain, err on the side of caution.
