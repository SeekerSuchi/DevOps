#!/usr/bin/env bash
set -e

echo "=================================================="
echo "🚀 Zepto DevOps Lab - Kubernetes Exercise 1: Hello Pod"
echo "=================================================="

# Check if Minikube is running
if ! minikube status > /dev/null 2>&1; then
    echo "⚡ Starting Minikube..."
    minikube start
else
    echo "✅ Minikube is already running."
fi

echo "📦 Deploying hello-k8s Pod..."
kubectl apply -f ../manifests/pod.yaml

echo "⚡ Deploying NodePort Service..."
kubectl apply -f ../manifests/service.yaml

echo "⏳ Waiting for hello-k8s Pod to be in Running state..."
kubectl wait --for=condition=Ready pod/hello-k8s --timeout=90s

echo "📋 Kubernetes Resources:"
kubectl get pods -l app=zepto-storefront
kubectl get svc hello-k8s-service

echo ""
echo "🎉 Deployment completed successfully!"
echo "🌐 Access your service with:"
echo "   minikube service hello-k8s-service"
