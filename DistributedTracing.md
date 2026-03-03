# Distributed Tracing: A Practical Guide

## What Distributed Tracing Is

Distributed tracing captures the complete journey of a single request as it passes through multiple services. A **trace** is composed of **spans** --- each span represents a discrete unit of work (an HTTP call, a database query, a queue publish). Spans carry a shared **Trace ID** (128-bit, globally unique) and parent-child relationships, so you can reconstruct the full causal chain: "this API call triggered that service call, which triggered that database query, which took 800ms and is why the user saw a 2-second response."

The mechanism is **context propagation** --- trace context (Trace ID, Span ID, sampling flags) travels across service boundaries via HTTP headers (`traceparent` / W3C Trace Context standard), gRPC metadata, or message queue headers.

### What It Does

- **Latency analysis**: Which service or operation is the bottleneck in a multi-service request
- **Error propagation**: Where an error originated and how it cascaded through services
- **Dependency mapping**: Which services call which, and how deeply
- **Root cause analysis**: From "something is slow" to "this specific database query in service X is slow when called by service Y"

### What It Does Not Do Well

- **Aggregate system health** --- metrics are better for "is the system healthy right now?"
- **Deep context on a single event** --- logs are better for "what exactly went wrong in this function?"
- **Long-running processes** --- traces are designed for request/response patterns; batch jobs and stream processing are awkward to model
- **Complete coverage** --- in practice, not every service is instrumented, not every library supports propagation, gaps in traces are common
- **Business analytics** --- traces capture technical operations, not business events

### The Sampling Problem

This is the fundamental tension. Capturing every request is not feasible at scale (Alibaba generates ~20 PB of trace data per day). So you sample, and every sampling strategy has tradeoffs:

- **Head-based sampling** (decide at entry): Simple, low-overhead, but the decision is made before knowing if the request will be interesting. Errors and anomalies in the unsampled majority are invisible.
- **Tail-based sampling** (decide after trace completes): Can keep all errors and slow traces. But requires buffering all spans in memory before the decision --- expensive, and hard to determine when a trace is "complete" since spans arrive out of order.

The paradox: the traces you most need to see (errors, rare edge cases) are exactly the ones most likely to be dropped by sampling.

---

## Tracing vs Metrics vs Logs vs Events

| Signal | Question | Data Type | Cost | Best For |
|--------|----------|-----------|------|----------|
| **Metrics** | *What* is happening? | Numeric, aggregated | Low | Alerting, dashboards, SLOs, capacity planning |
| **Logs** | *Why* did it happen? | Text/structured records | High | Detailed debugging, audit trails, compliance |
| **Traces** | *Where* did it happen? | Spans & relationships | Medium | Cross-service latency, dependency mapping, error propagation |
| **Events** | *What changed?* | Structured occurrences | Varies | Deployment tracking, config changes, incident correlation |

The diagnostic workflow: **Metrics** surface the symptom (error rate spike). **Traces** narrow it to a specific operation (the database call in service X). **Logs** explain why (the specific SQL error, the malformed input). **Events** provide context (a deployment happened 5 minutes before the spike).

None is sufficient alone. Correlation across all four is the goal. OpenTelemetry unifies the first three under one framework with shared context (Trace ID, resource attributes). The Grafana stack (Loki + Tempo + Mimir + Grafana) and Datadog both implement cross-signal correlation in the UI.

---

## How Traces Get Produced

Traces don't appear by magic. Something has to produce the spans, and something has to collect them. There are three levels of instrumentation, each producing spans at different depths.

### Level 1: Infrastructure (Mesh/Proxy)

Service meshes like Istio use Envoy sidecar proxies that sit in the data path and generate spans for every network hop. Entry/exit spans at service boundaries --- HTTP method, status code, latency, upstream/downstream service names. No code changes required.

But Envoy is a proxy. It sees network traffic. It does not see what happens inside the application between receiving a request and sending one out. It observes the envelope, not the letter.

**Critical caveat**: Envoy generates spans per hop, but it cannot correlate an outbound request to the inbound request that caused it. The application must propagate trace headers from incoming to outgoing requests. Without this, you get isolated per-hop spans, not connected end-to-end traces. This is the single most common problem teams encounter when setting up tracing in a service mesh.

### Level 2: Auto-Instrumentation (OTel SDK, Zero-Code)

OpenTelemetry provides auto-instrumentation agents that hook into well-known frameworks and libraries at runtime. In Java, it's a `-javaagent` JVM flag. In Python, it's `opentelemetry-instrument` wrapping the process. In Go, it's compile-time instrumentation libraries (Go doesn't have a runtime agent model).

What auto-instrumentation captures depends on the language and libraries in use, but typically:

- **HTTP servers/clients** (net/http, Express, Spring, Flask) --- spans for every inbound and outbound HTTP request
- **gRPC** --- spans for every RPC call
- **Database drivers** (JDBC, pgx, database/sql) --- spans for every query, including the SQL statement
- **Message queues** (Kafka producers/consumers, RabbitMQ) --- spans for publish and consume, with context propagation through message headers
- **Redis, Memcached** --- spans for cache operations
- **AWS SDK calls** --- spans for S3, DynamoDB, SQS, etc.

This is where most of the practical value comes from. Auto-instrumentation covers the common I/O boundaries without touching application code. It also handles **context propagation** automatically --- the trace headers get forwarded from incoming to outgoing requests, which is exactly what the mesh layer alone does not do.

### Level 3: Manual Instrumentation (Custom Spans)

For anything auto-instrumentation doesn't cover --- business logic, internal algorithms, conditional branches, custom processing steps --- there's code to write:

```go
ctx, span := tracer.Start(ctx, "processOrder",
    trace.WithAttributes(
        attribute.String("order.id", orderID),
        attribute.Int("order.items", len(items)),
    ),
)
defer span.End()

// ... business logic ...

if err != nil {
    span.RecordError(err)
    span.SetStatus(codes.Error, "order processing failed")
}
```

This is the only way to get:
- Business context (order ID, user ID, tenant ID) as span attributes
- Visibility into application-internal operations
- Custom error recording with domain-specific detail
- Spans around logic that doesn't touch I/O (validation, transformation, computation)

### The Practical Stack

In most production setups, all three layers combine:

```
[Mesh/Proxy spans]     ← Envoy, service boundary, automatic
        +
[Auto-instrumented]    ← OTel SDK, library-level I/O, near-automatic
        +
[Manual spans]         ← Application code, business logic, requires effort
        =
[Complete trace]       ← The full picture from ingress to database and back
```

| Level | Effort | Coverage |
|-------|--------|----------|
| Mesh only (Envoy) | Zero code changes | Service boundary hops only. No internal visibility. Broken traces without header propagation. |
| Auto-instrumentation | SDK dependency + agent flag + env vars | HTTP, gRPC, database, cache, queue spans. Header propagation handled. Solid coverage for most services. |
| Manual instrumentation | Code per operation | Business logic, custom attributes, full internal visibility. The only way to get domain-specific context. |

Most teams start with auto-instrumentation (80% of the value for 5% of the effort) and add manual spans selectively where deeper visibility is needed.

---

## How Traces Get Collected

Once spans are produced, they need to reach a backend. The collection pipeline:

```
Application (OTel SDK)
      │
      │ OTLP (gRPC :4317 or HTTP :4318)
      ▼
OTel Collector (agent mode, DaemonSet or sidecar)
      │
      │ batch, filter, enrich (add k8s metadata, etc.)
      ▼
OTel Collector (gateway mode, optional)
      │
      │ tail sampling, routing, fan-out
      ▼
Backend (Tempo, Jaeger, Datadog, etc.)
```

### Export from the Application

The OTel SDK batches completed spans in memory and exports them periodically (default: every 5 seconds or when the batch hits 512 spans). The export target is configured via environment variables:

```
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
OTEL_SERVICE_NAME=checkout-service
OTEL_RESOURCE_ATTRIBUTES=k8s.namespace.name=prod,k8s.pod.name=$(POD_NAME)
```

The SDK handles batching, retry on failure, and back-pressure (drops spans if the export queue is full, rather than blocking the application).

### Collector Agent (DaemonSet)

In Kubernetes, the typical pattern is an OTel Collector DaemonSet --- one per node. Every pod on that node exports to the local collector. The agent:

- Receives spans over OTLP
- Enriches them with Kubernetes metadata (pod name, namespace, node, labels) via the `k8sattributes` processor
- Batches for efficient network transfer
- Applies memory limits to prevent OOM
- Forwards to a gateway or directly to the backend

### Collector Gateway (Optional)

For larger deployments, a centralized gateway collector handles:

- **Tail-based sampling** --- must happen centrally because it needs to see the complete trace before deciding whether to keep it, and spans from different services land on different agent nodes
- **Routing** --- send traces to Tempo, metrics to Mimir, logs to Loki
- **Fan-out** --- send to multiple backends simultaneously (e.g., Tempo for storage + a real-time analytics pipeline)

### Backend Ingestion

The backend receives spans over OTLP and writes them to storage. From here it's the backend's problem --- Tempo writes Parquet blocks to S3, Jaeger indexes into Elasticsearch, etc.

In a service mesh deployment, the Envoy sidecar acts as its own span producer and exports spans directly to the tracing backend without going through the application's OTel SDK. The application's SDK-produced spans and Envoy's proxy-produced spans share the same Trace ID (assuming header propagation is working), so the backend stitches them together into one trace.

---

## OpenTelemetry (OTel)

The de facto industry standard as of 2025. Second most active CNCF project after Kubernetes. All three core signals (traces, metrics, logs) are now stable. Semantic Conventions 1.0 shipped in 2025, standardizing attribute names across all languages and exporters.

### Signal Maturity

| Signal | Status | Notes |
|--------|--------|-------|
| **Traces** | Stable | SDKs are v1.0+ across major languages |
| **Metrics** | Stable | Data model released as part of OTLP |
| **Logs** | Stable | Log Bridge API for existing frameworks |
| **Profiling** | In Development | Will support bi-directional links with traces/metrics/logs |

### Key Components

- **SDKs** for 12+ languages (Java, Go, Python, JavaScript/TypeScript, .NET, Rust, C++, Ruby, PHP, Swift, Kotlin, Erlang) with auto-instrumentation for common frameworks
- **OTLP protocol** (gRPC/HTTP + protobuf) --- the standard wire format everything speaks
- **Collector** --- vendor-agnostic pipeline: Receivers → Processors → Exporters

### Collector Architecture

```
[Receivers] --> [Processors] --> [Exporters]
```

**Receivers** (data ingress): OTLP (gRPC/HTTP), Prometheus scrape, Kafka, Jaeger, Zipkin, Fluent Forward, and many more.

**Processors** (transformation): Batch (groups telemetry for efficient export), Memory Limiter (prevents OOM), Attributes (add/modify/delete span attributes), Filter (drop unwanted data), Tail Sampling (sampling decisions after seeing complete traces).

**Exporters** (data egress): OTLP (to any compatible backend), Prometheus Remote Write, Debug (stdout), plus backend-specific exporters for Jaeger, Zipkin, Datadog, New Relic, etc.

The instrumentation layer is settled. The choice is in the backend.

---

## Jaeger

### History and Current State

Open-sourced by Uber in 2015, CNCF graduated project. **Jaeger v2** shipped November 2024 (current: v2.13). Jaeger v1 reaches end-of-life December 31, 2025.

### The v2 Rewrite

The defining change: Jaeger v2 is built **on top of the OpenTelemetry Collector framework**. The Jaeger binary directly imports OTel Collector code as a library. It's not a fork --- it's a customized OTel Collector distribution with Jaeger's storage backends and UI.

What this means practically:
- **Single binary** replaces multiple v1 binaries (collector, agent, query, ingester)
- Configured via OTel Collector YAML format
- Natively processes OTLP --- no translation step
- Gets tail-based sampling, batch processing, filtering, and every other OTel Collector processor for free
- A separate OTel Collector in front of Jaeger is no longer necessary (though it can still be used)

### Deployment Roles

The single binary runs in different roles:
- **Collector**: Receives trace data, writes to storage
- **Query**: Serves APIs and the Jaeger UI for querying/visualizing traces
- **Ingester**: Consumes from Kafka, writes to storage
- **All-in-one**: Collector + Query in a single process (development/testing)

### Storage Backends

| Backend | Notes |
|---------|-------|
| **Elasticsearch 7.x/8.x** | Best query performance. Recommended for most deployments. |
| **OpenSearch 1.0+** | Drop-in Elasticsearch alternative |
| **Cassandra 4.0+** | Good for write-heavy workloads, limited analytics |
| **ClickHouse** | Becoming first-class. Column-oriented, superior for analytics on trace data. |
| **Kafka** | Buffering layer for durability and spike absorption, not storage itself |

### Strengths

- Mature, battle-tested at Uber scale
- Built-in UI for trace visualization
- Rich indexed queries (search by service, operation, tags, duration)
- Fully aligned with OTel --- no more divergent instrumentation formats

### Weaknesses

- **Operational cost**: Running Elasticsearch or Cassandra clusters is non-trivial
- Storage backends require their own capacity planning, scaling, and backup
- Indexing everything is expensive --- pushes teams toward aggressive sampling (1-10%)

---

## Grafana Tempo

### Philosophy

Fundamentally different design from Jaeger: **no indexing, object storage only**.

Tempo stores traces as Parquet blocks in S3/GCS/Azure Blob. No Elasticsearch. No Cassandra. No database to operate. Object storage is cheap enough to store **100% of traces** without sampling.

### Architecture

- **Distributor**: Accepts spans (OTLP, Jaeger, Zipkin protocols), routes to ingesters via consistent hash ring
- **Ingester**: Buffers spans, builds Parquet blocks, flushes to object storage
- **Querier**: Looks up traces in ingesters (recent) or object storage (historical)
- **Query Frontend**: Splits queries across queriers for parallelism
- **Compactor**: Compresses, deduplicates, expires blocks

### Storage Backends

- Amazon S3
- Google Cloud Storage (GCS)
- Azure Blob Storage
- MinIO (S3-compatible)
- Local filesystem (development only)

### TraceQL

Originally Tempo was trace-ID-lookup only --- finding a trace required knowing its ID, which meant discovering traces through correlated logs (Loki) or metric exemplars (Prometheus/Mimir).

That's no longer the case. **TraceQL** is Tempo's query language:

```
{ span.http.status_code = 500 }
{ span.http.method = "GET" && duration > 2s }
{ resource.service.name = "checkout" && span.db.system = "postgresql" }
```

**TraceQL Metrics** (public preview) can create aggregate metrics from traces, similar to how LogQL creates metrics from logs.

### Current Versions

- **Tempo 2.8** (June 2025): New TraceQL functions, memory optimizations
- **Tempo 2.9** (October 2025): MCP server support (LLMs can query traces via TraceQL), TraceQL metrics sampling

### The Grafana Stack Integration

Tempo's real power is in the integrated stack:
- **Loki** (logs) → find trace IDs in log lines → jump to trace in Tempo
- **Tempo** (traces) → span-level detail, TraceQL queries
- **Mimir/Prometheus** (metrics) → exemplars link directly to trace IDs → jump to trace
- **Grafana** → unified UI correlating all three signals

---

## Jaeger vs Tempo: Head to Head

| | Jaeger | Tempo |
|---|---|---|
| **Storage** | Elasticsearch, Cassandra, ClickHouse | Object storage (S3, GCS, Azure) |
| **Indexing** | Full indexing | No traditional indexing; Parquet blocks |
| **Sampling** | Typically 1-10% (storage cost pressure) | Designed for 100% (storage is cheap) |
| **Query** | Rich indexed search from day one | TraceQL (newer, catching up) |
| **UI** | Built-in Jaeger UI | Grafana |
| **Operational burden** | Higher (database clusters to manage) | Lower (object storage, no indexes) |
| **Ecosystem** | Standalone / OTel | Deep Grafana stack integration |
| **Cost at scale** | Higher (indexed storage is expensive) | Lower (object storage is cheap) |

**Migration trend**: Red Hat published Jaeger-to-Tempo migration guidance in April 2025 as OpenShift deprecated the Jaeger-based tracing platform. Both accept OTLP, so the data pipeline doesn't change --- only the backend.

---

## Istio / Service Mesh Integration

Service meshes provide tracing with near-zero application changes, but the coverage has important limits.

### What the Mesh Provides Automatically

- Envoy sidecars generate spans for every inbound/outbound request at the service boundary
- Latency measurement per hop
- Service dependency graph
- Sampling rate controlled via Telemetry API (default 1%)

### What Requires Manual Work

- **End-to-end trace correlation** --- Envoy generates spans per hop, but cannot correlate an outbound request to the inbound request that caused it. The application must propagate trace headers (`traceparent`/`tracestate` for W3C, or `x-b3-*` for B3 format) from incoming to outgoing requests. Without this, traces appear as disconnected per-hop spans.
- **Application-internal spans** --- anything inside the code (function calls, business logic) requires SDK instrumentation
- **Database/cache query tracing** --- requires library-level instrumentation
- **Business context** (user ID, order ID) --- requires custom span attributes via SDK

| Capability | Automatic (mesh) | Manual (application) |
|------------|-------------------|----------------------|
| Span generation at service boundary | Yes | --- |
| Latency measurement per hop | Yes | --- |
| Service dependency graph | Yes | --- |
| End-to-end trace correlation | No | Header propagation required |
| Application-internal spans | No | Full SDK instrumentation |
| Business context attributes | No | Custom attributes via SDK |
| Database query tracing | No | Library instrumentation |

The recommended approach for header propagation is OTel SDK auto-instrumentation, which handles it transparently. The alternative is manual middleware that copies headers from incoming to outgoing requests.

---

## Other Tracing Systems

- **Zipkin**: The original (Twitter, 2012). Simple, lightweight. Its B3 propagation format was the standard before W3C Trace Context. Hasn't evolved for modern scale. Increasingly superseded by Jaeger and Tempo.
- **AWS X-Ray**: Managed service, deep AWS integration (Lambda, ECS, API Gateway). Good for AWS-only shops. Limited outside the ecosystem. Supports OTel for instrumentation.
- **Datadog APM**: Commercial SaaS. Automatic instrumentation, AI anomaly detection (Watchdog), tightly integrated traces/logs/metrics. Pricing escalates fast (~$31/host/month + per-GB ingestion charges).
- **Honeycomb**: Purpose-built for high-cardinality trace debugging. "BubbleUp" feature for automatic anomaly detection. OTel-native. Best for teams that prioritize deep trace-based debugging over breadth.
- **Lightstep / ServiceNow Cloud Observability**: Founded by OTel co-creators, acquired by ServiceNow. ServiceNow announced EOL for Lightstep in 2025. Teams are migrating to Grafana stack, Honeycomb, or SigNoz.
