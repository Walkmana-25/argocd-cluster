#!/bin/bash

if [[ $(whoami) == "root" ]]
then
    echo "rootユーザで実行するな。"
    exit 1
fi

#install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh

#install cni flannel
# Needs manual creation of namespace to avoid helm error
kubectl create ns kube-flannel
kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged

helm repo add flannel https://flannel-io.github.io/flannel/
helm repo update
helm install flannel --set podCidr="10.244.0.0/16" --namespace kube-flannel flannel/flannel

#install metallb
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb

kubectl apply -f https://github.com/Walkmana-25/argocd-cluster/raw/main/bootstrap/metallb.yaml


#argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install my-argo-cd argo/argo-cd --version 5.46.7 --set server.service.type=LoadBalancer

