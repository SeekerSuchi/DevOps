# DevOps Lab Assignments & Exercises

Welcome to the **DevOps Engineering Laboratory Repository**. This repository contains hands-on labs and practical implementations for containerization, orchestration, CI/CD, and cloud-native architectures.

---

## 📂 Repository Structure

```tree
.
├── README.md
├── exercise1/                          # Kubernetes Exercise 1: Hello Pod
│   ├── README.md                       # Comprehensive lab guide & instructions
│   ├── manifests/                      # Declarative Kubernetes YAML manifests
│   │   ├── pod.yaml                    # Standard Nginx Pod definition
│   │   ├── service.yaml                # NodePort Service definition
│   │   ├── zepto-storefront-configmap.yaml # Custom Zepto web storefront config
│   │   └── zepto-storefront-pod.yaml   # Zepto Pod with custom HTML mounted
│   ├── scripts/                        # Automation & helper scripts
│   │   ├── deploy.sh                   # Linux / macOS / WSL automated deployment
│   │   ├── deploy.ps1                  # Windows PowerShell automated deployment
│   │   ├── cleanup.sh                  # Linux / macOS / WSL teardown script
│   │   └── cleanup.ps1                 # Windows PowerShell teardown script
│   └── app/                            # Application Assets
│       └── index.html                  # Zepto Storefront & Delivery Status Web App
├── exercise2/                          # Kubernetes Exercise 2: Deploy Flask App on Minikube
│   ├── README.md                       # Comprehensive lab guide & Q&A
│   ├── app.py                          # Flask application source code (port 15000)
│   ├── Dockerfile                      # Docker container build definition
│   ├── requirements.txt                # Python dependencies
│   ├── flask-deployment.yaml           # Deployment & NodePort Service manifest
│   ├── manifests/                      # Standalone YAML manifests
│   │   ├── deployment.yaml             # Deployment manifest
│   │   └── service.yaml                # NodePort Service manifest
│   └── scripts/                        # Automation & helper scripts
│       ├── deploy.sh                   # Linux / macOS / WSL automated deployment
│       ├── deploy.ps1                  # Windows PowerShell automated deployment
│       ├── cleanup.sh                  # Linux / macOS / WSL teardown script
│       └── cleanup.ps1                 # Windows PowerShell teardown script
├── exercise3/                          # Kubernetes Exercise 3: Scaling with ReplicaSets
│   ├── README.md                       # Lab guide, steps & Q&A
│   ├── app.py                          # Flash Sale Flask app (/, /buy, /health)
│   ├── Dockerfile                      # Container build definition (gunicorn)
│   └── flashsale-replicaset.yaml       # ReplicaSet + ClusterIP Service manifest
└── exercise4/                          # Docker Exercise 4: Multi-Container Networking
    ├── README.md                       # Lab guide & Q&A
    ├── app.py                          # Simple Flask REST API (/about endpoint)
    ├── requirements.txt                # Python dependencies (Flask==2.0.1)
    └── Dockerfile                      # Docker container build definition
```

---

## 🚀 Exercises Overview

| Exercise | Topic | Description | Status |
| :--- | :--- | :--- | :--- |
| **[Exercise 1](./exercise1/README.md)** | **Kubernetes - Hello Pod** | Deploying Zepto's Storefront & Delivery App using Pods & Services | Completed |
| **[Exercise 2](./exercise2/README.md)** | **Deploy Flask App on Minikube** | Deploying Flask app via local Docker daemon, kubectl, Deployment & NodePort Service | Completed |
| **[Exercise 3](./exercise3/README.md)** | **Scaling with ReplicaSets** | Flash Sale scenario — scaling a Flask app from 3 to 5 pods, observing self-healing on a single-node Minikube cluster | Completed |
| **[Exercise 4](./exercise4/README.md)** | **Docker Networking** | Multi-container app with Flask, MySQL & Redis on a custom bridge network; testing inter-container DNS resolution | Completed |

---

## 🛠️ Prerequisites

- **Docker / Container Engine**
- **Minikube** (Local Kubernetes Cluster)
- **kubectl** (Kubernetes CLI)
- **Git**
