# Airflow with KubernetesExecutor + GitSync sidecar

## Overview

This repository contains the necessary steps and configurations to deploy Airflow with KubernetesExecutor and GitSync sidecar in a Kubernetes cluster. It allows you to run Airflow jobs within a Kubernetes environment.

## Project Structure

```
| dags/
| docs/
| helm/
    values.yaml: 
| scripts/
    install_k8s_secrets.sh
    install_local_dependencies.sh
    run_airflow_local.sh
| src/
    Dockerfile
    requirements.txt
Makefile
```

The project structure consists of the following directories:

- dags/: Contains the Airflow DAGs (Directed Acyclic Graphs) that define the workflows and tasks.
- docs/: Contains documentation related to the project.
- helm/: Includes the Helm chart configuration files, such as values.yaml, which holds the configuration values for Airflow deployment.
- scripts/: Contains various scripts for installing Kubernetes secrets, local dependencies, and running Airflow locally.
- src/: Holds the Dockerfile and requirements.txt file necessary for building the Airflow Docker image.
- Makefile: Provides convenience commands for building and running the project.

## Setup Locally

### Prerequisites

Before proceeding, ensure that you have the following prerequisites installed:

1. Docker: Required for building the Airflow Docker image.
1. Minikube: Needed for setting up a local Kubernetes cluster.
1. Helm: Required for deploying Airflow using the Helm package manager.

### Build Airflow Docker Image and push to remote

To build the Docker image for Airflow with KubernetesExecutor and push it to a remote repository, follow these steps:

Run the following command to build and push the Docker image:

```bash
make build
make push
```

This will build the Airflow Docker image and push it to the remote repository.

### Deploy Airflow Docker image to Kubernetes Cluster

To deploy the Airflow Docker image to a Kubernetes cluster, run the following command:

```bash
make deploy
```

This command will deploy Airflow using the Kubernetes configuration files and settings provided in the Helm chart. Ensure that you have the necessary permissions and access to the Kubernetes cluster before executing this command.
