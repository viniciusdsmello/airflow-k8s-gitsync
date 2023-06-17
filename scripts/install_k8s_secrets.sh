#!/bin/bash
sudo echo ""

# Install Airflow fernet key secret
kubectl create secret generic airflow-fernet-key --from-file=fernet-key=$PWD/fernet-key

# Install Airflow GitSync secret
kubectl create secret generic airflow-gitsync --from-file=id_rsa=$HOME/.ssh/id_rsa

# Install Airflow Postgres password secret
# kubectl create secret generic airflow-postgres-password --from-file=postgres-password=$PWD/postgres-password