#!/bin/bash
set -e

yum update -y

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

mkdir -p /home/ec2-user/.kube
chown ec2-user:ec2-user /home/ec2-user/.kube

cat > /home/ec2-user/setup_kubectl.sh << 'EOF'
#!/bin/bash
set -e

K3S_MASTER_IP=$1

if [ -z "$K3S_MASTER_IP" ]; then
  echo "Usage: $0 <k3s-master-ip>"
  exit 1
fi

echo "Copying kubeconfig from K3s master..."
scp ec2-user@$K3S_MASTER_IP:/etc/rancher/k3s/k3s.yaml ~/.kube/config

sed -i "s/127.0.0.1/$K3S_MASTER_IP/g" ~/.kube/config

echo "Kubernetes configuration complete! Try running: kubectl get nodes"
EOF

chmod +x /home/ec2-user/setup_kubectl.sh
chown ec2-user:ec2-user /home/ec2-user/setup_kubectl.sh

cat > /etc/motd << EOF
=================================================================
Welcome to the Bastion Host!

To set up kubectl access to the K3s cluster:
  ./setup_kubectl.sh <k3s-master-private-ip>

After setup, verify the cluster is running:
  kubectl get nodes

And check that the NGINX pod is deployed:
  kubectl get pod nginx
  kubectl get all --all-namespaces | grep nginx
=================================================================
EOF

echo "Bastion host setup complete!"
