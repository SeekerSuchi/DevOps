#!/usr/bin/env bash
# Bash Deployment Script for Kubernetes Exercise 2: Deploy a Flask App on Minikube
set -e

echo "================================================================"
echo "🚀 Kubernetes Exercise 2: Flask App Deployment on Minikube"
echo "================================================================"

# 1. Verify Minikube status
if ! minikube status >/dev/null 2>&1; then
    echo "⚡ Starting Minikube cluster..."
    minikube start
else
    echo "✅ Minikube is running."
fi

# 2. Configure Minikube Docker environment and build image
echo ""
echo "🐳 Configuring Minikube's Docker daemon..."
eval $(minikube docker-env)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔨 Building Docker image (flask-app:latest) inside Minikube..."
docker build -t flask-app:latest "$PROJECT_ROOT"

# 3. Apply Kubernetes Deployment & Service Manifest
echo ""
echo "📦 Applying Kubernetes manifests..."
kubectl apply -f "$PROJECT_ROOT/flask-deployment.yaml"

# 4. Wait for Pod to be Ready
echo ""
echo "⏳ Waiting for Flask Pod to become Ready..."
kubectl rollout status deployment/flask-app --timeout=120s

# 5. Resource summary
echo ""
echo "📋 Deployment Status:"
kubectl get deployments -l app=flask-app
echo ""
echo "📋 Pods:"
kubectl get pods -l app=flask-app
echo ""
echo "📋 Services:"
kubectl get svc flask-app-service

# 6. Retrieve service URL
echo ""
echo "🎉 Deployment completed successfully!"
echo "🌐 Obtain the access URL using:"
echo "   minikube service flask-app-service --url"
echo ""
echo "Or open the service directly in your browser with:"
echo "   minikube service flask-app-service"
