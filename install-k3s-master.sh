#!/bin/bash
set -e

# === CONFIG ===
K3S_VERSION="v1.28.5+k3s1"   # Pick a fixed version from https://github.com/k3s-io/k3s/releases
CLUSTER_CIDR="10.42.0.0/16"

echo "[+] Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "[+] Installing required packages..."
apt update && apt install -y curl apt-transport-https ca-certificates sudo

echo "[+] Loading required kernel modules..."
modprobe overlay
modprobe br_netfilter

echo "[+] Installing k3s master node (version $K3S_VERSION)..."
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION INSTALL_K3S_EXEC="server --cluster-init --write-kubeconfig-mode 644 --cluster-cidr $CLUSTER_CIDR" sh -

echo "[+] Saving join token to /root/k3s_token..."
cp /var/lib/rancher/k3s/server/node-token /root/k3s_token
chmod 600 /root/k3s_token

echo "[+] Setting up kubeconfig for current user..."
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[✓] K3s master node installed and kubeconfig ready.. Use this token to join workers:"
cat /root/k3s_token