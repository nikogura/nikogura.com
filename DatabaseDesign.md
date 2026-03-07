# "Design Me a Highly Resilient Database"

I've failed job interviews over this.  Not because I didn't know the answer.  Because I knew too many of them.

An interviewer once asked me to "design a highly resilient database."  No context.  No product.  No data model.  No query patterns.  No failure modes.  Just "highly resilient."

I did what any engineer who's been paged at 3 AM over a corrupted ledger would do: I asked questions.

"How resilient is 'resilient'?  What kind of data are we storing?  What are the query patterns?  What failure modes does the product need to survive?  Are we talking about financial transactions?  User sessions?  IoT telemetry?  Cat pictures?"

His answer: "Whatever.  Your choice."

So I chose.  I come from fintech.  U.S. Bank.  Apple Pay.  Environments where if a transaction says it committed, it *committed*, or somebody's money disappears and regulators start asking uncomfortable questions.  I laid out CloudNativePG on Kubernetes backed by S3-compatible object storage for WAL archiving — giving you 11 nines of durability on your backups, automated failover, point-in-time recovery, and the ability to restore a cluster from nothing but an S3 bucket and a manifest.  ACID-compliant.  Battle-tested.  Running in production right now under real money.

The answer he was looking for was Cassandra.  "You'd have a hard time having it NOT be resilient."

I failed the interview.

## The Question Was Wrong

Here's the thing: "Design me a highly resilient database" is not a database question.  It's a *product* question.  And you can't answer a product question without knowing the product.

A database is not a standalone artifact.  It is an organ in a living system.  Asking someone to "design a resilient database" without specifying the system is like asking a surgeon to "design a resilient organ" without telling them whether it's going into a human or a horse.  The answer depends entirely on the body it has to live in.

Cassandra is a fine database.  It's excellent at what it does.  What it does is distribute massive volumes of data across nodes with tunable consistency, survive node failures without breaking a sweat, and handle write-heavy workloads at scale.  If you're ingesting billions of time-series events from IoT sensors and you need five nines of write availability, Cassandra is a legitimate choice.

You know what Cassandra is not great at?  Keeping a financial ledger.

## ACID Is Not Optional When Money Is Involved

Cassandra offers "eventual consistency."  Eventual consistency means that if you write a value, different nodes might return different values for a period of time, but they'll *eventually* converge.  For a social media timeline, that's fine.  For a user's avatar URL, who cares.  For a financial ledger?

Eventual consistency on a ledger means that for some window of time, the system does not agree on how much money you have.  In regulated financial services, this is not a philosophical inconvenience.  It's a compliance violation.  It's a potential audit finding.  It might be fraud.

When I worked at U.S. Bank, I spent years in the payment processing space — credit card PAN encryption, tokenization, the systems that move real money between real institutions.  At Apple Pay, we processed millions of daily transactions across 30,000 servers with zero infrastructure-caused payment outages for two straight years.  These systems were PCI DSS compliant, which means among other things that when a transaction commits, the data is *durable* and *consistent* and you can *prove* it to an auditor.

This is why PostgreSQL exists in the financial world.  Not because it's trendy.  Because ACID compliance — Atomicity, Consistency, Isolation, Durability — is what stands between you and a regulator asking why your books don't balance.

## Every Database Is a Set of Tradeoffs

The CAP theorem is not a suggestion.  It's a mathematical proof.  In the presence of a network partition, you get to pick consistency or availability.  Not both.  Every database engine is a bet on which side of that tradeoff matters more for a given use case.

Here's an incomplete but illustrative map:

**PostgreSQL / MySQL (RDBMS):** Strong consistency, ACID transactions, complex queries with JOINs, relational integrity.  The right choice when your data has relationships, your queries are complex, and correctness matters more than raw throughput.  Financial ledgers.  User accounts.  Anything with foreign keys that *mean something.*

**Cassandra / ScyllaDB:** Partition-tolerant, highly available, eventually consistent (tunable), optimized for write-heavy workloads.  Excellent for time-series data, event logs, IoT telemetry — situations where you're ingesting massive volumes and can tolerate brief inconsistency windows.

**Redis:** In-memory, sub-millisecond reads, ephemeral by design (though it can persist).  The right choice for caching, session state, rate limiting, real-time leaderboards.  The wrong choice for your system of record.

**Elasticsearch:** Full-text search, analytics, log aggregation.  Not a primary database.  A secondary index over data that lives somewhere else.

**DynamoDB:** Managed, serverless-ish, partition-tolerant with optional strong consistency on reads.  Good for high-throughput key-value access patterns where you can design your access patterns upfront and don't need ad-hoc queries.

**ClickHouse / TimescaleDB:** Columnar or time-series optimized.  Excellent for analytical workloads over large datasets.  Not where you put your transactional data.

Every one of these is a legitimate tool.  None of them is the universal answer to "design me a resilient database."  Because *resilient against what?*

## The Questions That Actually Matter

When someone asks you to design a data layer, the first thing out of your mouth should be questions, not products.  Here's what you need to know before you can give a responsible answer:

**What kind of data?**  Relational with integrity constraints?  Time-series events?  Documents with variable schema?  Graph relationships?  The shape of the data eliminates half your options immediately.

**What are the query patterns?**  Are we doing complex JOINs across normalized tables?  Point lookups by primary key?  Full-text search?  Aggregations over time windows?  The query pattern determines whether you need an RDBMS, a document store, a columnar engine, or a search index.

**What are the consistency requirements?**  Can you tolerate eventual consistency?  Do you need linearizable reads?  Is this financial data where ACID is non-negotiable?  Is it a cache where stale data is acceptable for 30 seconds?

**What are the availability requirements?**  What's the SLA?  Can you afford a 30-second failover window?  Do you need multi-region active-active?  Is this a system where five minutes of downtime costs the business $100 or $10 million?

**What are the durability requirements?**  How many nines?  What's the RPO (Recovery Point Objective)?  Can you lose the last 5 seconds of writes, or is every byte sacred?  This determines your backup strategy, your replication topology, and your storage backend.

**What failure modes keep you up at night?**  Node failure?  Datacenter loss?  Network partition?  Operator error (someone drops a table)?  Malicious insider (someone *intentionally* drops a table)?  Each failure mode demands a different architectural response.

**What's the budget?**  A managed multi-region Aurora cluster costs different money than a self-hosted PostgreSQL on Kubernetes.  Both might meet your requirements.  Your CFO has opinions about which one you pick.

## The Cost of Getting It Wrong

Choosing the wrong database is not an academic exercise.  It's a business decision with real consequences.

**Choose eventual consistency for financial data** and you get audit findings, regulatory scrutiny, and potential legal liability.  I've seen this.  It's not theoretical.

**Choose a relational database for a write-heavy IoT pipeline** and you'll spend your weekends nursing a PostgreSQL instance that's drowning in WAL files and can't keep up with ingestion.  Then someone will suggest "just add more hardware" and your CFO will start asking questions you don't want to answer.

**Choose an in-memory store as your system of record** and you will eventually learn what "data loss" means in a production incident report.

**Choose a distributed NoSQL database because it's "resilient" without asking resilient-to-what** and you'll discover that it's resilient to node failures but not to the consistency requirements your product actually needs.  Your users will discover it first, when their account balance flickers between two values for 200 milliseconds and they file a support ticket asking if they're being robbed.

At a fintech startup, I ran CloudNativePG on Kubernetes — PostgreSQL with automated failover, continuous WAL archiving to S3, point-in-time recovery, and the ability to reconstitute an entire database cluster from object storage.  S3 gives you 11 nines of durability.  CNPG gives you automated promotion of replicas when a primary fails.  The combination gives you ACID compliance *and* operational resilience *and* disaster recovery you can demonstrate to auditors.

Is it "resilient"?  Yes.  But more importantly, it's resilient *in the ways that matter for financial data.*  It's consistent.  It's durable.  It's recoverable.  And it's auditable.

Could I have used Cassandra?  Sure.  And then I'd have to explain to a compliance officer why my ledger uses eventual consistency, and I'd better have a very good answer.

## The Point

There is no such thing as a "highly resilient database" in the abstract.  There are databases that are resilient to specific failure modes, optimized for specific access patterns, and appropriate for specific data models and consistency requirements.

The right answer to "design me a highly resilient database" is not a product name.  It's a conversation.  It starts with understanding the problem — the data, the product, the users, the failure modes, the regulatory environment, the budget — and then selecting the tool that fits.

An engineer who immediately jumps to a product name without asking these questions is not demonstrating expertise.  They're demonstrating that they have a favorite hammer and everything looks like a nail.

I asked the right questions in that interview.  I gave an answer grounded in real production experience with real money and real compliance requirements.  The interviewer wanted a magic word.  That's not engineering.  That's trivia.

The discipline is in the questions, not the answers.  Your future self — the one getting paged at 3 AM because the database made a promise it couldn't keep — will thank you for asking them.
