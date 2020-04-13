# Bring up K8S master node based on Vagrantfile

```bash
vagrant up
vagrant ssh
```

If you bring up a box based on this Vagrantfile, you should have a node with Kubernetes up and running! 
But there are a couple of final steps required before your Kubernetes node will be ready to run your workloads.

## Install a pod network

As per the official docs you need to install a CNI-based [pod network add-on](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network). 

```bash
vagrant@vagrant:~$ kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')
```

## Allow pods to run on the master node

By default master nodes get a taint which prevents regular workloads being scheduled on them. Since we only have one node in this cluster, we want to remove that taint.

```bash
vagrant@vagrant:~$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

# Install kube-state-metrics in K8S

## Install the Chart

```bash
vagrant@vagrant:~$ helm install stable/kube-state-metrics --set service.type=NodePort --set service.nodePort=30080
```

# Install prometheus-node-exporter in K8S

## Install the Chart

```bash
vagrant@vagrant:~$ helm install --name my-release stable/prometheus-node-exporter --set service.type=NodePort --set service.nodePort=30091
```

