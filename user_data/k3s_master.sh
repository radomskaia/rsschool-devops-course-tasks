#!/bin/bash
set -e

yum update -y

yum install -y curl

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} K3S_TOKEN=${k3s_token} sh -

until kubectl get nodes | grep -i ready; do
  echo "Waiting for K3s to be ready..."
  sleep 5
done

kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml

echo "Waiting for nginx pod to start..."
until kubectl get pod nginx | grep -i running; do
  sleep 5
done

chmod 644 /etc/rancher/k3s/k3s.yaml

echo "K3s master setup complete with NGINX pod deployed!"

