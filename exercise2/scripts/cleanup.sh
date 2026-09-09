#!/usr/bin/env bash
# Bash Cleanup Script for Kubernetes Exercise 2
set -e

echo "================================================================"
echo "🧹 Cleaning up Kubernetes Exercise 2 Resources..."
echo "================================================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

kubectl delete -f "$PROJECT_ROOT/flask-deployment.yaml" --ignore-not-found=true

echo ""
echo "✅ Resources cleaned up successfully!"
