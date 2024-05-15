# Shell Functions

The following shell functions are often quite useful for debugging.  You can add them to your `~/.bashrc` or `~/.zshrc` at your pleasure.

You don't have to use them, but it's helpful to know what they are, since folks tend to use them as abbreviations in messaging.  

Just as typing `kubectl get pod` is kind of tedious to type on the cli, (`k get pod` or even just `pods` is much faster), typing that as instructions to someone looking for help is likewise faster and less error prone.  

Plus, once you start using the funcs, you start having trouble remembering the full command syntax.  Don't even get me started on `kubectl config get-contexts`.  Install the functions and just type `context`, get the info you're after, and get on with  your day.

## Nik's Shell Functions

* [niks-k8s-shell-funcs.sh](niks-k8s-shell-funcs.sh)

Contents:

        # called without arguments, displays context and current context
        # called with an argument, changes into the context given
        function context {
          if [ -n "$1" ]; then
            kubectl config use-context $1
          else
            kubectl config get-contexts
          fi
        }

        # Do you want to type 'kubectl' all the time?
        alias k=kubectl

        # Typing 'kubectl get pod' gets old, too
        alias pods="kubectl get pod"

        # get logs from a pod matching a pattern in the current namespace, or another
        function podlogs {
          PATTERN=$1
          NS=$2
          if [ -n "$NS" ]; then
            clear && k logs -n $NS -f $(pods -n $NS | grep ${PATTERN} | cut -d " " -f 1)
          else
            clear && k logs -f $(pods | grep ${PATTERN} | cut -d " " -f 1)
          fi
        }

        # delete a pod matching a pattern in the current namespace or another
        function delpod {
          PATTERN=$1
          NS=$2
          if [ -n "$NS" ]; then
            PODS=$(pods -n $NS | grep ${PATTERN} | cut -d " " -f 1)
            echo "${PODS}" | xargs kubectl delete pod -n $NS
          else
            PODS=$(pods | grep ${PATTERN} | cut -d " " -f 1)
            echo "${PODS}" | xargs kubectl delete pod
          fi
        }

        # describe a pod matching a pattern in the current namespace or another
        function descpod {
          PATTERN=$1
          NS=$2
          if [ -n "$NS" ]; then
            PODS=$(pods -n $NS | grep ${PATTERN} | cut -d " " -f 1)
            echo "${PODS}" | xargs kubectl describe pod -n $NS
          else
            PODS=$(pods | grep ${PATTERN} | cut -d " " -f 1)
            echo "${PODS}" | xargs kubectl describe pod
          fi
        }

        # show images in use in a namespace, or globally
        function images {
          NS=$1

          if [[ -z "$NS" ]]; then
            kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec['initContainers', 'containers'][*].image}" |tr -s '[[:space:]]' '\n' |sort |uniq -c

          else
            kubectl get pods -n "${NS}" -o jsonpath="{.items[*].spec['initContainers', 'containers'][*].image}" |tr -s '[[:space:]]' '\n' |sort |uniq -c

          fi
        }
            
        # Delete Failed Jobs in a Namespace
        function delfailedjobs {
          NS=$1
          if [ -z "$NS" ]; then
            echo "Usage: delfailedjobs <namespace>"
          else
            echo "Deleting failed jobs in $NS"
          fi

          kubectl get pods -n ${NS} --field-selector 'status.phase=Failed' -o name | xargs kubectl delete -n ${NS}
        }

        # Decode JWT's
        function decjwt {
            jq -R 'split(".") |.[0:2] | map(@base64d) | map(fromjson)'
        }

        # Get a JWT out of a K8S Cluster
        function gettoken {
          POD_PATTERN=$1
          TOKEN_DOMAIN=$2
          kubectl exec $(kubectl get pod | grep $POD_PATTERN | awk '{print $1}') -- cat /var/run/secrets/${TOKEN_DOMAIN}/serviceaccount/token

        }

        # Pull the generated Prometheus Config out of a Prometheus instance created by Prometheus Operator.
        alias promconfig="kubectl get secret -n monitoring prometheus-k8s -o json | jq -r .data.\\\"prometheus.yaml.gz\\\" | base64 -d | gunzip | vim -R -"
