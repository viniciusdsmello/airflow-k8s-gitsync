#!/bin/bash
sudo echo ""

# install helm
cd /tmp || exit 0
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# Adds airflow helm repo
helm repo add airflow-stable https://airflow-helm.github.io/charts
