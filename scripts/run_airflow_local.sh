#!/bin/bash
sudo echo ""

# run minikube
# minikube start --memory=4000
# minikube addons enable ingress
# minikube update-context

# install airflow
helm upgrade --install airflow helm/airflow -f helm/values.yaml

# forwarding a port from airflow to local port 8000
RET=1
until [ ${RET} -eq 0 ]; do
    kubectl port-forward svc/airflow-web 8080:8080
    RET=$?
    sleep 10
done
