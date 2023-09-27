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
calicoctl patch BGPConfig default --patch '{"spec": {"serviceLoadBalancerIPs": [{"cidr": "10.11.0.0/16"},{"cidr":"10.1.5.0/24"}]}}'


#install flux
curl -s https://fluxcd.io/install.sh | sudo bash
flux bootstrap github --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --branch=main --personal --path=clusters/production
