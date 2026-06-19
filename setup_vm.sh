#!/bin/bash
# Run this once on your VM to set everything up
# Usage: bash setup_vm.sh

set -e

REPO_URL="https://github.com/chedi-khlifi/projectpy.git"
DEPLOY_DIR=~/projectpy
SSH_KEY_PATH=~/.ssh/github_actions

echo "========================================"
echo " VM Setup for projectpy CI/CD"
echo "========================================"

# 1. Install Docker
echo ""
echo "[1/5] Installing Docker..."
sudo apt-get update -qq
sudo apt-get install -y docker.io docker-compose-plugin git curl
sudo usermod -aG docker $USER

# 2. Start Docker service
echo ""
echo "[2/5] Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# 3. Clone the repo
echo ""
echo "[3/5] Cloning repository..."
if [ -d "$DEPLOY_DIR" ]; then
  echo "Directory already exists, pulling latest..."
  cd $DEPLOY_DIR && git pull origin main
else
  git clone $REPO_URL $DEPLOY_DIR
fi
chmod +x $DEPLOY_DIR/rollback.sh
mkdir -p $DEPLOY_DIR/logs

# 4. Generate SSH key for GitHub Actions
echo ""
echo "[4/5] Generating SSH key for GitHub Actions..."
if [ -f "$SSH_KEY_PATH" ]; then
  echo "SSH key already exists at $SSH_KEY_PATH, skipping."
else
  ssh-keygen -t ed25519 -C "github-actions-deploy" -f $SSH_KEY_PATH -N ""
  cat $SSH_KEY_PATH.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo "SSH key created."
fi

# 5. Do an initial Docker build so the first deploy is faster
echo ""
echo "[5/5] Running initial Docker build..."
cd $DEPLOY_DIR
docker build -t projectpy:latest .
docker compose up -d
echo "Initial container started."

# Print summary
echo ""
echo "========================================"
echo " Setup complete!"
echo "========================================"
echo ""
echo "Now add these secrets to GitHub:"
echo "https://github.com/chedi-khlifi/projectpy/settings/secrets/actions"
echo ""
echo "  VM_HOST     → $(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')"
echo "  VM_USER     → $(whoami)"
echo "  VM_PORT     → 22"
echo "  VM_SSH_KEY  → (copy everything below, including the header/footer lines)"
echo ""
echo "-------- PRIVATE KEY START --------"
cat $SSH_KEY_PATH
echo "-------- PRIVATE KEY END ----------"
echo ""
echo "App is running at: http://$(hostname -I | awk '{print $1}'):8000"
