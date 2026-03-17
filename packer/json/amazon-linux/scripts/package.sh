#!/bin/bash
set -e

# Update the system
sudo yum update -y

# Install basic utilities
sudo yum install -y git vim wget curl

# Install EFS utilities
sudo yum install -y amazon-efs-utils

# Install kubectl (latest stable)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

echo "All packages installed successfully!"

