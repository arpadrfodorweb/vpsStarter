#!/bin/bash

# Store the path to this script
SCRIPT_PATH=$(readlink -f "$0")

# Exit on any error
set -e

# Update and upgrade system
echo "Updating system packages..."
apt update && apt upgrade -y

# Create new user
echo "Creating new user 'elliot'..."
useradd -m -s /bin/bash elliot

# Set password for elliot (will prompt during script execution)
echo "Please set a password for user 'elliot'"
passwd elliot

# Add elliot to sudo group
echo "Adding elliot to sudo group..."
usermod -aG sudo elliot

# Set up SSH directory for elliot
echo "Setting up SSH directory..."
mkdir -p /home/elliot/.ssh
chmod 700 /home/elliot/.ssh
touch /home/elliot/.ssh/authorized_keys
chmod 600 /home/elliot/.ssh/authorized_keys
chown -R elliot:elliot /home/elliot/.ssh

# Install Docker
echo "Installing Docker..."
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add elliot to docker group
echo "Adding elliot to docker group..."
usermod -aG docker elliot

# Secure SSH configuration
echo "Configuring SSH..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd

echo "Setup complete! Now from your Windows machine, run:"
echo "ssh-copy-id elliot@your-server-ip"
echo ""
echo "After successfully copying your SSH key, run this command on the server to disable password authentication:"
echo "sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && sudo systemctl restart sshd"

# Clean up the script
echo "Cleaning up..."
rm -f "$SCRIPT_PATH"
echo "Script has been removed for security."