# PowerShell Deployment Script for Kubernetes Exercise 1
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🚀 Zepto DevOps Lab - Kubernetes Exercise 1: Hello Pod" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

# Check Minikube Status
$minikubeStatus = minikube status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚡ Starting Minikube cluster..." -ForegroundColor Yellow
    minikube start
} else {
    Write-Host "✅ Minikube is already running." -ForegroundColor Green
}

Write-Host "`n📦 Deploying hello-k8s Pod..." -ForegroundColor Yellow
kubectl apply -f "$PSScriptRoot\..\manifests\pod.yaml"

Write-Host "⚡ Deploying NodePort Service..." -ForegroundColor Yellow
kubectl apply -f "$PSScriptRoot\..\manifests\service.yaml"

Write-Host "`n⏳ Waiting for Pod readiness..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready pod/hello-k8s --timeout=90s

Write-Host "`n📋 Deployed Resources:" -ForegroundColor Cyan
kubectl get pods -l app=zepto-storefront
kubectl get svc hello-k8s-service

Write-Host "`n🎉 Deployment Completed!" -ForegroundColor Green
Write-Host "🌐 Launch your application with:" -ForegroundColor Cyan
Write-Host "   minikube service hello-k8s-service" -ForegroundColor White
