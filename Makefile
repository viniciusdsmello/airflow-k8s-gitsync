IMAGE_NAME = "viniciusdsmello/airflow-k8s"
VERSION = "v1.0.0"
SERVICE_NAME = "airflow"
NAMESPACE = "default"

start-minikube:
	minikube start --cpus 4 --memory 7859
	minikube addons enable ingress
	minikube update-context

stop-minikube:
	minikube stop

setup-k8s-prerequisites:
	@echo "Setting up prerequisites..."
	kubectl apply -f helm/pv.yaml
	sh scripts/install_k8s_secrets.sh

build:
	@echo "Building $(IMAGE_NAME):$(VERSION)..."
	docker build -t $(IMAGE_NAME):$(VERSION) src/

push:
	@echo "Pushing $(IMAGE_NAME):$(VERSION)..."
	docker push $(IMAGE_NAME):$(VERSION)

deploy:
	@echo "Deploying $(IMAGE_NAME):$(VERSION) to Kubernetes..."
	helm upgrade --install --namespace $(NAMESPACE) $(SERVICE_NAME) helm/airflow/ -f helm/values.yaml --set airflow.image.repository=$(IMAGE_NAME) --set airflow.image.tag=$(VERSION)
	
cleanup:
	@echo "Cleaning up airflow deployment and persistent volume..."
	helm delete airflow || exit 0;
	kubectl delete secret airflow-fernet-key
	kubectl delete secret airflow-gitsync
	kubectl delete pv airflow-logs-pv

reinstall: cleanup deploy