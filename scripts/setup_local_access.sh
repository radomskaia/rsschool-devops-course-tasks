#!/bin/bash
set -e

BASTION_IP=$(terraform -chdir=terraform output -raw bastion_public_ip)
K3S_MASTER_IP=$(terraform -chdir=terraform output -raw k3s_master_private_ip)
SSH_KEY_PATH="$1"

if [ -z "$SSH_KEY_PATH" ]; then
  echo "Usage: $0 /path/to/key.pem"
  exit 1
fi

mkdir -p ~/.kube

echo "Retrieving kubeconfig from master node..."
ssh -i "$SSH_KEY_PATH" -o "StrictHostKeyChecking=no" ec2-user@$BASTION_IP \
  "ssh -o StrictHostKeyChecking=no ec2-user@$K3S_MASTER_IP 'sudo cat /etc/rancher/k3s/k3s.yaml'" > ~/.kube/config-k3s

sed -i '' "s/127.0.0.1/$K3S_MASTER_IP/g" ~/.kube/config-k3s

SSH_CONFIG_FILE=~/.ssh/config
SSH_TUNNEL_CONFIG="
# K3s API tunnel
Host k3s-api-tunnel
  HostName $BASTION_IP
  User ec2-user
  IdentityFile $SSH_KEY_PATH
  LocalForward 6443 $K3S_MASTER_IP:6443
"

if grep -q "k3s-api-tunnel" "$SSH_CONFIG_FILE"; then
  echo "SSH tunnel config already exists, updating..."
  sed -i '' "/# K3s API tunnel/,/LocalForward.*6443/d" "$SSH_CONFIG_FILE"
fi

echo "$SSH_TUNNEL_CONFIG" >> "$SSH_CONFIG_FILE"

echo "Starting SSH tunnel..."
ssh -fN k3s-api-tunnel

sleep 2

export KUBECONFIG=~/.kube/config-k3s

echo "Testing kubectl access..."
kubectl get nodes

echo "Checking for NGINX pod deployment..."
kubectl get pod nginx
kubectl get all --all-namespaces | grep nginx

echo "
===== K3s Access Setup Complete =====

To use your k3s cluster:

1. Keep the SSH tunnel running or restart it if needed:
   ssh -fN k3s-api-tunnel

2. Use kubectl with the new config:
   export KUBECONFIG=~/.kube/config-k3s
   kubectl get nodes

3. Verify the NGINX pod is running:
   kubectl get pod nginx
   kubectl get all --all-namespaces

4. To stop the tunnel when finished:
   pkill -f 'ssh -fN k3s-api-tunnel'

For permanent configuration, add this to your shell profile:
   export KUBECONFIG=\$KUBECONFIG:~/.kube/config-k3s
"
