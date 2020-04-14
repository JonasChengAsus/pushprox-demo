#!/bin/bash

## Install a pod network ##
# As per the official docs you need to install a CNI-based [pod network add-on](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network).
kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')

## Allow pods to run on the master node ##
# By default master nodes get a taint which prevents regular workloads being scheduled on them. Since we only have one node in this cluster, we want to remove that taint.
kubectl taint nodes --all node-role.kubernetes.io/master-

## Install helm2 ##
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
# install specific version
./get_helm.sh -v v2.16.5
rm get_helm.sh

## Install tiller ##
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
# wait for tiller pod status
while [[ $(kubectl get pods -n kube-system -l name=tiller -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done

## Install kube-state-metrics in K8S ##
helm install --name state-metrics --namespace kube-system stable/kube-state-metrics --set service.type=NodePort --set service.nodePort=30080

## Install prometheus-node-exporter in K8S ##
helm install --name node-exporter --namespace kube-system stable/prometheus-node-exporter --set service.type=NodePort --set service.nodePort=30091
