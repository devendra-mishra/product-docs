#!/bin/bash

# Docker setup script for /mnt/storage
echo "Setting up Docker with data directory on /mnt/storage..."

# Update system packages
sudo apt update -y

# Install required packages
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index
sudo apt update -y

# Install Docker Engine
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Stop Docker service
sudo systemctl stop docker

# Create Docker data directory on the 20GB disk
sudo mkdir -p /mnt/storage/docker

# Create Docker daemon configuration
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "data-root": "/mnt/storage/docker",
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Add user to docker group
sudo usermod -aG docker ubuntu

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
echo "Docker installation completed!"
echo "Docker data directory: /mnt/storage/docker"
echo "Checking Docker status..."
sudo systemctl status docker --no-pager
echo ""
echo "Docker version:"
docker --version
echo ""
echo "Disk usage:"
df -h /mnt/storage
echo ""
echo "Docker info:"
sudo docker info | grep "Docker Root Dir"