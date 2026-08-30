#!/usr/bin/env bash

echo "🧹 Cleaning up Exercise 1 Kubernetes resources..."

kubectl delete service hello-k8s hello-k8s-service zepto-service --ignore-not-found
kubectl delete pod hello-k8s zepto-storefront --ignore-not-found
kubectl delete configmap zepto-storefront-html --ignore-not-found

echo "✅ Cleanup finished."
