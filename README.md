# Airflow with KubernetesExecutor + GitSync sidecar

## Overview

This repository contains the necessary steps and configurations to deploy Airflow with KubernetesExecutor and GitSync sidecar in a Kubernetes cluster. It allows you to run Airflow jobs within a Kubernetes environment.

## Project Structure

```
|-- dags/
|-- helm/
    |-- airflow/
        |-- files/
            |-- webserver_config.py: Airflow Webserver's config file
        |-- templates/
    |-- pv.yaml: PersistentVolume definition
    |-- values.yaml: Contains all values used to deploy to production 
    |-- values_local.yaml: Contains all values used to deploy to local environment, i.e., postgres/pgbouncer
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
- helm/: Includes the Helm chart configuration files, such as values.yaml, which holds the configuration values for Airflow deployment.
- scripts/: Contains various scripts for installing Kubernetes secrets, local dependencies, and running Airflow locally.
- src/: Holds the Dockerfile and requirements.txt file necessary for building the Airflow Docker image.
- Makefile: Provides convenience commands for building and running the project.

## Setup

### Prerequisites

Before proceeding, ensure that you have the following prerequisites installed:

1. Docker: Required for building the Airflow Docker image.
1. Minikube: Needed for setting up a local Kubernetes cluster.
1. [Make](https://linuxhint.com/install-make-ubuntu/): Required for executing `make` commands
1. [Helm](https://helm.sh/docs/intro/install/): Required for deploying Airflow using the Helm package manager.
1. [Kubectl](https://kubernetes.io/pt-br/docs/tasks/tools/#kubectl): Required for connecting to Kubernetes API

#### Create PersinsteVolume and Secrets

You will also need to setup a PersistenVolume with **ReadWriteMany** mode. This is important so all Airflow Pods can save logs in a shared volume.

Besides, it is important to create the following secrets:

1. airflow-fernet-key: This secret should contain the Fernet key used for encryption and decryption in Airflow.
2. airflow-gitsync: This secret should contain the necessary credentials to access your Git repository for syncing DAGs.

In order to set up the PV and Secrets, run the following steps:

1. Edit the file `fernet-key` with you desired key

### Build Docker Image

To build Airflow image, use the following steps:

1. Build the Airflow Docker image and push it to the local Docker registry:

    ```bash
    make build
    make push
    ```

### Local Deployment

To deploy Airflow locally, use the following steps:

1. Start Minikube, create the PersistentVolume and Secrets, then deploy airflow:

    ```bash
    minikube start
    make setup-k8s-prerequisites
    make deploy-local
    ```

1. Monitor the deployment and wait for all Airflow pods to be in a running state:

    ```bash
    kubectl get pods --watch
    ```

1. Once all the pods are running, you can access the Airflow web UI using the following command:

    ```bash
    kubectl port-forward svc/airflow-web 8080:8080
    ```

1. Enable and run Airflow DAGs through the web UI, and monitor the job progress.

Remember to clean up the resources after you finish by running:

```bash
make cleanup
```

These steps will set up and deploy Airflow locally using Minikube and Helm, allowing you to test and run Airflow jobs in a local Kubernetes environment.

### Production Deploymnet

In order to deploy Airflow to a Production environment we need to setup an external Postgres database and guarantee that we can create a PersistentVolume with NFS.

Then, you will need to create the Kubernetes Secret with Postgres password:

```bash
kubectl create secret generic airflow-postgres \
    --from-file=postgresql-user=$PWD/postgres-user \
    --from-file=postgresql-password=$PWD/postgres-password
```

Note that the script above reads the postgres password from a local files (`postgres-user` and `postgres-password`) (do not commit this file).

After creating the secrets go to file `helm/values.yaml` and disable the key `postgresql.enabled`, like in the example below:

```yaml
...
postgresql:
  ## if the `stable/postgresql` chart is used
  ## [FAQ] https://github.com/airflow-helm/charts/blob/main/charts/airflow/docs/faq/database/embedded-database.md
  ## [WARNING] the embedded Postgres is NOT SUITABLE for production deployments of Airflow
  ## [WARNING] consider using an external database with `externalDatabase.*`
  enabled: false
...
```

Then, add the name of the recent created secrets to `externalDatabase`:

```yaml
## the name of a pre-created secret containing the external database user
## - if set, this overrides `externalDatabase.user`
##
userSecret: ""
...
## the name of a pre-created secret containing the external database password
## - if set, this overrides `externalDatabase.password`
##
passwordSecret: "airflow-postgres"
...
```

To setup an ingress you must go to `ingress.web`, enable the webserver's ingress and change the host. If tls is required you must provide the values to `ingress.web.tls`. Note that, we do not need to enable `flower` since it is only used by CeleryExecutor.

Finally, you must configure the gitSync authentication method (ssh or user/password). If you choose ssh and wants to your own `id_rsa` there nothing to change, but if you want to use user/password method you must change the script `scripts/install_k8s_secrets.sh` and replace the secret airflow-gitsync creation command with the following:

```bash
kubectl create secret generic airflow-gitsync --from-file=user=$PWD/github-user --from-file=password=$PWD/github-password
```

Note that you need to create the following files `github-user` and `github-password` before applying the changes.

Finally, review all values inside the file `helm/values.yaml` and execute the following commands to deploy the application to your cluster (make sure you have kubectl context set to production):

```bash
make deploy-prod
```

## References

1. [Airflow - Customizing the image](https://airflow.apache.org/docs/docker-stack/build.html#customizing-the-image)
1. [Install Makefile](https://linuxhint.com/install-make-ubuntu/)
1. [Installing Helm](https://helm.sh/docs/intro/install/)
