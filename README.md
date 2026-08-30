# DevOps Lab Assignments & Exercises

Welcome to the **DevOps Engineering Laboratory Repository**. This repository contains hands-on labs and practical implementations for containerization, orchestration, CI/CD, and cloud-native architectures.

---

## 📂 Repository Structure

```tree
.
├── README.md
└── exercise1/                          # Kubernetes Exercise 1: Hello Pod
    ├── README.md                       # Comprehensive lab guide & instructions
    ├── manifests/                      # Declarative Kubernetes YAML manifests
    │   ├── pod.yaml                    # Standard Nginx Pod definition
    │   ├── service.yaml                # NodePort Service definition
    │   ├── zepto-storefront-configmap.yaml # Custom Zepto web storefront config
    │   └── zepto-storefront-pod.yaml   # Zepto Pod with custom HTML mounted
    ├── scripts/                        # Automation & helper scripts
    │   ├── deploy.sh                   # Linux / macOS / WSL automated deployment
    │   ├── deploy.ps1                  # Windows PowerShell automated deployment
    │   ├── cleanup.sh                  # Linux / macOS / WSL teardown script
    │   └── cleanup.ps1                 # Windows PowerShell teardown script
    └── app/                            # Application Assets
        └── index.html                  # Zepto Storefront & Delivery Status Web App
```

---

## 🚀 Exercises Overview

| Exercise | Topic | Description | Status |
| :--- | :--- | :--- | :--- |
| **[Exercise 1](./exercise1/README.md)** | **Kubernetes - Hello Pod** | Deploying Zepto's Storefront & Delivery App using Pods & Services | Completed |

---

## 🛠️ Prerequisites

- **Docker / Container Engine**
- **Minikube** (Local Kubernetes Cluster)
- **kubectl** (Kubernetes CLI)
- **Git**
