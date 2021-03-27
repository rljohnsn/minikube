#!/bin/sh
set -e

# Installing dependencies
brew list > ./.brew-list.txt
[ "$(cat ./.brew-list.txt | grep -ci minikube)" -eq 0 ]        && brew install minikube
[ "$(cat ./.brew-list.txt | grep -ci helm)" -eq 0 ]            && brew install helm@2
[ "$(cat ./.brew-list.txt | grep -ci kubernetes-cli)" -eq 0 ]  && brew install kubernetes-cli

# Configure Minikube and Kubectl
figlet minikube | lolcat
cat /dev/null > ~/.kube/minikube
minikube update-check && minikube status || minikube start
export KUBECONFIG=~/.kube/minikube
minikube update-context

figlet kubectl | lolcat
kubectl cluster-info
kubectl get nodes

# Helm Repositories
figlet Helm | lolcat
helm repo list > ./.helm-repo-list.txt
[ "$(cat ./.helm-repo-list.txt | grep -ci appscode)" -eq 0 ]    && helm repo add appscode https://charts.appscode.com/stable/
[ "$(cat ./.helm-repo-list.txt | grep -ci bitnami)" -eq 0 ]     && helm repo add bitnami https://charts.bitnami.com/bitnami
[ "$(cat ./.helm-repo-list.txt | grep -ci chartmuseum)" -eq 0 ] && helm repo add chartmuseum https://chartmuseum.es.8x8.com

helm repo list
helm init --upgrade --wait --history-max 10

# Install supporting charts
helm upgrade kubed            appscode/kubed              --force --install --namespace kube-system --version v0.12.0 --set config.clustername=kubed,apiserver.enabled=false > /dev/null && echo "."
helm upgrade ecr-credentials  chartmuseum/ecr-credentials --force --install --namespace kube-system --version 1.0.136-6cdc7075-RELEASE > /dev/null && echo "."

echo 
helm list -rd  --col-width 20

figlet profit | lolcat
sleep 4
# Launch the dashboard
minikube dashboard

