#!/bin/bash

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
# install specific version
./get_helm.sh -v v2.16.5

kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')

kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller

while [[ $(kubectl get pods -n kube-system -l name=tiller -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done

helm install stable/kube-state-metrics --set service.type=NodePort --set service.nodePort=30080

helm install --name my-release stable/prometheus-node-exporter --set service.type=NodePort --set service.nodePort=30091
