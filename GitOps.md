# GitOps

## kubectl apply Is Not GitOps

I hear it all the time. "Yeah, we do GitOps." Then I watch someone `kubectl apply -f deployment.yaml` from their laptop and call it a day.

That's not GitOps. That's a human applying a file to a cluster. The fact that the file came from a git repository doesn't make it GitOps any more than printing an email makes it a fax.

We spent years as an industry learning that SSH-ing into production servers to make changes was a bad idea. No audit trail. No reproducibility. No way to really know what changed, when, or by whom. You may have some idea from logs and file permissions, but it's a tenuous trail at best.  No way to roll back except "SSH in again and hope you remember what it looked like before." We replaced that with configuration management, immutable infrastructure, and infrastructure as code.

`kubectl apply` from a laptop is the same thing wearing a Kubernetes t-shirt. You're SSH-ing into your cluster with extra steps. The manifest might be version-controlled, but the act of applying it isn't. The cluster doesn't know where the change came from, whether it was reviewed, or whether it matches what's in git. You've reproduced every problem we solved by getting off of production servers, just in a different context.

`kubectl edit` and `kubectl patch` are in many ways worse. At least `kubectl apply` starts from a file that might exist somewhere. `kubectl edit` opens a resource in your terminal editor, lets you change it in place, and applies the result. `kubectl patch` does the same thing without even opening an editor --- a one-liner that mutates a live resource and vanishes into your shell history. There's no file. There's no diff. There's no record of the previous state. There's no code review. The change exists only in etcd and in the memory of the person who made it. From a security standpoint, someone can `kubectl edit` a Role or ClusterRole and grant permissions that were never reviewed or approved. From a capacity planning standpoint, someone can `kubectl edit` a Deployment and bump replicas or resource requests, and now your cluster is running a workload profile that doesn't match anything in your planning documents. From a reliability standpoint, someone can `kubectl edit` a ConfigMap or Secret and break an application in a way that's invisible to anyone who wasn't watching at that moment. When the next deploy from git overwrites the edit and things break differently, good luck figuring out what the intermediate state was. It's SSH-ing into a server and editing config files by hand. We stopped doing that for good reasons.

`helm install` from a CI pipeline isn't GitOps either. Neither is `helm upgrade`. Neither is a Jenkins job that runs `kubectl apply` on a schedule. These are all imperative actions performed by something outside the cluster. The moment that action fails, or the pipeline breaks, or someone runs a different version from their laptop because the pipeline is slow, your cluster state and your git state have diverged, and you might not know it.

GitOps is a specific thing. It has a definition, and the definition matters.

## What GitOps Actually Is

GitOps is really simple. Everything applied to the cluster is in git. Nothing is configured outside of git, and if someone does change something, the automation puts it back.

That's it. A controller running inside the cluster continuously reconciles the cluster's actual state against the desired state declared in a git repository. Three moving parts:

1. **Git holds the desired state.** Every piece of configuration that affects your cluster is committed, reviewed, and merged. No exceptions.

2. **A controller watches git and applies changes.** The controller runs in the cluster. It polls or receives webhooks from git, computes the diff between desired and actual, and applies the changes. No human in the loop. No CI pipeline. No `kubectl` command.

3. **Drift is automatically corrected.** If someone `kubectl edit`s a deployment, the controller notices the drift and reverts it. The cluster converges back to what git says. Always.

If any of these three are missing, you don't have GitOps. You have "infrastructure files in git," which is better than nothing, but it's a different thing with different properties.

## Why the Distinction Matters

The value of GitOps is not "we keep YAML in git." The value is the properties that emerge from the reconciliation loop.

### Audit Trail

Every change to infrastructure is a git commit. Who changed it, when, why, and what the previous state was. This isn't just nice to have --- in regulated environments (banking, healthcare, fintech), auditors ask "show me the change history for this system." With GitOps, you point them at the git log. Done.

With `kubectl apply`, the audit trail is "someone ran a command at some point." `kubectl` doesn't record who applied what, or from where. The cluster's etcd stores the current state, not the history of how it got there. If someone applies a change from their laptop at 2 AM during an incident, that change is invisible to everyone except whoever happened to be watching at the time.

### Reproducibility

If your cluster catches fire, can you rebuild it? With GitOps, the answer is definitely yes. Stand up a new cluster, point the controller at the same git repository, and walk away. The controller will converge the new cluster to the desired state.

With imperative `kubectl apply`, rebuilding means someone remembers (or discovers) which files to apply, in what order, with what flags. Maybe they documented it. Maybe they didn't. Maybe the docs are out of date. Do you want to bet your infrastructure on "maybe"?

### Drift Detection and Correction

Production clusters drift. Someone scales a deployment manually during an incident and forgets to revert it. Someone edits a ConfigMap to test something. A CRD webhook mutates a resource in a way nobody expected. These things happen in every cluster, every week.  Even the act of running causes drift - Those pristine volumes are filling up with logs.

With GitOps, drift is detected and corrected automatically. The controller sees the difference between what git says and what the cluster has, and it fixes it. You don't need to discover the drift. You don't need to remember to fix it. It just converges.

Without a reconciliation loop, drift accumulates silently until something breaks and you spend a weekend figuring out why the cluster doesn't match your manifests. I've been that person. It's not fun.

### Rollback

Rolling back with GitOps is `git revert`. That's it. The controller picks up the revert commit and reconciles the cluster to the previous state. Clean, auditable, automatic.

Rolling back with `kubectl apply`? You'd better hope someone saved the previous version of the manifest. And that they apply the right one. And that nothing else changed in between that they need to account for. And that they don't fat-finger something at 3 AM during an outage.

## The CI Pipeline Trap

Here's where many teams go wrong. They build a perfectly good CI/CD pipeline that does something like:

```
push to git → CI runs tests → CI runs helm upgrade → done
```

This looks like GitOps. It has git. It has automation. It deploys things. But it's not GitOps, and the failure modes are different in ways that matter.

**Push-based deployment is fragile.** The pipeline is an external actor performing an imperative action against the cluster. If the pipeline fails mid-deploy, you have a partial state. If the pipeline succeeds but the cluster rejects a resource, the pipeline might not know. If someone bypasses the pipeline and applies something directly, the pipeline doesn't know about the drift.

**Pull-based reconciliation is resilient.** The controller runs in the cluster, continuously. If it fails to apply something, it retries. If someone manually changes something, the controller reverts it. If the controller itself crashes and restarts, it re-reads git and re-converges. The desired state is always in git, and the controller always moves toward it.

The difference is subtle but fundamental. Push-based deployment tells the cluster "be this." Pull-based reconciliation tells the cluster "always be what git says." The first is an event. The second is a property of the system.

## The Convergence Requirement

This is the part most "GitOps" implementations get wrong. Having your configuration in git and having a pipeline apply it is not enough. You need a convergence loop --- something running continuously in the background that compares desired state to actual state and corrects drift automatically.

This isn't a new idea. Puppet and Chef solved this problem twenty years ago. The Puppet agent runs every 30 minutes, compares the node's actual state to the catalog, and fixes whatever has drifted. Chef's client does the same thing. The insight was that applying configuration once and walking away doesn't work, because systems drift. Someone logs in and changes something. A package update modifies a config file. A process crashes and gets restarted with different flags. Without continuous convergence, drift accumulates and you end up with infrastructure that doesn't match what you think you have.

Kubernetes GitOps controllers like FluxCD are the direct descendants of this pattern. The controller runs in the cluster, continuously. It doesn't just apply once on commit --- it re-reconciles on an interval, detects drift, and corrects it. If someone `kubectl edit`s a deployment, the controller puts it back. If a webhook mutates a resource, the controller notices and reverts the mutation. The desired state in git is enforced as an ongoing property of the system, not as a one-time event.

Tools like Terraform and Atlantis don't do this. Terraform applies infrastructure changes imperatively --- `terraform apply` runs once, makes the changes, and exits. Atlantis wraps Terraform in a pull request workflow, which is an improvement over running `terraform apply` from a laptop, but it's still push-based. There's no background worker thread running periodically to detect and correct drift. If someone modifies an AWS security group through the console, or an IAM policy gets changed by another team's Terraform, or a resource drifts for any reason, Terraform doesn't know until the next time someone runs `terraform plan`. That could be days, weeks, or never.

You can run `terraform plan` on a schedule to detect drift, and some teams do. But detection without correction is monitoring, not convergence. An alert that says "your infrastructure has drifted" at 2 AM is useful, but it still requires a human to wake up, assess the drift, and decide what to do. A convergence loop that automatically corrects drift while you sleep is a fundamentally different operational model.

This is what people actually mean --- or should mean --- when they say "declarative infrastructure as code." Declarative doesn't just mean "I described the desired state in a file." It means there's a system that continuously ensures reality matches the declaration. The declaration is a contract, and something is enforcing it.

Puppet does this. The Puppet agent runs on every node, compares actual state to the catalog, and fixes drift. Chef does this. The Chef client runs on a schedule, converges the node to the cookbook's desired state, and reports back. These tools understood twenty years ago that applying configuration once and hoping it sticks is not enough.

Ansible does not do this, at least not natively. Ansible is imperative --- you run a playbook, it makes changes, it exits. There's no agent, no background convergence, no drift correction. If someone changes something after the playbook runs, Ansible doesn't know and doesn't care until the next time a human runs the playbook. Ansible Tower (now Red Hat Ansible Automation Platform) and AWX (its open source upstream) can schedule playbook runs on a recurring interval --- every 30 minutes, for example --- which provides convergence-like behavior. But it's a scheduled re-run of an imperative tool, not a native convergence loop. The playbook runs, applies changes, exits, and the system is unmanaged until the next scheduled run. It's closer to a cron job running `terraform apply` than it is to a Puppet agent.

Terraform is in the same category. `terraform apply` runs once and exits. Atlantis wraps it in a pull request workflow, which is better, but still push-based with no background convergence.

FluxCD and ArgoCD are the Kubernetes equivalents of Puppet and Chef. The controller runs continuously inside the cluster, watches for drift, and corrects it. The desired state in git is enforced as an ongoing property, not a one-time event.

If your tool applies once and walks away, you have automated deployment. If your tool continuously converges, you have declarative infrastructure. The distinction matters because drift doesn't wait for your next scheduled run.

## Evaluate Before You Apply

Even within a GitOps workflow, discipline matters. Never commit unevaluated resources to your repository:

```bash
# Don't do this
kubectl apply -f https://raw.githubusercontent.com/some-project/deploy.yaml
helm install my-release some-chart
```

Instead:

1. **Download and review.** Read the manifests. Understand what they create. Every `ClusterRole`, every `hostPath` mount, every `securityContext` override is a decision you're making about your cluster's security posture.

2. **Render charts locally.** Use `helm template` to see what a chart actually produces. Charts are templates, and templates hide things. Don't install what you haven't read.

3. **Commit the evaluated resources to git.** Once you've reviewed them, commit them. Now they're versioned, auditable, and subject to code review.

4. **Let the controller apply them.** The GitOps controller picks up the commit and applies the resources. You never touch `kubectl apply`.

This isn't bureaucracy. It's the difference between knowing what runs in your cluster and hoping for the best.  Hope is not a strategy.

## The Security Problem with Blind Application

The modern internet has normalized a deeply dangerous pattern: `curl https://some-url.sh | bash`. Install scripts, setup wizards, "one-line installs" --- they all ask you to download and execute code you haven't read from a source you don't control. People do it on their laptops, which is bad enough. People do it on production infrastructure, which is inexcusable.

`kubectl apply -f https://raw.githubusercontent.com/some-project/deploy.yaml` is the Kubernetes version of `curl | bash`. You're downloading a manifest from the internet and applying it to a cluster you are responsible for. A cluster you will be paged for at 3 AM. A cluster that holds your company's data, runs your company's services, and is governed by your company's compliance requirements.

What's in that manifest? You don't know, because you didn't read it. Here's what might be in it:

**RBAC grants you didn't authorize.** A `ClusterRoleBinding` granting `cluster-admin` to a service account the project controls. You've just given a third party full administrative access to your cluster. Every secret, every namespace, every workload --- theirs to read, modify, or delete. That's not a theoretical risk. I've seen it in real install manifests from real projects.

**Privileged containers.** A pod spec with `privileged: true` or `hostPID: true` or `hostNetwork: true`. A privileged container can escape its sandbox and access the underlying node. If you're running multi-tenant workloads, you've just given one tenant a path to every other tenant's data.

**Host path mounts.** A volume mount to `/var/run/docker.sock` or `/etc/kubernetes` or `/` itself. The container now has access to the node's filesystem, the container runtime, or worse. This is how container escapes work in practice.

**DaemonSets.** A DaemonSet runs a pod on every node in your cluster. Apply one blindly, and you've just deployed someone else's code on every node you operate. If that DaemonSet has a privileged security context, you've given it root on every node.

**Webhooks.** A `MutatingWebhookConfiguration` or `ValidatingWebhookConfiguration` intercepts every API request matching its rules. A malicious or misconfigured webhook can modify resources in transit, block deployments, or exfiltrate data from API requests. Webhooks are one of the most powerful extension points in Kubernetes, and one of the most dangerous to deploy without review.

**Network policies and service accounts.** Seemingly innocuous resources that change who can talk to whom, and what identity workloads run as. A service account with the right annotations can assume cloud IAM roles. A missing network policy can open a path between namespaces that should be isolated.

Helm charts are worse, because they hide all of this behind templates. A chart's `values.yaml` might look reasonable, but the templates that consume those values can produce anything. `helm install` without `helm template` first is applying code you haven't read. You wouldn't `go install` a binary without reading the source. Don't `helm install` a chart without reading the output.

**The discipline is simple:** download it, read it, understand it, commit it, review it, let the controller apply it. If a project's install instructions start with `kubectl apply -f https://`, that's a red flag about the project's security posture, not an instruction you should follow. Download the manifest. Read it. Decide whether you want those RBAC grants, those security contexts, those host mounts in your cluster. Then commit the reviewed manifest to your control repository and let GitOps do its job.

There's a capacity planning dimension to this too. If you don't know what's running in your cluster, you can't plan for it. Every manually applied workload, every blindly installed chart, every `kubectl apply` from a laptop is something consuming CPU, memory, and network that isn't accounted for in your resource budgets. When the cluster starts running hot and someone asks "do we need more nodes?", the honest answer is "I don't know, because I don't know what's running." You can't right-size what you can't inventory. You can't forecast what you can't measure. And you can't measure what you didn't know was there.

GitOps gives you a complete, auditable inventory of every resource in your cluster by definition. If it's not in git, the controller removes it. What's in git is what's running. Capacity planning starts with knowing what you have, and that starts with controlling what gets deployed.

You're the one who gets paged. You should know what's running.

## Control Repositories

The git repositories that hold your cluster's desired state are control repositories. They deserve the same respect as application code, because they are code. They're instructions for a machine --- just a different machine.

Control repositories provide:

- **What** changed (the diff)
- **Who** changed it (the commit author)
- **When** it changed (the commit timestamp)
- **Why** it changed (the commit message)
- **How to undo it** (git revert)

Code reviews on control repositories serve a slightly different purpose than application code reviews. The goal is less about style and correctness and more about communication and understanding. When a change to a control repository gets reviewed, the reviewer now knows that change is coming. They won't be surprised when the cluster changes. That shared awareness prevents a whole class of operational confusion.

## Kubernetes Resource Management

Within a GitOps model, you'll manage Kubernetes resources with one or more of these tools:

- **Bare YAML** --- simple, explicit, no abstraction. Good for small, stable configurations.
- **Helm** --- templated charts with values files. Good for third-party software and parameterized deployments. Bad when charts become so complex that nobody can predict what they'll render.
- **Kustomize** --- overlay-based composition. Good for managing environment-specific variations without templates. Composes cleanly with GitOps controllers.
- **Jsonnet** --- a data templating language. More expressive than Helm or Kustomize, with the advantage that everything is explicitly laid out in checked-in code. Harder to learn, but resistant to the "what does this actually produce?" problem.

You'll encounter all four. They all have their place. The key discipline is the same regardless of which you choose: render locally, review the output, commit the result (or the inputs that produce it), and let the controller apply it.

## The Point

GitOps is not a branding exercise. It's not "we keep files in git." It's a specific operational model with specific properties: audit trail, reproducibility, drift correction, and safe rollback. Those properties come from the reconciliation loop --- a controller in the cluster continuously converging actual state toward desired state.

If you're running `kubectl apply` or `helm install` --- from your laptop, from a CI pipeline, from a cron job, from anywhere --- you don't have those properties. You have automation, which is good. But automation and GitOps are not the same thing.

If it ain't in git, it ain't running in your infra. And if a controller isn't reconciling your infra to what's in git, it's not GitOps.
