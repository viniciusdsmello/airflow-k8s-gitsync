IMAGE_NAME = "viniciusdsmello/airflow-k8s"
VERSION = "latest"
SERVICE_NAME = "airflow"
NAMESPACE = "default"

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

deploy:
	@echo "Deploying $(IMAGE_NAME):$(VERSION) to Kubernetes..."
	helm upgrade --namespace $(NAMESPACE) \
	--install $(SERVICE_NAME) helm/$(SERVICE_NAME)\
	--set airflow.image.repository=$(IMAGE_NAME) \
	--set airflow.image.tag=$(VERSION)
	
