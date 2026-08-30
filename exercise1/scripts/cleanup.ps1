# PowerShell Cleanup Script for Kubernetes Exercise 1
Write-Host "🧹 Cleaning up Exercise 1 Kubernetes resources..." -ForegroundColor Yellow

kubectl delete service hello-k8s hello-k8s-service zepto-service --ignore-not-found
kubectl delete pod hello-k8s zepto-storefront --ignore-not-found
kubectl delete configmap zepto-storefront-html --ignore-not-found

Write-Host "✅ Cleanup finished." -ForegroundColor Green
