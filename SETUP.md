# Complete Setup Guide

## What I've Created

I've rebuilt your GitOps workloads setup from scratch with proper ArgoCD ApplicationSet configuration.

## File Structure

```
gitops-workloads-aks/
├── apps/
│   └── team-workloads-applicationset.yaml   # ApplicationSet that generates apps
├── teams/
│   ├── team1.yaml                           # Team 1 configuration
│   └── team2.yaml                           # Team 2 configuration
├── README.md                                # Documentation
├── validate.ps1                             # Validation script
└── SETUP.md                                 # This file
```

## How It Works

### 1. Bootstrap Application
**File**: `aks-platform-engineering/terraform/bootstrap/workloads.yaml`

This is the root application that you apply directly to ArgoCD:
- Points to the `apps/` directory in the gitops-workloads-aks repo
- Deploys the ApplicationSet to ArgoCD

### 2. ApplicationSet
**File**: `apps/team-workloads-applicationset.yaml`

Uses the **Git File Generator** to:
- Scan all `*.yaml` files in the `teams/` directory
- Read the configuration from each file
- Generate one ArgoCD Application per team

**Key Features**:
- Uses `goTemplate: true` for Go template syntax
- Properly quotes all template variables
- Supports both Helm charts and plain manifests
- Includes error checking with `missingkey=error`

### 3. Team Configurations
**Files**: `teams/team1.yaml`, `teams/team2.yaml`

Each team file defines:
```yaml
team: team1                    # Team identifier
repoURL: <git-repo-url>        # Where the workload code lives
targetRevision: main           # Branch/tag to deploy
path: <path-in-repo>           # Path to manifests/chart
namespace: team1-workloads     # K8s namespace
helmChart: my-app              # (Optional) Helm chart name
valuesFile: values.yaml        # (Optional) Helm values file
```

## Deployment Steps

### Step 1: Delete Old Resources (if any)
```powershell
# Delete the old application
kubectl delete application workloads -n argocd

# Delete old ApplicationSets (if any)
kubectl delete applicationset team-workloads-apps -n argocd
kubectl delete applicationset team-workloads-generator -n argocd
```

### Step 2: Apply Bootstrap Application
```powershell
kubectl apply -f C:\Users\rmkp\Documents\Azure-platform-engineering\aks-platform-engineering\terraform\bootstrap\workloads.yaml
```

### Step 3: Verify Deployment
```powershell
# Check the bootstrap application
kubectl get application workloads -n argocd

# Check the ApplicationSet was created
kubectl get applicationset -n argocd

# Check team applications were generated
kubectl get applications -n argocd

# Run validation script
cd C:\Users\rmkp\Documents\Azure-platform-engineering\gitops-workloads-aks
.\validate.ps1
```

### Step 4: Monitor in ArgoCD UI
- Open ArgoCD UI
- Look for the "workloads" application
- It should show the ApplicationSet
- The ApplicationSet should generate "team1" and "team2" applications

## Key Differences from Previous Version

1. **Simplified Structure**: Only one ApplicationSet instead of multiple
2. **Proper Go Templates**: All variables use correct syntax (e.g., `{{ .team }}`)
3. **Clean Team Configs**: Simple, flat YAML structure
4. **Better Error Handling**: Added `missingkey=error` to catch template issues
5. **Documentation**: Added README and this setup guide

## Troubleshooting

### Check ApplicationSet Status
```powershell
kubectl describe applicationset team-workloads -n argocd
```

### Check Generated Applications
```powershell
kubectl get applications -n argocd -o yaml
```

### View ArgoCD Logs
```powershell
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-applicationset-controller
```

### Common Issues

**Issue**: "Failed to unmarshal"
- **Cause**: Invalid YAML syntax in team files
- **Fix**: Validate YAML files using `validate.ps1`

**Issue**: "Template error"
- **Cause**: Missing required fields in team config
- **Fix**: Ensure all required fields are present (team, repoURL, targetRevision, path, namespace)

**Issue**: Applications not generated
- **Cause**: Git File Generator can't find team files
- **Fix**: Verify files exist in `teams/*.yaml` and are valid YAML

## Adding New Teams

1. Create new file: `teams/team3.yaml`
2. Add configuration:
   ```yaml
   team: team3
   repoURL: https://github.com/your-org/your-repo
   targetRevision: main
   path: path/to/app
   namespace: team3-workloads
   ```
3. Commit and push
4. ArgoCD will auto-generate the application

## Next Steps

1. Apply the bootstrap application
2. Verify in ArgoCD UI
3. Add more teams as needed
4. Customize team configurations (add Helm values, etc.)
