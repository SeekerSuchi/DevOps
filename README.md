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
└── exercise2/                          # Kubernetes Exercise 2: Deploy Flask App on Minikube
    ├── README.md                       # Comprehensive lab guide & Q&A
    ├── app.py                          # Flask application source code (port 15000)
    ├── Dockerfile                      # Docker container build definition
    ├── requirements.txt                # Python dependencies
    ├── flask-deployment.yaml           # Deployment & NodePort Service manifest
    ├── manifests/                      # Standalone YAML manifests
    │   ├── deployment.yaml             # Deployment manifest
    │   └── service.yaml                # NodePort Service manifest
    └── scripts/                        # Automation & helper scripts
        ├── deploy.sh                   # Linux / macOS / WSL automated deployment
        ├── deploy.ps1                  # Windows PowerShell automated deployment
        ├── cleanup.sh                  # Linux / macOS / WSL teardown script
        └── cleanup.ps1                 # Windows PowerShell teardown script
```

---

## 🚀 Exercises Overview

| Exercise | Topic | Description | Status |
| :--- | :--- | :--- | :--- |
| **[Exercise 1](./exercise1/README.md)** | **Kubernetes - Hello Pod** | Deploying Zepto's Storefront & Delivery App using Pods & Services | Completed |
| **[Exercise 2](./exercise2/README.md)** | **Deploy Flask App on Minikube** | Deploying Flask app via local Docker daemon, kubectl, Deployment & NodePort Service | Completed |

---

## 🛠️ Prerequisites

- **Docker / Container Engine**
- **Minikube** (Local Kubernetes Cluster)
- **kubectl** (Kubernetes CLI)
- **Git**
