#!/bin/bash

if [[ $(whoami) == "root" ]]
then
    echo "rootユーザで実行するな。"
    exit 1
fi

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


#install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh

#install calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
curl -L https://github.com/projectcalico/calico/releases/download/v3.26.1/calicoctl-linux-amd64 -o calicoctl
chmod +x ./calicoctl
sudo mv ./calicoctl /usr/local/bin/calicoctl

wget https://github.com/Walkmana-25/argocd-cluster/raw/main/bootstrap/calico.yaml
calicoctl create -f calico.yaml
rm calico.yaml


#install metallb
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb

kubectl apply -f https://github.com/Walkmana-25/argocd-cluster/raw/main/bootstrap/metallb.yaml


#argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install my-argo-cd argo/argo-cd --version 5.46.7 --set server.service.type=LoadBalancer
