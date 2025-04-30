#!/bin/bash
set -e

# === CONFIG ===
K3S_VERSION="v1.28.5+k3s1"        # Must match master version
MASTER_IP="192.168.1.215"         
TOKEN_FILE="token"            # File containing the token

# Check if token.txt exists
if [ ! -f "$TOKEN_FILE" ]; then
  echo "[!] Error: $TOKEN_FILE not found"
  exit 1
fi

# Read the token from token.txt
TOKEN=$(cat "$TOKEN_FILE")

# Ensure the token is not empty
if [ -z "$TOKEN" ]; then
  echo "[!] Error: Token in $TOKEN_FILE is empty"
  exit 1
fi

echo "[+] Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "[+] Installing required packages..."
apt update && apt install -y curl apt-transport-https ca-certificates

echo "[+] Installing k3s worker node (version $K3S_VERSION)..."
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION \
  K3S_URL=https://$MASTER_IP:6443 \
  K3S_TOKEN=$TOKEN \
  sh -

echo "[✓] K3s worker node joined the cluster successfully."