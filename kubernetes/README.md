# kubernetes

Install [kubernetes](http://kubernetes.io/docs/getting-started-guides/).

## Variables

### `KUBE_VERSION`

Default to [check here](https://storage.googleapis.com/kubernetes-release/release/stable.txt).

### `KUBE_ROLE`

Then the role variable defines the role of above machine in the same order, “ai” stands for machine acts as both master 
and node, “a” stands for master, “i” stands for node.

Default to `ai`.
