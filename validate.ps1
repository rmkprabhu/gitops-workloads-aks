# Validation script for ArgoCD ApplicationSet setup
# This script helps verify the YAML files are valid

Write-Host "=== Validating GitOps Workloads Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check if kubectl is available
try {
    kubectl version --client --short 2>&1 | Out-Null
    Write-Host "✓ kubectl is available" -ForegroundColor Green
} catch {
    Write-Host "✗ kubectl not found" -ForegroundColor Red
    exit 1
}

# Validate YAML files
Write-Host ""
Write-Host "=== Validating YAML Files ===" -ForegroundColor Cyan

$files = @(
    "apps\team-workloads-applicationset.yaml",
    "teams\team1.yaml",
    "teams\team2.yaml"
)

foreach ($file in $files) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        Write-Host "Checking $file..." -NoNewline
        try {
            # Try to parse as YAML using kubectl
            kubectl apply --dry-run=client -f $fullPath 2>&1 | Out-Null
            Write-Host " ✓" -ForegroundColor Green
        } catch {
            Write-Host " ✗" -ForegroundColor Red
            Write-Host "  Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ File not found: $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Checking ArgoCD Resources ===" -ForegroundColor Cyan

# Check if ArgoCD is running
try {
    kubectl get namespace argocd 2>&1 | Out-Null
    Write-Host "✓ ArgoCD namespace exists" -ForegroundColor Green
    
    # Check ApplicationSets
    Write-Host ""
    Write-Host "ApplicationSets:" -ForegroundColor Yellow
    kubectl get applicationset -n argocd 2>&1
    
    Write-Host ""
    Write-Host "Applications:" -ForegroundColor Yellow
    kubectl get applications -n argocd 2>&1
    
} catch {
    Write-Host "✗ ArgoCD namespace not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Validation Complete ===" -ForegroundColor Cyan
