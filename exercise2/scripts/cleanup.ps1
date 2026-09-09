# PowerShell Cleanup Script for Kubernetes Exercise 2
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "🧹 Cleaning up Kubernetes Exercise 2 Resources..." -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Cyan

kubectl delete -f "$PSScriptRoot\..\flask-deployment.yaml" --ignore-not-found=true

Write-Host "`n✅ Resources cleaned up successfully!" -ForegroundColor Green
