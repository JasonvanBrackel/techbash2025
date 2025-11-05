# Exercise 5: GitOps with Flux

**Duration:** 15 minutes  
**Objective:** Implement GitOps to automatically deploy applications from Git

## Prerequisites
- GitHub account
- Kubernetes cluster (K3s or Docker Desktop)
- kubectl configured
- Git installed
- GitHub personal access token (we'll create this)

## What You'll Learn
- Install Flux CLI and controllers
- Bootstrap Flux with GitHub
- Create GitOps repository structure
- Auto-deploy on Git commits
- Monitor reconciliation

---

## Part 1: Setup GitHub Repository

### Step 1: Create GitHub Personal Access Token

1. Go to GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Name: "Flux GitOps Workshop"
4. Select scopes:
   - ✅ repo (all)
   - ✅ admin:repo_hook (for webhooks)
5. Click "Generate token"
6. **Copy the token** - you won't see it again!

### Step 2: Export GitHub Credentials

```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-github-username>
```

**Windows PowerShell:**
```powershell
$env:GITHUB_TOKEN="<your-token>"
$env:GITHUB_USER="<your-github-username>"
```

---

## Part 2: Install Flux

### Step 3: Install Flux CLI

**macOS:**
```bash
brew install fluxcd/tap/flux
```

**Windows:**
```powershell
choco install flux
```

**Linux:**
```bash
curl -s https://fluxcd.io/install.sh | sudo bash
```

### Step 4: Verify Flux CLI

```bash
flux --version

# Check if cluster is ready for Flux
flux check --pre
```

---

## Part 3: Bootstrap Flux

### Step 5: Bootstrap Flux with GitHub

This command will:
- Create a GitHub repository (or use existing)
- Install Flux controllers in your cluster
- Configure Flux to watch the repository

```bash
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=workshop-gitops \
  --branch=main \
  --path=./clusters/dev \
  --personal
```

**What happens:**
1. Creates `workshop-gitops` repo in your GitHub account
2. Installs Flux in `flux-system` namespace
3. Creates initial structure in repo
4. Configures Flux to sync from repo

### Step 6: Verify Flux Installation

```bash
# Check Flux components
kubectl get pods -n flux-system

# Check Flux status
flux check

# View Flux resources
flux get all
```

---

## Part 4: Clone and Setup GitOps Repository

### Step 7: Clone Your GitOps Repository

```bash
git clone https://github.com/$GITHUB_USER/workshop-gitops.git
cd workshop-gitops
```

### Step 8: Create Application Structure

```bash
# Create directory structure
mkdir -p apps/weather-api
mkdir -p infrastructure/sources
```

### Step 9: Create Namespace

Create `apps/weather-api/namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: weather-api
  labels:
    toolkit.fluxcd.io/tenant: weather-api
```

### Step 10: Create HelmRepository Source

Create `infrastructure/sources/dockerhub.yaml`:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: weather-api-charts
  namespace: flux-system
spec:
  interval: 10m
  url: oci://registry-1.docker.io/yourusername  # If using OCI registry
```

Or for direct Git source, create `infrastructure/sources/weather-api-git.yaml`:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: weather-api
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/$GITHUB_USER/weather-api-manifests
  ref:
    branch: main
```

### Step 11: Create Deployment Manifests

Create `apps/weather-api/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: weather-api
  namespace: weather-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: weather-api
  template:
    metadata:
      labels:
        app: weather-api
    spec:
      containers:
      - name: weather-api
        image: yourusername/weather-api:latest  # Replace with your image
        ports:
        - containerPort: 8080
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
```

### Step 12: Create Service

Create `apps/weather-api/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: weather-api
  namespace: weather-api
spec:
  type: LoadBalancer
  selector:
    app: weather-api
  ports:
  - port: 80
    targetPort: 8080
```

### Step 13: Create Kustomization

Create `apps/weather-api/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: weather-api
resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
```

---

## Part 5: Configure Flux to Deploy Application

### Step 14: Create Flux Kustomization

Create `clusters/dev/weather-api-kustomization.yaml`:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: weather-api
  namespace: flux-system
spec:
  interval: 5m
  path: ./apps/weather-api
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: weather-api
      namespace: weather-api
  timeout: 2m
```

---

## Part 6: Commit and Watch GitOps in Action

### Step 15: Commit and Push Changes

```bash
git add .
git commit -m "Add weather-api application"
git push origin main
```

### Step 16: Watch Flux Reconcile

```bash
# Watch Flux reconciliation
flux get kustomizations --watch

# Watch Flux sources
flux get sources git --watch

# Watch in another terminal
kubectl get pods -n weather-api --watch
```

You should see:
1. Flux detects the Git commit
2. Flux reconciles the kustomization
3. Kubernetes creates the namespace
4. Deployment and Service are created
5. Pods start running

### Step 17: Verify Deployment

```bash
# Check all resources
kubectl get all -n weather-api

# Get service details
kubectl get svc -n weather-api

# Check Flux logs
flux logs --kind=Kustomization --name=weather-api
```

---

## Part 7: Test GitOps Workflow

### Step 18: Make a Change

Edit `apps/weather-api/deployment.yaml` and change replicas:

```yaml
spec:
  replicas: 5  # Changed from 2
```

### Step 19: Commit and Push

```bash
git add apps/weather-api/deployment.yaml
git commit -m "Scale to 5 replicas"
git push origin main
```

### Step 20: Watch Auto-Deployment

```bash
# Flux will automatically detect and apply changes
flux get kustomizations --watch

# Watch pods scale up
kubectl get pods -n weather-api --watch
```

Within 1-5 minutes (based on interval), you should see 5 pods running!

---

## Part 8: Advanced Flux Features

### Step 21: Suspend/Resume Reconciliation

```bash
# Suspend automatic reconciliation
flux suspend kustomization weather-api

# Make changes manually with kubectl
kubectl scale deployment weather-api -n weather-api --replicas=1

# Resume reconciliation (Flux will restore to Git state)
flux resume kustomization weather-api
```

### Step 22: Force Reconciliation

```bash
# Trigger immediate reconciliation (don't wait for interval)
flux reconcile kustomization weather-api --with-source
```

### Step 23: View Reconciliation Events

```bash
# Get kustomization status
flux get kustomization weather-api

# View events
kubectl describe kustomization weather-api -n flux-system

# View all Flux events
kubectl get events -n flux-system --sort-by='.lastTimestamp'
```

---

## Part 9: Image Automation (Bonus)

### Step 24: Setup Image Automation

Create `infrastructure/image-automation.yaml`:

```yaml
---
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: weather-api
  namespace: flux-system
spec:
  image: yourusername/weather-api
  interval: 1m
---
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: weather-api
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: weather-api
  policy:
    semver:
      range: 1.x.x
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageUpdateAutomation
metadata:
  name: weather-api
  namespace: flux-system
spec:
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: flux-system
  git:
    checkout:
      ref:
        branch: main
    commit:
      author:
        email: fluxcdbot@users.noreply.github.com
        name: fluxcdbot
      messageTemplate: |
        Automated image update
        
        Automation name: {{ .AutomationObject }}
    push:
      branch: main
  update:
    path: ./apps/weather-api
    strategy: Setters
```

### Step 25: Update Deployment for Image Automation

Edit `apps/weather-api/deployment.yaml`:

```yaml
spec:
  template:
    spec:
      containers:
      - name: weather-api
        image: yourusername/weather-api:1.0.0 # {"$imagepolicy": "flux-system:weather-api"}
```

Now when you push a new image with a semver tag (e.g., `v1.0.1`), Flux will automatically update the deployment!

---

## Part 10: Cleanup

### Step 26: Remove Application

```bash
# Delete from Git
rm -rf apps/weather-api
git add .
git commit -m "Remove weather-api"
git push origin main

# Flux will automatically remove resources
flux get kustomizations --watch
```

### Step 27: Uninstall Flux (Optional)

```bash
flux uninstall --silent
```

---

## GitOps Workflow Summary

```
┌─────────────┐
│   Developer │
└──────┬──────┘
       │ 1. Commit & Push
       ▼
┌─────────────┐
│  Git Repo   │
└──────┬──────┘
       │ 2. Flux watches
       ▼
┌─────────────┐
│    Flux     │
└──────┬──────┘
       │ 3. Reconciles
       ▼
┌─────────────┐
│ Kubernetes  │
└─────────────┘
```

---

## Key Flux Concepts

### GitRepository
- Source of truth for manifests
- Flux watches for changes

### Kustomization
- Defines what to apply from Git
- Health checks and dependencies
- Prune old resources

### HelmRelease
- Deploy Helm charts via GitOps
- Version pinning and values

### ImageRepository/Policy
- Watch container registries
- Auto-update images based on policy

---

## Key Takeaways

✅ **Git is the single source of truth**  
✅ **Flux continuously reconciles cluster with Git**  
✅ **Changes are tracked and auditable**  
✅ **Rollback is as simple as reverting a commit**  
✅ **No need for manual kubectl apply**  
✅ **Image automation keeps apps updated**  

---

## Common Issues & Solutions

**Issue:** Flux can't access GitHub  
**Solution:** Check GITHUB_TOKEN is valid and has correct permissions

**Issue:** Kustomization fails  
**Solution:** Check logs: `flux logs --kind=Kustomization --name=weather-api`

**Issue:** Changes not applied  
**Solution:** Check interval, or force: `flux reconcile kustomization weather-api`

**Issue:** Image automation not working  
**Solution:** Verify ImagePolicy range matches your tags

---

## Additional Resources

- **Flux Documentation:** https://fluxcd.io/docs/
- **Flux GitHub:** https://github.com/fluxcd/flux2
- **GitOps Principles:** https://opengitops.dev/

---

**Congratulations!** You've completed all exercises and now have a full GitOps workflow for your .NET applications!