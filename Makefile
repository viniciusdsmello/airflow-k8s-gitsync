IMAGE_NAME = "viniciusdsmello/airflow-k8s"
VERSION = "v3"
SERVICE_NAME = "airflow"
NAMESPACE = "default"


setup-prerequisites:
	@echo "Setting up prerequisites..."
	kubectl apply -f helm/pv.yaml

setup-local:
	@echo "Setting up local environment..."
	sh scripts/install_local_dependencies.sh
	sh scripts/start_local_airflow.sh

build:
	@echo "Building $(IMAGE_NAME):$(VERSION)..."
	docker build -t $(IMAGE_NAME):$(VERSION) src/

push:
	@echo "Pushing $(IMAGE_NAME):$(VERSION)..."
	docker push $(IMAGE_NAME):$(VERSION)

deploy: setup-prerequisites
	@echo "Deploying $(IMAGE_NAME):$(VERSION) to Kubernetes..."
	helm upgrade --install --namespace $(NAMESPACE) $(SERVICE_NAME) helm/airflow/ -f helm/values.yaml --set airflow.image.repository=$(IMAGE_NAME) --set airflow.image.tag=$(VERSION)
	
cleanup:
	helm delete airflow
	kubectl delete pv airflow-logs-pv