---
title: 'Prometheus and OpenTelemetry: How They Fit Together'
excerpt: OpenTelemetry does not replace Prometheus. They solve different problems, they are converging, and understanding the boundary between them will save you from expensive architectural mistakes.
publishDate: 'Mar 03 2026'
tags:
  - Observability
  - Prometheus
  - OpenTelemetry
isFeatured: false
---

People keep asking whether OpenTelemetry replaces Prometheus. The short answer is no. The longer answer is that they solve different problems, they're converging, and understanding the boundary between them will save you from making expensive architectural mistakes.

## What Each One Actually Is

**Prometheus** is a metrics system. It scrapes numeric time-series data from targets, stores it in a local TSDB, provides PromQL for querying, and fires alerts via Alertmanager. It is the de facto standard for Kubernetes monitoring. If you're running workloads on Kubernetes and you're not using Prometheus, you're either using something that wraps Prometheus or you're doing it wrong.

**OpenTelemetry (OTel)** is an instrumentation and telemetry pipeline framework. It defines APIs, SDKs, and a Collector for producing, transforming, and routing telemetry data --- traces, metrics, and logs. It doesn't store anything. It doesn't query anything. It doesn't alert on anything. It's the plumbing between your applications and whatever backend you choose.

The confusion comes from the fact that OTel handles metrics. But "handles metrics" and "is a metrics system" are different things. OTel produces and transports metrics. Prometheus stores, queries, and alerts on them. They're complementary layers in the same pipeline.

## The Architecture

Here's how they fit in a typical Kubernetes deployment:

```
Application (OTel SDK)
      │
      │  OTLP (gRPC :4317)
      ▼
OTel Collector
      │
      ├──→ Prometheus Remote Write ──→ Prometheus/Thanos ──→ PromQL, Alerts, Grafana
      ├──→ OTLP ──→ Tempo (traces)
      └──→ OTLP ──→ Loki (logs)
```

OTel is the fan-out layer. It collects all three signals from your applications through a single SDK and routes each signal to the appropriate backend. Prometheus remains the metrics backend. Tempo or Jaeger handles traces. Loki handles logs.

The alternative --- and what most teams start with --- is Prometheus scraping metrics directly:

```
Application (/metrics endpoint)
      │
      │  HTTP scrape (pull)
      ▼
Prometheus ──→ PromQL, Alerts, Grafana
```

Both work. The question is when you need to move from one to the other.

## Pull vs Push: The Fundamental Difference

Prometheus uses a **pull model**. It reaches out to your services on a schedule and scrapes their `/metrics` endpoint. The service exposes metrics in Prometheus exposition format, Prometheus collects them.

OTel uses a **push model**. Your application pushes telemetry to the OTel Collector (or directly to a backend) via OTLP. The application decides when to send data.

Both models have tradeoffs:

| | Pull (Prometheus) | Push (OTel) |
|---|---|---|
| **Service discovery** | Prometheus must know where your targets are (Kubernetes SD, DNS, static config) | Application pushes to a known Collector endpoint |
| **Firewall friendliness** | Prometheus must be able to reach every target | Only outbound traffic from the application |
| **Short-lived jobs** | Awkward --- the job may finish before the next scrape. Requires Pushgateway. | Natural --- the SDK pushes before the process exits |
| **Back-pressure** | Implicit --- if Prometheus is slow, it just scrapes less often | Explicit --- the SDK queues, retries, and drops under pressure |
| **Health signal** | A failed scrape is itself a signal ("target is down") | Absence of data is ambiguous ("is the app down or is the Collector down?") |
| **Cardinality control** | At the source --- the `/metrics` endpoint defines what's exposed | At the Collector --- processors can drop or aggregate before export |

The pull model's best feature is that it doubles as a health check. If Prometheus can't scrape a target, that's an alert in itself. The push model's best feature is that it works for everything --- including short-lived batch jobs, serverless functions, and environments where inbound connections are restricted.

## Where Prometheus Wins

### PromQL

There is no OTel equivalent to PromQL. OTel doesn't have a query language because it's not a query system. Whatever backend you send OTel metrics to needs its own query capability.

PromQL is expressive, well-documented, and understood by every SRE on the planet. Rate calculations, histogram quantiles, aggregation across label dimensions, subqueries --- it's a purpose-built language for time-series analysis.

```promql
# Request rate per service over 5 minutes
sum(rate(http_requests_total[5m])) by (service)

# 99th percentile latency from histograms
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))

# Error rate as a percentage
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100
```

### Alertmanager

Prometheus alerting via Alertmanager is mature, battle-tested, and well-integrated with every incident response platform. Alert routing, silencing, grouping, inhibition --- it's all there and it works.

OTel has no alerting mechanism. It's not designed to have one. You still need Prometheus (or a commercial backend) to evaluate alert rules against your metrics.

### The Kubernetes Ecosystem

Every Kubernetes component exposes a Prometheus metrics endpoint natively. The kubelet, kube-apiserver, etcd, CoreDNS, Flux, cert-manager, ingress controllers --- all of them. Service meshes like Istio expose Envoy metrics in Prometheus format. Operators like CloudNativePG and Strimzi expose their own Prometheus metrics.

This is not going to change. The `/metrics` endpoint is the universal interface for Kubernetes infrastructure metrics.

### Long-Term Storage with Thanos

Prometheus's local TSDB has a retention limit. For production environments, you need long-term storage and cross-cluster querying. Thanos solves this:

```
Prometheus (cluster A)  ──→  Thanos Sidecar  ──→  Object Storage (S3)
Prometheus (cluster B)  ──→  Thanos Sidecar  ──→  Object Storage (S3)
                                                          │
                                                    Thanos Query
                                                          │
                                                       Grafana
```

Thanos Query provides a unified PromQL interface across multiple Prometheus instances and long-term storage. You get global view, deduplication, and downsampling --- all while each Prometheus instance remains independent and local to its cluster.

I run this in production across multiple clusters. Each cluster has its own Prometheus with a Thanos sidecar that ships blocks to S3. Thanos Query federates across all of them, giving a single pane of glass without requiring any cluster to know about the others. The Prometheus instances are fully autonomous --- if Thanos goes down, each cluster still has local metrics and alerting.

This architecture is hard to beat for reliability. Each component fails independently and degrades gracefully.

## Where OpenTelemetry Wins

### Unified Instrumentation

Without OTel, you instrument for metrics with a Prometheus client library, for traces with a Jaeger or Tempo SDK, and for logs with whatever logging framework your language uses. Three separate instrumentation paths. Three sets of libraries. Three configuration mechanisms.

With OTel, you instrument once. The SDK produces all three signals from a single integration point. A traced HTTP request automatically generates a span, a duration metric, and a structured log entry --- all sharing the same context (trace ID, service name, resource attributes).

```go
// One SDK, three signals
import "go.opentelemetry.io/otel"

// Traces
tracer := otel.Tracer("my-service")
ctx, span := tracer.Start(ctx, "handleRequest")
defer span.End()

// Metrics
meter := otel.Meter("my-service")
counter, _ := meter.Int64Counter("http.requests")
counter.Add(ctx, 1, metric.WithAttributes(
    attribute.String("method", "GET"),
    attribute.Int("status", 200),
))
```

The trace and the metric share context. You can link a metric spike to the exact traces that caused it. That correlation is OTel's killer feature.

### Vendor Neutrality

OTel Collector sits between your applications and your backends. Change your mind about where metrics go? Reconfigure the Collector. No application changes.

```yaml
exporters:
  prometheusremotewrite:
    endpoint: "http://prometheus:9090/api/v1/write"
  otlp/tempo:
    endpoint: "tempo:4317"
  loki:
    endpoint: "http://loki:3100/loki/api/v1/push"

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch, memory_limiter]
      exporters: [prometheusremotewrite]
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp/tempo]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [loki]
```

Swap Prometheus for Datadog? Change one exporter. Send metrics to two backends simultaneously? Add another exporter to the pipeline. The instrumentation layer is stable; the routing layer is flexible.

### The Collector as a Processing Pipeline

The OTel Collector isn't just a forwarder. It's a programmable processing pipeline:

- **Batch processor** --- groups telemetry for efficient network transfer
- **Memory limiter** --- prevents the Collector from OOM-ing under load
- **Attributes processor** --- add, modify, or delete metric labels before they reach the backend
- **Filter processor** --- drop metrics you don't want (cardinality control before storage)
- **Transform processor** --- rename metrics, convert types, compute derived values
- **k8sattributes processor** --- enrich metrics with Kubernetes metadata (pod, namespace, node, labels)

This processing pipeline is particularly valuable for cardinality management. High-cardinality labels are the number one cause of Prometheus performance problems. With the Collector, you can drop or aggregate high-cardinality dimensions before they ever hit Prometheus, without changing application code.

## The Convergence

Prometheus and OTel are actively converging. This isn't speculation --- it's happening in the codebases right now.

### Prometheus OTLP Ingestion

Since Prometheus 2.47, there's experimental support for receiving metrics via OTLP. This means OTel can push metrics directly to Prometheus without the remote write detour:

```
Application ──→ OTel Collector ──→ OTLP ──→ Prometheus
```

The feature is still maturing (UTF-8 metric name handling, delta-to-cumulative conversion), but the direction is clear: Prometheus is becoming an OTLP-native backend.

### OTel Prometheus Receiver

The OTel Collector has a Prometheus receiver that implements a full Prometheus scrape client. It can scrape existing `/metrics` endpoints and convert them to OTLP:

```yaml
receivers:
  prometheus:
    config:
      scrape_configs:
        - job_name: 'kubernetes-pods'
          kubernetes_sd_configs:
            - role: pod
```

This is useful for bridging --- you can route scraped Prometheus metrics through the OTel pipeline for processing before sending them to a backend.

### Shared Metric Types

OTel's metric data model was designed to be compatible with Prometheus. Counters, gauges, and histograms map directly between the two systems. OTel's exponential histograms map to Prometheus native histograms (an active area of development in Prometheus).

### Exemplars

Both systems support exemplars --- links from a metric data point to a specific trace. A spike in error rate can link directly to the traces that caused it. This is the bridge between metrics ("something is wrong") and traces ("here's exactly what went wrong").

```promql
# Query with exemplars in Grafana
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
```

In Grafana, clicking an exemplar on a Prometheus graph jumps directly to the associated trace in Tempo. This cross-signal correlation is where the Prometheus + OTel + Tempo stack becomes more than the sum of its parts.

## Prometheus as Producer vs Prometheus as Destination

This is the thing that confuses people, because Prometheus plays both roles depending on where you're looking.

### Prometheus as Destination (The Common Case)

In this role, Prometheus is the **backend** --- the place where metrics land, get stored, get queried, and get alerted on. Something else produces the metrics. Prometheus consumes them.

```
[Your application]  ──exposes /metrics──→  [Prometheus scrapes it]  ──stores──→  [TSDB]
[OTel Collector]    ──remote write────→  [Prometheus receives it]  ──stores──→  [TSDB]
[OTel Collector]    ──OTLP push──────→  [Prometheus receives it]  ──stores──→  [TSDB]
```

In all three cases, Prometheus is the destination. It's the database. The metrics originate in your applications (via Prometheus client libraries or OTel SDKs) and Prometheus is where they end up.

This is Prometheus's primary role in most architectures.

### Prometheus as Producer (The Federation / Export Case)

In this role, Prometheus is the **source** --- it has metrics, and something else reads from it.

**Scenario 1: Thanos / Long-Term Storage**

```
[Prometheus]  ──Thanos Sidecar reads blocks──→  [S3 Object Storage]
                                                        │
                                                  [Thanos Query]  ──serves PromQL──→  [Grafana]
```

Prometheus produces the TSDB blocks. Thanos Sidecar uploads them to object storage. In this relationship, Prometheus is the data producer --- Thanos is consuming what Prometheus wrote.

**Scenario 2: Federation**

```
[Prometheus (cluster A)]  ──exposes /federate──→  [Prometheus (global) scrapes it]
[Prometheus (cluster B)]  ──exposes /federate──→  [Prometheus (global) scrapes it]
```

A global Prometheus scrapes selected metrics from cluster-level Prometheus instances. The cluster-level Prometheus instances are producers; the global instance is the destination. This is the older pattern that Thanos largely replaced.

**Scenario 3: OTel Collector Scraping Prometheus**

```
[Prometheus]  ──exposes /metrics or /federate──→  [OTel Collector scrapes it]  ──routes──→  [Other Backend]
```

The OTel Collector's Prometheus receiver can scrape Prometheus itself (or any `/metrics` endpoint). This is useful when migrating away from a direct-scrape architecture --- the Collector becomes the intermediary, and Prometheus is just another scrape target.

**Scenario 4: Remote Read**

```
[Prometheus]  ──remote read API──→  [Grafana or another system queries it]
```

Grafana queries Prometheus via its remote read API. Prometheus is the data source. This is the most common "producer" role --- Prometheus serves query results to dashboards and alerting systems.

### The Mental Model

Think of Prometheus as a **database with a built-in ETL**:

- **As destination**: Prometheus's built-in scraper (the ETL) pulls data from your services and writes it to the TSDB (the database). Or external systems push to it via remote write / OTLP.
- **As producer**: Other systems read from the TSDB --- via PromQL API (Grafana), Thanos Sidecar (long-term storage), federation (another Prometheus), or OTel Collector (re-routing).

The confusion arises because most databases don't have a built-in data collection mechanism. PostgreSQL doesn't go out and scrape your applications for data. Prometheus does. So people conflate "Prometheus the scraper" with "Prometheus the database" when they're really two different functions that happen to live in the same binary.

When people say "OTel replaces Prometheus," they mean OTel replaces **the scraper role** --- the data collection and transport. Prometheus-the-database (TSDB + PromQL + Alertmanager) is not being replaced by anything in the OTel ecosystem.

## When to Use What

### Prometheus-Only (No OTel)

Use this when:

- Your stack is entirely Kubernetes infrastructure (no custom application instrumentation)
- You only need metrics, not traces or logs through a unified pipeline
- You're a small team and operational simplicity matters more than flexibility
- You're scraping well-known exporters (node-exporter, kube-state-metrics, etc.)

This is a perfectly valid architecture. Prometheus with Thanos for long-term storage and Grafana for visualization covers a huge amount of ground. Don't add OTel complexity if you don't need it.

### OTel for Applications, Prometheus for Infrastructure

The pragmatic middle ground:

- Kubernetes components and infrastructure exporters continue to expose `/metrics` endpoints --- Prometheus scrapes them directly
- Your own applications instrument with the OTel SDK --- metrics, traces, and logs flow through the OTel Collector
- The Collector sends metrics to Prometheus via remote write, traces to Tempo, logs to Loki
- Prometheus handles alerting and PromQL for everything

This gives you unified application instrumentation and cross-signal correlation without disrupting the infrastructure monitoring that already works.

### Full OTel Pipeline

Use this when:

- You need vendor flexibility (today Prometheus, tomorrow maybe something else)
- You want centralized cardinality management via the Collector
- You're running a large multi-cluster environment and want a single telemetry pipeline
- You're standardizing instrumentation across multiple languages and teams

Even in this case, Prometheus (or a Prometheus-compatible backend like Thanos or Mimir) is likely the metrics destination. OTel replaces the transport and instrumentation layer, not the storage and query layer.

## The Migration Path

Most organizations follow this trajectory:

1. **Start with Prometheus** --- scrape infrastructure metrics, set up Grafana dashboards and alerts. This is where everyone begins and where many teams stay indefinitely.

2. **Add Thanos or Mimir** --- when you need long-term storage, cross-cluster queries, or high availability for Prometheus itself.

3. **Introduce OTel for new applications** --- when you start building services that need tracing alongside metrics. Instrument with the OTel SDK, route metrics to Prometheus and traces to Tempo.

4. **Migrate existing applications gradually** --- swap Prometheus client libraries for OTel SDK. The metrics still end up in Prometheus; the instrumentation is just unified now.

5. **Use the Collector as the universal pipeline** --- centralize processing, filtering, and routing. Prometheus still handles metrics; the Collector handles everything upstream of it.

At no point do you remove Prometheus. You layer OTel in front of it. Prometheus becomes one backend in a multi-signal pipeline rather than the only tool in the stack.

## The Practical Takeaway

Prometheus is not going away. PromQL is not being replaced. Alertmanager is not being superseded. The Kubernetes ecosystem's native metrics format is not changing.

OpenTelemetry is not replacing Prometheus. It's replacing the fragmented, per-vendor instrumentation libraries that came before it. It's standardizing how telemetry gets produced and transported. The destination --- for metrics, at least --- is still Prometheus.

Think of it this way: Prometheus is the database. OTel is the ETL pipeline. You might run the database without the pipeline (Prometheus scraping directly). You will not run the pipeline without the database.
