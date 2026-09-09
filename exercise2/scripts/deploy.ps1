# PowerShell Deployment Script for Kubernetes Exercise 2: Deploy a Flask App on Minikube
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "🚀 Kubernetes Exercise 2: Flask App Deployment on Minikube" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan

# 1. Verify Minikube status
$minikubeStatus = minikube status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚡ Starting Minikube cluster..." -ForegroundColor Yellow
    minikube start
} else {
    Write-Host "✅ Minikube is running." -ForegroundColor Green
}

# 2. Configure Minikube Docker environment and build image
Write-Host "`n🐳 Configuring Minikube's Docker daemon..." -ForegroundColor Yellow
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

Write-Host "🔨 Building Docker image (flask-app:latest) inside Minikube..." -ForegroundColor Yellow
docker build -t flask-app:latest "$PSScriptRoot\.."

# 3. Apply Kubernetes Deployment & Service Manifest
Write-Host "`n📦 Applying Kubernetes manifests..." -ForegroundColor Yellow
kubectl apply -f "$PSScriptRoot\..\flask-deployment.yaml"

# 4. Wait for Pod to be Ready
Write-Host "`n⏳ Waiting for Flask Pod to become Ready..." -ForegroundColor Yellow
kubectl rollout status deployment/flask-app --timeout=120s

# 5. Resource summary
Write-Host "`n📋 Deployment Status:" -ForegroundColor Cyan
kubectl get deployments -l app=flask-app
Write-Host "`n📋 Pods:" -ForegroundColor Cyan
kubectl get pods -l app=flask-app
Write-Host "`n📋 Services:" -ForegroundColor Cyan
kubectl get svc flask-app-service

# 6. Retrieve service URL
Write-Host "`n🎉 Deployment completed successfully!" -ForegroundColor Green
Write-Host "🌐 Obtain the access URL using:" -ForegroundColor Cyan
Write-Host "   minikube service flask-app-service --url" -ForegroundColor White
Write-Host "`nOr open the service directly in your browser with:" -ForegroundColor Cyan
Write-Host "   minikube service flask-app-service" -ForegroundColor White
