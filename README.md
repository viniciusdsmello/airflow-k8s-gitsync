# Airflow with KubernetesExecutor + GitSync sidecar

## Overview

This repository contains the necessary steps and configurations to deploy Airflow with KubernetesExecutor and GitSync sidecar in a Kubernetes cluster. It allows you to run Airflow jobs within a Kubernetes environment.

## Project Structure

```
|-- dags/
|-- docs/
|-- helm/
    |-- values.yaml: 
|-- scripts/
    |-- install_k8s_secrets.sh
    |-- install_local_dependencies.sh
    |-- run_airflow_local.sh
|-- src/
    |-- Dockerfile
    |-- requirements.txt
|-- Makefile
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

### Create PersinsteVolume and Secrets

You will also need to setup a PersistenVolume with **ReadWriteMany** mode. Besides, it is important to create the following secrets:

1. airflow-fernet-key: This secret should contain the Fernet key used for encryption and decryption in Airflow.
2. airflow-gitsync: This secret should contain the necessary credentials to access your Git repository for syncing DAGs.

In order to set up the PV and Secrets, run the following steps:
    1. Edit the file fernet-key with you desired key
    2. Run the following command:
        ```bash
        make setup-prerequisites
        ```
        This command will create both secrets and also create a PersisteVolume

### Local Deployment

To deploy Airflow locally, use the following steps:

1. Start Minikube to set up a local Kubernetes cluster:

```bash
minikube start
```

2. Configure Minikube to use the Docker daemon inside the Minikube cluster:

```bash
eval $(minikube docker-env)
```

3. Build the Airflow Docker image and push it to the local Docker registry:

```bash
make build
make push
```

4. Install the Airflow Helm chart with the provided values.yaml file:

```bash
make deploy
```

5. Monitor the deployment and wait for all Airflow pods to be in a running state:

```bash
kubectl get pods --namespace airflow --watch
```

6. Once all the pods are running, you can access the Airflow web UI using the following command:

```bash
minikube service airflow-web -n airflow
```

7. Enable and run Airflow DAGs through the web UI, and monitor the job progress.

Remember to clean up the resources after you finish by running:

```bash
helm uninstall airflow --namespace airflow
kubectl delete secret airflow-fernet-key --namespace airflow
kubectl delete secret airflow-gitsync --namespace airflow
```

These steps will set up and deploy Airflow locally using Minikube and Helm, allowing you to test and run Airflow jobs in a local Kubernetes environment.

## References
1. [Airflow - Customizing the image](https://airflow.apache.org/docs/docker-stack/build.html#customizing-the-image)