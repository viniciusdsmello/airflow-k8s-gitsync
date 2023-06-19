IMAGE_NAME = "viniciusdsmello/airflow-k8s"
VERSION = "v1.0.0"
SERVICE_NAME = "airflow"
NAMESPACE = "default"

start-minikube:
	minikube start --cpus 4 --memory 7859
	minikube addons enable ingress
	minikube addons enable ingress-dns
	minikube update-context

stop-minikube:
	minikube stop

setup-k8s-prerequisites:
	@echo "Setting up prerequisites..."
	kubectl apply -f helm/pv.yaml
	kubectl create secret generic airflow-fernet-key --from-file=fernet-key=$PWD/fernet-key
	kubectl create secret generic airflow-gitsync --from-file=id_rsa=$HOME/.ssh/id_rsa
	kubectl create secret generic airflow-postgres --from-file=postgres-user=$PWD/postgres-user --from-file=postgres-password=$PWD/postgres-password

build:
	@echo "Building $(IMAGE_NAME):$(VERSION)..."
	docker build -t $(IMAGE_NAME):$(VERSION) src/

push:
	@echo "Pushing $(IMAGE_NAME):$(VERSION)..."
	docker push $(IMAGE_NAME):$(VERSION)

deploy-prod:
	@echo "Deploying $(IMAGE_NAME):$(VERSION) to Kubernetes..."
	helm upgrade --install --namespace $(NAMESPACE) $(SERVICE_NAME) helm/airflow/ -f helm/values.yaml --set airflow.image.repository=$(IMAGE_NAME) --set airflow.image.tag=$(VERSION)

deploy-local:
	@echo "Deploying $(IMAGE_NAME):$(VERSION) to Kubernetes..."
	helm upgrade --install --namespace $(NAMESPACE) $(SERVICE_NAME) helm/airflow/ -f helm/values_local.yaml --set airflow.image.repository=$(IMAGE_NAME) --set airflow.image.tag=$(VERSION)

dry-run-prod:
	@echo "Dry running $(IMAGE_NAME):$(VERSION) to Kubernetes..."
	helm upgrade --install --namespace $(NAMESPACE) $(SERVICE_NAME) helm/airflow/ -f helm/values.yaml --set airflow.image.repository=$(IMAGE_NAME) --set airflow.image.tag=$(VERSION) --dry-run	

dry-run-local:
	@echo "Dry running $(IMAGE_NAME):$(VERSION) to Kubernetes..."
	helm upgrade --install --namespace $(NAMESPACE) $(SERVICE_NAME) helm/airflow/ -f helm/values_local.yaml --set airflow.image.repository=$(IMAGE_NAME) --set airflow.image.tag=$(VERSION) --dry-run	

generate-yaml-prod:
	@echo "Generating yaml files..."
	helm template --namespace $(NAMESPACE) $(SERVICE_NAME) helm/airflow/ -f helm/values.yaml --set airflow.image.repository=$(IMAGE_NAME) --set airflow.image.tag=$(VERSION) --output-dir k8s/production

generate-yaml-local:
	@echo "Generating yaml files..."
	helm template --namespace $(NAMESPACE) $(SERVICE_NAME) helm/airflow/ -f helm/values_local.yaml --set airflow.image.repository=$(IMAGE_NAME) --set airflow.image.tag=$(VERSION) --output-dir k8s/local

cleanup:
	@echo "Cleaning up airflow deployment and persistent volume..."
	helm delete airflow || exit 0;
	kubectl delete secret airflow-fernet-key
	kubectl delete secret airflow-gitsync
	kubectl delete pv airflow-logs-pv
