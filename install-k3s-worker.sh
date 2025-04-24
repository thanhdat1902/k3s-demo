#!/bin/bash
set -e

# === CONFIG ===
K3S_VERSION="v1.28.5+k3s1"        # Must match master version
MASTER_IP="192.168.1.215"         
TOKEN="REPLACE_WITH_TOKEN"        # Replace with actual token or script will prompt for it

echo "[+] Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "[+] Installing required packages..."
apt update && apt install -y curl apt-transport-https ca-certificates

if [ "$TOKEN" = "REPLACE_WITH_TOKEN" ]; then
  read -p "[?] Enter the K3s cluster token: " TOKEN
fi

echo "[+] Installing k3s worker node (version $K3S_VERSION)..."
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION \
  K3S_URL=https://$MASTER_IP:6443 \
  K3S_TOKEN=$TOKEN \
  sh -

echo "[✓] K3s worker node joined the cluster successfully."
