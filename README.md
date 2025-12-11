# GitOps Workloads for AKS

This repository contains ArgoCD ApplicationSets and team configurations for managing workloads on AKS.

## Structure

```
.
├── apps/                                    # ArgoCD ApplicationSets
│   └── team-workloads-applicationset.yaml  # Generates apps from team configs
└── teams/                                   # Team workload configurations
    ├── team1.yaml                          # Team 1 configuration
    └── team2.yaml                          # Team 2 configuration
```

## How It Works

1. **Bootstrap Application** (`workloads.yaml`):
   - Applied directly to the ArgoCD namespace
   - Points to the `apps/` directory in this repo
   - Deploys the ApplicationSet

2. **ApplicationSet** (`apps/team-workloads-applicationset.yaml`):
   - Uses Git File Generator
   - Reads all YAML files from `teams/` directory
   - Creates one ArgoCD Application per team configuration

3. **Team Configurations** (`teams/*.yaml`):
   - Each file defines a team's workload
   - Fields:
     - `team`: Team identifier
     - `repoURL`: Git repository containing the workload
     - `targetRevision`: Branch/tag to deploy
     - `path`: Path within the repository
     - `namespace`: Kubernetes namespace for deployment
     - `helmChart`: (Optional) Helm chart name
     - `valuesFile`: (Optional) Helm values file

## Adding a New Team

1. Create a new file in `teams/` directory (e.g., `team3.yaml`)
2. Define the team configuration:
   ```yaml
   team: team3
   repoURL: https://github.com/your-org/your-repo
   targetRevision: main
   path: path/to/manifests
   namespace: team3-workloads
   helmChart: my-chart  # Optional
   valuesFile: values.yaml  # Optional
   ```
3. Commit and push
4. ArgoCD will automatically create the application

## Deployment

```bash
# Apply the bootstrap application
kubectl apply -f workloads.yaml -n argocd

# Verify ApplicationSet is created
kubectl get applicationset -n argocd

# Verify team applications are generated
kubectl get applications -n argocd
```

## Troubleshooting

- Check ApplicationSet status: `kubectl describe applicationset team-workloads -n argocd`
- Check generated applications: `kubectl get applications -n argocd -l team`
- View ArgoCD UI for detailed sync status
