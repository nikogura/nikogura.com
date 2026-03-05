# Metrics, Logs, Traces, and Events: What's Actually Different

Four words that get thrown around interchangeably in observability conversations. They're not the same thing, but the boundaries are blurrier than most documentation admits. Understanding what makes each one distinct --- and where they overlap --- determines whether your observability stack scales or collapses under its own weight.

## The Short Version

| Signal | What it is | Indexed by | Query pattern | Cardinality concern |
|--------|-----------|-----------|---------------|-------------------|
| **Metrics** | Pre-aggregated numbers | Label dimensions | Aggregate over time | Labels (dimensions) |
| **Logs** | Timestamped text records | Time + labels + content | Search/filter individual records | Volume (bytes/sec) and label cardinality |
| **Traces** | Causal graphs of requests across services | Trace ID + span relationships | Retrieve call trees, find bottlenecks | Span volume per request |
| **Events** | Discrete state changes | Time + object + reason | Filter by type and object | Volume (count/sec) |

## Metrics

A metric is a numeric measurement at a point in time, pre-aggregated into named dimensions. You define the dimensions (labels) up front, and every data point gets bucketed into those dimensions before it hits storage.

```promql
# This is a metric: a counter with three label dimensions
http_requests_total{service="api-gateway", method="GET", status="200"} 148293
```

When you query metrics, you're asking aggregate questions:

```promql
# What's the request rate per service over 5 minutes?
sum(rate(http_requests_total[5m])) by (service)

# What's the 99th percentile latency?
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))

# What percentage of requests are errors?
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100
```

You never see an individual request. The power is in the aggregation. The tradeoff is that you've already thrown away the individual events before they hit storage. You know *that* 2% of requests to the payment service are failing. You don't know *which* requests, or *why*.

### How Prometheus stores metrics

Prometheus scrapes a `/metrics` endpoint on a schedule (typically every 15-30 seconds) and writes the samples to a local time-series database (TSDB). Each unique combination of metric name + label values is a **time series**. The TSDB is append-only and optimized for sequential writes and range queries over time.

For long-term storage and cross-cluster querying, Thanos extends Prometheus by shipping TSDB blocks to object storage (S3) and providing a unified PromQL interface across multiple Prometheus instances.

```
Application (/metrics) ──scrape──→ Prometheus (TSDB) ──sidecar──→ S3 ──→ Thanos Query ──→ Grafana
```

### Where metrics break down

Metrics answer "what" and "how much." They don't answer "why" or "which one." When the error rate spikes, metrics tell you it's happening. They don't tell you which user, which request payload, or which downstream dependency caused it.

## Logs

A log is a timestamped text record of something that happened. Each line is an independent event --- a request was received, a query was executed, an error was thrown, a connection was established.

```json
{"timestamp":"2025-03-03T14:23:01Z","level":"error","service":"order-service","msg":"order processing failed","orderId":"ord-4821","reason":"payment declined","error":"insufficient funds","traceId":"abc123def456"}
```

When you query logs, you're searching for individual records:

```logql
# All error logs from order-service in the last hour
{service="order-service"} |= "error" | json | level = "error"

# Logs for a specific order
{service="order-service"} |= "ord-4821"

# Error rate derived from logs (yes, you can do this, but metrics do it better)
sum(rate({service="order-service"} |= "error" [5m]))
```

Each line stands alone. You can correlate logs from different services if they share a request ID or trace ID, but the log system doesn't enforce or index that relationship. You're doing a text search across independent records that happen to contain the same string.

### How Loki stores logs

Loki is deliberately *not* a full-text search engine. It indexes logs by **label** (service, namespace, pod) but does **not** index log content. The actual log lines are stored as compressed chunks in object storage (S3). When you query, Loki identifies relevant chunks by labels and time range, then scans the content within those chunks.

```
Application ──→ Promtail (scrapes stdout/stderr) ──→ Loki (index + S3 chunks) ──→ Grafana
```

This design makes Loki cheap to run (no full-text indexing) but means content-based searches scan more data than a system like Elasticsearch would. The tradeoff is intentional: label-based access is fast, content search is slower but storage is an order of magnitude cheaper.

### Where logs break down

Logs answer "what happened on this service at this time." They don't efficiently answer "what happened across all 15 services this request touched." You can grep for a request ID across services, but you're mentally reconstructing the call flow from timestamps and hoping the clocks are synchronized. For a request that fans out to multiple downstream services in parallel, the log lines are interleaved and the causal structure is lost.

## Traces

A trace is a graph. Not a number, not a text record --- a **tree of causally related events across services**.

One request enters the system, hits the API gateway, which calls the order service, which calls the inventory service and the payment service in parallel, the inventory service calls PostgreSQL, the payment service calls an external payment provider. That's a tree of spans with parent-child relationships. The trace ID ties them all together. The parent span ID encodes the causal structure --- which call caused which.

```
[API Gateway]  ────────────────────────────────  850ms
  └─[order-service]  ─────────────────────────  780ms
      ├─[inventory-service]  ─────────────────  620ms
      │   └─[PostgreSQL query]  ──────────────  590ms  ← here's your bottleneck
      └─[payment-service]  ──────────  120ms
          └─[HTTP POST stripe.com]  ──  85ms
```

The access pattern is: "show me the full call tree for this request, across every service it touched, with timing for each hop." That's not a query you can express efficiently against a log system or a metrics system, because neither one indexes data by **causal relationship between events across services**.

You could hack it. Put a trace ID in every log line, search Loki for all lines with that trace ID, sort by timestamp, and mentally reconstruct the call tree. People do this. It works for small systems. It falls apart when:

- A single request touches 15 services
- You need to see where the latency *actually* happened (was it the database call in the inventory service, or the network hop between order and inventory?)
- You need to find *which* request is slow, not just *that* requests are slow (metrics tell you the latter, traces tell you the former)
- You need to aggregate across traces --- "what's the typical call pattern for requests to `/checkout`, and where do the slow ones diverge?"

### How Tempo stores traces

Tempo stores traces as objects in S3, indexed by trace ID, using bloom filters for discovery. It doesn't index every span attribute --- it's a trace ID lookup store, not a search engine. TraceQL adds search capabilities, but the primary access pattern is still "give me this trace by ID."

```
Application (OTel SDK) ──OTLP──→ OTel Collector ──OTLP──→ Tempo (S3) ──→ Grafana
```

This design makes Tempo extremely cheap. A trace is written once and read rarely (only during investigations). The storage cost is dominated by S3 object storage, not indexing infrastructure.

### Where traces break down

Traces answer "what happened to this specific request." They don't efficiently answer "how is the system doing overall." You can derive metrics from traces (Tempo's metrics generator does this, producing RED metrics --- rate, errors, duration --- via remote write to Prometheus), but traces are not a replacement for metrics. Sampling means you don't have every trace, and aggregating across millions of traces to compute a percentile is orders of magnitude more expensive than reading a pre-aggregated histogram.

### Why traces need a separate system

It's the same reason you don't store metrics in Elasticsearch or logs in Prometheus. You *could*. The data would fit. But the query patterns are different enough that a system optimized for one is bad at the other.

Metrics are optimized for: "aggregate this number across these dimensions over this time range." The TSDB is built for sequential time-range scans with label-based filtering.

Logs are optimized for: "find records matching this pattern in this time range." The storage is built for label-indexed chunk scanning with content filtering.

Traces are optimized for: "retrieve the complete call tree for this trace ID and show me the span hierarchy with timing." The storage is built for trace-ID-based object retrieval with structural queries (find the slowest span, find the critical path, show the service dependency graph).

A trace backend (Tempo) stores spans grouped by trace ID as objects. A log backend (Loki) stores log lines grouped by label streams as chunks. Asking Loki to efficiently reconstruct a trace from log lines scattered across hundreds of label streams is like asking PostgreSQL to efficiently serve a key-value workload --- it can do it, but a purpose-built system does it better.

## Events

This is where it gets philosophically interesting. What's an event? In the broadest sense, everything is an event. A metric sample is an event (a measurement was taken). A log line is an event (something happened). A span is an event (a unit of work started and ended).

### The Honest Answer: Events Are Logs

At the data level, there is no difference between an event and a log. Both are timestamped structured records of something that happened. You can store both in Loki. You can store both in Elasticsearch. The bytes on disk are indistinguishable. Many teams forward Kubernetes events into Loki as structured log entries, and once they're in Loki, they *are* log entries. Nothing about the storage distinguishes them.

And the reverse is true too. A structured log line like this:

```json
{"level":"error","msg":"database connection lost","service":"order-service"}
```

Is that a log or an event? It's a state change (connection was up, now it's down). It's produced by the application, not by an external observer. It's one line among thousands. It's both.

So why does the industry maintain the distinction?

### The Distinction Is Editorial, Not Technical

The difference between events and logs isn't about what the data *is*. It's about **who produces it, why, and what the signal-to-noise ratio is**.

**Logs are exhaustive.** An application logs everything it does. Every request, every query, every connection, every retry. Most of it is noise. A healthy service producing 10,000 log lines per minute might have 3 that matter. You wade through logs *after* you know something is wrong, looking for the relevant needle. Logs are raw footage.

**Events are curated.** Something decided "this is worth telling you about." A Kubernetes controller doesn't emit a continuous stream of "pod is still running, pod is still running" --- it emits a record *when something changes*: pod scheduled, container started, readiness probe failed. An alert fires when a threshold is crossed, not every time a metric is scraped. Events are the highlight reel.

Kubernetes events are the clearest example of the editorial distinction:

```
LAST SEEN   TYPE      REASON              OBJECT                    MESSAGE
2m          Normal    Scheduled           pod/order-service-7x9f2   Successfully assigned to node-3
2m          Normal    Pulled              pod/order-service-7x9f2   Container image already present
2m          Normal    Created             pod/order-service-7x9f2   Created container order-service
2m          Normal    Started             pod/order-service-7x9f2   Started container order-service
45s         Warning   Unhealthy           pod/order-service-7x9f2   Readiness probe failed: connection refused
30s         Warning   BackOff             pod/order-service-7x9f2   Back-off restarting failed container
```

Compare that to the logs from the same pod:

```
2025-03-03T14:23:01Z INF starting order-service version=v2.4.1
2025-03-03T14:23:01Z INF connecting to database host=postgres-primary.production
2025-03-03T14:23:01Z INF loading configuration from vault path=production/order-service
2025-03-03T14:23:02Z INF database connection established latency=1.2s
2025-03-03T14:23:02Z INF starting HTTP server addr=:8080
2025-03-03T14:23:02Z INF starting gRPC server addr=:9090
2025-03-03T14:23:05Z INF handled request method=GET path=/health status=200 duration=2ms
2025-03-03T14:23:05Z INF handled request method=GET path=/health status=200 duration=1ms
... (thousands more lines) ...
```

Six events vs. thousands of log lines, covering the same time period for the same pod. The events tell you *what changed*. The logs tell you *everything that happened*. Both are timestamped structured records. The difference is that someone --- a Kubernetes controller, an alerting rule, a human writing the code --- made an editorial decision about what rises to the level of "event."

### The Practical Differences

Even though events and logs are the same data type, they differ in practice along axes that matter operationally:

- **Volume**: Logs are high-volume continuous streams (megabytes per second per service). Events are low-volume discrete notifications (a few per minute per object). This affects storage cost and query performance.
- **Signal-to-noise**: Events are pre-filtered by their producer. Every event is supposed to be meaningful. Logs contain everything, and most of it is routine.
- **Consumption pattern**: You **search** logs ("show me what happened on this service between 2:00 and 2:05"). You **react to** events ("this alert fired, this pod restarted, this deployment rolled out"). Logs are pulled. Events are pushed.
- **Retention**: Logs are typically retained for days to weeks. Events are often ephemeral (Kubernetes events expire after 1 hour by default, though forwarding them to a log system gives them longer life).
- **Audience**: Logs are consumed by developers debugging application behavior. Events are consumed by operators and automation (controllers, alerting, incident response).

But none of these are fundamental properties of the data. They're conventions about how two flavors of the same thing get produced, stored, and consumed.

### Events on the Spectrum: Between Logs and Metrics

Rather than treating events as a separate category, it's more honest to place them on a spectrum between logs and metrics.

An event is to logs what a metric is to raw measurements. Someone upstream decided what matters and distilled the raw exhaust into something higher-signal. But where metrics pre-aggregate into **bounded numeric dimensions** (counter, histogram, gauge), events pre-aggregate into **unbounded structured narratives** (reason, object, message). Metrics trade away detail for predictable cardinality. Events trade away volume for signal, but keep the detail --- and accept the unbounded cardinality that comes with it.

```
Raw measurements ──(pre-aggregate into bounded numbers)──→ Metrics
                                                            Low cardinality, no detail

Raw log lines ────(curate into significant state changes)──→ Events
                                                            Unbounded cardinality, high detail

Raw log lines ────(store everything)──────────────────────→ Logs
                                                            Unbounded cardinality, all detail
```

This framing explains why events don't need their own storage engine. Metrics need a TSDB because the access pattern (aggregate numbers over time ranges by label dimensions) is fundamentally different from text search. Traces need an object store indexed by trace ID because the access pattern (retrieve a causal graph by a single identifier) is fundamentally different from either. But events? They're just curated logs. The access pattern is the same: search by time, filter by labels, read the content. Loki handles both.

The reason events get listed as a separate observability signal is partly historical (Kubernetes has an Event API that's distinct from pod logs, and alerting systems produce notifications that feel different from application output) and partly because the editorial distinction --- high-signal curated records vs. exhaustive raw output --- is genuinely useful even if the underlying data format is identical.

Think of it this way: a novel and a legal brief are both text documents. You could store them in the same database. But you read them differently, search them differently, and care about different things in each one. Events and logs are like that. Same format. Different editorial intent. Different position on the cardinality-vs-detail tradeoff curve.

### Events in Prometheus

Prometheus alerts are events. When an alert fires, Alertmanager produces a discrete notification: "this condition became true at this time." The alert has structured fields (alertname, severity, labels, annotations) and represents a state change (firing → resolved). It's an event, not a metric, even though it's derived from metrics.

```yaml
# This is a metric query
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.05

# When it crosses the threshold, it produces an event (alert)
# FIRING: HighErrorRate service=order-service error_rate=7.2%
```

## The Cardinality Problem

Cardinality is the number of unique combinations. In observability, it's the thing that kills your systems.

### Metrics Cardinality

Prometheus scales primarily by **label cardinality**, not data volume. Every unique combination of metric name + label values creates a new time series. Each time series costs memory (for the head block) and disk (for TSDB blocks), regardless of how many samples it contains.

A metric with low cardinality is cheap:

```
# 3 services × 4 methods × 5 status codes = 60 time series
http_requests_total{service="api-gateway", method="GET", status="200"}
http_requests_total{service="api-gateway", method="GET", status="404"}
http_requests_total{service="api-gateway", method="POST", status="201"}
... (57 more combinations)
```

The same metric with a high-cardinality label becomes expensive:

```
# 3 services × 4 methods × 5 status codes × 100,000 users = 6,000,000 time series
http_requests_total{service="api-gateway", method="GET", status="200", user_id="usr-00001"}
http_requests_total{service="api-gateway", method="GET", status="200", user_id="usr-00002"}
... (5,999,998 more)
```

Six million time series will bring Prometheus to its knees. Not because of the data volume (each sample is 16 bytes), but because the TSDB has to maintain an inverted index entry, a head chunk, and a memory mapping for every active series. The memory usage scales linearly with series count, not sample count.

This is why **adding a label is the most dangerous operation in a metrics system**. Adding `user_id` to a metric doesn't just add information --- it multiplies the cardinality by the number of users. Adding `request_id` multiplies it by the number of requests. These are not theoretical mistakes; they are the number one cause of Prometheus outages in production.

Common cardinality explosions:
- `user_id` or `customer_id` on a metric (unbounded dimension)
- `url_path` with path parameters not normalized (`/users/123` vs `/users/456` creates a new series for every user)
- `error_message` as a label (every unique error string creates a new series)
- `pod_name` on a metric in a system with frequent pod churn (new series on every restart, old series become stale)

The OTel Collector's filter and transform processors address this by dropping or aggregating high-cardinality labels *before* they reach Prometheus. This is one of the Collector's highest-value functions --- cardinality control at the pipeline level rather than at the application level.

### Log Cardinality

Loki has its own cardinality problem, but it manifests differently. Loki indexes logs by **label streams**, not by content. Each unique label combination is a stream. Too many streams cause the same kind of index pressure that too many time series cause in Prometheus.

```
# Low cardinality: good
{service="order-service", namespace="production"} → one stream

# High cardinality: dangerous
{service="order-service", namespace="production", pod="order-service-7x9f2"} → new stream per pod
{service="order-service", namespace="production", pod="order-service-8k3j1"} → another stream
```

Loki's documentation is explicit about this: keep label cardinality low. Use broad labels (service, namespace, level) and use LogQL's filter expressions for everything else. Don't put `pod_name` in a label if pods churn frequently --- filter on it in the query instead.

But logs also have a **volume** dimension that metrics don't. A noisy service that logs every request at debug level can produce gigabytes per day. That volume costs storage (S3 chunks) and query time (scanning those chunks). Metrics don't have this problem because they're pre-aggregated --- 10,000 requests become one counter increment.

### Trace Cardinality

Traces have the most forgiving cardinality model. Tempo stores traces by trace ID as opaque objects. There's no inverted index over span attributes (unlike a system like Jaeger backed by Elasticsearch). Adding a high-cardinality attribute to a span (`user_id`, `order_id`, `request_id`) costs nothing in index terms --- it's just bytes in the stored trace object.

The cardinality concern for traces is **span volume per request**. A trace with 5 spans is small. A trace with 5,000 spans (possible in a system with deep call chains and aggressive instrumentation) is large and expensive to store and render. The mitigation is sampling: keep 100% of error and slow traces, sample normal traffic down to 1-10%.

### Cardinality Summary

| Signal | Cardinality driver | Scaling limit | Mitigation |
|--------|-------------------|---------------|------------|
| **Metrics** | Label combinations (dimensions) | Memory per time series | Drop/aggregate labels before ingestion |
| **Logs** | Label streams + content volume | Index size + storage volume | Keep labels broad, filter on content |
| **Traces** | Span count per trace × trace volume | Storage volume | Sampling (head or tail) |
| **Events** | Event count per object | Minimal (low volume) | TTL expiration |

The key insight: **metrics cardinality is multiplicative** (each new label multiplies total series by its unique value count), while **log and trace cardinality is additive** (each new record adds to volume linearly). This is why a single bad label on a Prometheus metric can cause an outage, while a single noisy log stream just costs more storage.

## Cross-Signal Correlation: Where It All Connects

The four signals become more than the sum of their parts when they're linked:

```
Metrics → "error rate spiked to 7% on order-service"
    │
    │  (exemplar links metric data point to a trace ID)
    ▼
Trace → "request abc123: API → order-service → payment-service (timeout after 30s)"
    │
    │  (span attributes include pod name, namespace, trace ID)
    ▼
Logs → "order-service pod-7x9f2: payment provider timed out after 30s, orderId=ord-4821"
    │
    │  (Kubernetes event on the same pod)
    ▼
Event → "pod/order-service-7x9f2: Unhealthy - readiness probe failed"
```

In Grafana, this flow is navigable:

1. A Prometheus alert fires for high error rate
2. Click an exemplar on the Grafana panel → jumps to the trace in Tempo
3. The trace shows exactly which span failed and how long each hop took
4. Click a span → derived field links to the Loki logs for that service during that time window, filtered by trace ID
5. Kubernetes events on the same pod show it was being restarted due to failed readiness probes

Without traces, step 2 is "grep Loki for errors around this timestamp and try to figure out which of the 15 services in the request path is the problem." Without events, step 5 is "kubectl describe pod and hope the event hasn't expired." Without metrics, step 1 is "someone noticed the site is slow and filed a ticket."

Each signal fills a gap that the others can't efficiently cover. Metrics tell you something is wrong. Traces tell you where. Logs tell you why. Events tell you what changed.
