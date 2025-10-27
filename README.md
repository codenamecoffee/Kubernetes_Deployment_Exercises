## 🧩 Kubernetes Deployment Exercises

This repository contains guided Kubernetes deployment exercises completed during the School of Software Engineering (Endava, 2025) training program.
The goal was to understand the fundamentals of Kubernetes orchestration, both locally (Kind) and in the Azure cloud (AKS).

These exercises demonstrate how to deploy a containerized application (Movie Shop API) to a Kubernetes cluster, manage deployments and services, and observe Kubernetes features such as scaling, load balancing, and self-healing.

<br>

## 🎯 Learning Objectives

- Understand Kubernetes architecture, clusters, and namespaces.

- Learn how to:
  - Create a local Kubernetes cluster using Kind.
  - Deploy applications from Azure Container Registry (ACR).
  - Configure and manage Azure Kubernetes Service (AKS).
  - Work with Deployments, Services, and RBAC (Role-Based Access Control).
  - Observe load balancing, pod lifecycle, and cluster scaling.

- Gain practical experience with kubectl, Docker, and Azure CLI.

<br>

## 🗂️ Project Structure

```
├── ejercicios/
│   ├── ejercicio-aks/                # Deployment to Azure Kubernetes Service
│   │   ├── create-aks-cluster.sh         # Script to create AKS cluster and connect to ACR
│   │   ├── deploy-to-acr.sh              # Builds and pushes Docker image to Azure Container Registry
│   │   ├── deployment-v1.yaml            # Initial deployment manifest (v1)
│   │   ├── deployment-latest.yaml        # Updated deployment manifest (latest version)
│   │   ├── service.yaml                  # LoadBalancer service exposing the API
│   │   ├── role-student-deployer.yaml    # Role definition for limited access
│   │   ├── rolebinding-student.yaml      # Role binding for student access
│   │   └── ejercicio-deploy-acr-aks.md   # Full guided AKS exercise documentation
│   │
│   └── ejercicio-kind/             # Deployment to local Kind cluster
│       ├── setup-kind-cluster.sh         # Creates and configures Kind cluster
│       ├── deploy-to-acr.sh              # Loads Docker image from ACR into Kind
│       ├── deployment.yaml               # Local deployment manifest
│       └── ejercicio-deploy-acr-kind.md  # Full guided Kind exercise documentation
│
└── README.md                     # This documentation file

```

<br>

## 🧰 Prerequisites

Before running the exercises, ensure you have the following tools installed and configured:

- Docker (required)

- Kubectl – Kubernetes CLI

- Azure CLI – for login and AKS management

- Kind – for local Kubernetes cluster (optional, only for the Kind exercise)

- Access to an Azure account with permissions to create AKS and ACR resources

<br>

> ⚠️ These exercises were originally designed for guided corporate training.
The scripts and manifests are still educationally useful, but running them outside Azure may require configuration changes (e.g., different registry or cluster names).

<br>

## 🚀 Exercises Overview

### 1️⃣ AKS Deployment (ejercicio-aks)

This exercise demonstrates deploying a containerized API from Azure Container Registry (ACR) to an Azure Kubernetes Service (AKS) cluster.
Main steps covered:

You will:

- Build and push a Docker image to ACR.

- Create an AKS cluster connected to that ACR.

- Deploy and expose the app with a Service (LoadBalancer).

- Scale the deployment and observe load balancing.

- Apply role-based access control for limited users.

<br>

📘 Full guide available here: [ejercicio-deploy-acr-aks.md](ejercicios/ejercicio-aks/ejercicio-deploy-acr-aks.md)

<hr>

<br>

### 2️⃣ Local Deployment with Kind (ejercicio-kind/)

This exercise covers the same deployment flow but using a local cluster created with Kind.
It allows experimenting safely with Kubernetes concepts such as deployments, scaling, and self-healing.

You will:

- Create a local cluster with setup-kind-cluster.sh.

- Load a Docker image from ACR into Kind.

- Deploy and expose the app using port-forwarding.

- Observe pod behavior, scaling, and self-healing in action.

<br>

📘 Full guide available here: [ejercicio-deploy-acr-kind.md](ejercicios/ejercicio-kind/ejercicio-deploy-acr-kind.md)

<br>

## 🧠 Key Takeaways

- Kubernetes is declarative: it ensures the system’s actual state matches the desired state.

- AKS provides scalability and resilience on the cloud.

- Kind allows local simulation of real Kubernetes environments.

- Deployments and Services define how applications run and communicate.

- RBAC enables secure, role-based access control to cluster resources.

<br>

## 👥 Authors

Developed as part of the School of Software Engineering - Endava (2025)
Contributors:

- Federico González Lage
- Clemente Reyes (Endava)

<br>

## 🪪 License

This repository is distributed for educational purposes only under the MIT License.

<br>

## 🎓 Educational Context

This repository was developed during the *School of Software Engineering (Endava, 2025)* as a learning activity to practice container orchestration concepts.
It is not intended for production deployment, but as a technical demonstration of Kubernetes fundamentals using both **Kind** (local) and **AKS** (cloud) environments.
