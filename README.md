# Wisecow

Cow Wisdom Web Server - A simple web server that serves random cow quotes using fortune and cowsay commands.

![Wisecow Logo](https://raw.githubusercontent.com/nyrahul/wisecow/main/wisecow-logo.png)

---

## Table of Contents

- [About](#about)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Kubernetes Deployment](#kubernetes-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [TLS/SSL Support](#tlsssl-support)
- [Scripts for Monitoring](#scripts-for-monitoring)
- [Contributing](#contributing)
- [License](#license)
- [Credits](#credits)
- [Contact](#contact)

---

## About

Wisecow is a lightweight web server built on Debian using `fortune-mod` and `cowsay` to display fun and inspirational cow wisdom messages. It is containerized with Docker and deployable on Kubernetes clusters. This project includes Kubernetes manifests, TLS implementation, and GitHub Actions CI/CD pipelines for fully automated build and deployment.

---

## Features

- Dockerized Wisecow web application
- Kubernetes manifests for deployment and service exposure
- TLS/SSL support for secure communication
- GitHub Actions workflow to automate build, push, and deploy
- Monitoring scripts for system and application health

---

## Prerequisites

Before running the project, ensure you have:

- Docker installed on your machine
- Kubernetes cluster ready (Minikube, Kind, or any cloud provider)
- kubectl CLI configured to interact with your Kubernetes cluster
- GitHub account and Docker Hub (or other container registry) account

---

## Installation

1. Clone the repository:

git clone https://github.com/bhushanmahajan0070/wisecow.git
cd wisecow


2. Build the Docker image locally:

docker build -t wisecow:local .


3. Run the container locally:
   
docker run -p 4499:4499 wisecow:local


4. Test the application:

curl http://localhost:4499


---

## Kubernetes Deployment

1. Modify `k8s/deployment.yaml` to update the image name to your pushed Docker image:

image: YOUR_DOCKERHUB_USERNAME/wisecow:latest

2. Apply Kubernetes manifests:
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml # if using ingress and TLS


3. Verify pods are running:
kubectl get pods -n wisecow


4. Port-forward to access Wisecow service locally:

kubectl port-forward -n wisecow service/wisecow-service 8080:4499
curl http://localhost:8080

---

## CI/CD Pipeline

This project includes a GitHub Actions workflow (`.github/workflows/ci-cd.yml`) that:

- Builds the Docker image on code push
- Pushes the image to Docker Hub
- Automatically deploys updated image to Kubernetes cluster

Make sure to add the following repository secrets in your GitHub repo for successful runs:

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD` (Docker Hub personal access token)
- `KUBECONFIG` (optional for deploying from GitHub Actions directly)

---

## TLS/SSL Support

Secure communication is enabled using self-signed TLS certificates and Kubernetes ingress. To generate and apply TLS:

1. Generate self-signed cert and key
2. Create Kubernetes TLS secret
3. Configure ingress resource with TLS references

Access the app securely via your configured domain or IP.

---

## Scripts for Monitoring

Included are two example monitoring scripts:

- **System Health Monitoring** (`system_health_monitor.py`) — monitors CPU, memory, disk, and running processes and logs alerts.
- **Application Health Checker** (`app_health_checker.py`) — checks HTTP status codes to verify if an app is up or down.

Use these scripts to integrate basic health checks in your environment.

---

## Contributing

Feel free to fork this repository, make improvements, and submit pull requests. Please adhere to standard GitHub etiquette.

---

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

---

## Credits

Thanks to [@nyrahul](https://github.com/nyrahul) for the original Wisecow application.

---

## Contact

For questions or help, open an issue or contact mahajanbhushan2005@gmail.com.



