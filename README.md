# Application install & usage
Required tools:
- Python 3.10 (or latest): https://www.python.org/downloads/release/python-3100/
- Docker (Docker Desktop/Rancher/etc.): https://www.docker.com/products/docker-desktop/
- Kubernetes (EKS/minikube/k3d/etc.): https://minikube.sigs.k8s.io/docs/start/

## Setting Environment Up
### Creating .env file
Using the env.example, create a .env file with the required variables:
- `MONGO_URI` - the URI to the MongoDB instance (including a user & pass if wanted)
- `FLASK_ENV` - development/production (depending on environment location)
- `PORT` - the Port under which Flask will be running (5000 default recommended)

### Creating MongoDB Auth
To create the MongoDB username & password we must store it under Docker Secrets for the Docker Swarm deployment or in Kubernetes Secrets for the Kubernetes Deployment.

1. Docker Swarm deployment
    For the Docker Swarm deployment we must add the username & password in the secrets:

## Building the app
To build the application you can run the `build.bat` script under `scripts/`

```sh
Usage: build.bat
Description: the script will build the docker image and push it to the Docker & Minikube Image Registry
```

## Deploying the kubernetes services
To deploy the kubernetes services such as the app, monitoring, db, etc. run the `deploy-infra.bat` script under `scripts/`

```sh
Usage: deploy-infra.bat [app|logging|mongodb|monitoring|all]
Description: the script will start deploying the selected service, or all services if wanted, in the correct order of dependency
```

## Deploying the app to Docker/Kubernetes
To deploy the application to Docker or Kubernetes, run the `deploy-app.bat` script under `scripts/`

```sh
Usage: deploy-app.bat [docker|k8s]
Description: the script will deploy the application to either a Docker container or a K8s Deployment
```

## Manual deploy to Docker
You can use the `docker-compose.yml` to start the service under Docker via the command:

```sh
docker-compose up
```

# DevOps Test Requirements
## 1. Dockerize the Application
### Dockerfile
Create a Dockerfile for the Python application. ✅
This file should:
- include instructions to install all necessary dependencies ✅
- expose the correct port ✅
- incorporate configurations managed by an appropriate .env file ✅

### Build and Test Locally
Use Docker commands to build an image from the Dockerfile and run a container locally ✅
Ensure the application functions correctly within the container ✅

## 2. Deploy with Kubernetes
### Kubernetes Deployment YAML File
Write a YAML file to describe how Kubernetes should deploy the Docker container ✅
Include specifications such as:
- the container image ✅
- resource requirements ✅
- number of replicas ✅
- and other configurations ✅

### LoadBalancer Service
Configure a LoadBalancer service in Kubernetes to enable external access to the application ✅

### Horizontal Pod Autoscaler (HPA)
Include a configuration for Horizontal Pod Autoscaler (HPA) to automatically scale the application based on CPU usage ✅

## 3. Setup Prometheus Monitoring
### Prometheus Configuration
Configure Prometheus to monitor the application by specifying which metrics to scrape. ✅
This may include system metrics or custom application metrics. ✅

### Deploy Prometheus within Kubernetes Cluster
Deploy Prometheus as a container within the Kubernetes cluster to enable scraping metrics from the application. ✅

### Visualize Metrics
Visualize the Prometheus metrics through a simple dashboard ✅

## 4. Integrate with ELK Stack
### Filebeat Configuration
Configure Filebeat to watch the application's log files and ship them to Elasticsearch. ✅

### Elasticsearch
Ensure Elasticsearch is running within the environment to store and index the logs sent from Filebeat. ✅

### Kibana
Set up Kibana to visualize the logs stored in Elasticsearch. ✅
Create a dashboard in Kibana to display key information from the application's logs. ✅

