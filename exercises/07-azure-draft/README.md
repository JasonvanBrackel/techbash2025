# Exercise 7: Generating Kubernetes Manifests with Azure Draft

**Duration:** 20 minutes
**Objective:** Use Azure Draft to automatically generate Kubernetes manifests and Dockerfiles from source code

## Prerequisites
- Azure Draft CLI installed
- Docker Desktop running
- Kubernetes cluster running (K3s or Docker Desktop)
- .NET 8 SDK or Node.js installed
- kubectl configured

## What You'll Learn
- Install and configure Azure Draft
- Auto-generate Dockerfiles from application code
- Auto-generate Kubernetes manifests from Docker images
- Auto-generate Helm charts
- Customize Draft templates
- Compare manual vs. Draft-generated configurations

---

## Part 1: Install Azure Draft

### Step 1: Install Draft

**Windows (using winget):**
```powershell
winget install Microsoft.Azure.Draft
```

**Windows (using Chocolatey):**
```powershell
choco install azure-draft
```

**macOS:**
```bash
brew install azure/draft/draft
```

**Linux:**
```bash
# Download latest release
DRAFT_VERSION=0.0.36
curl -fsSL -o draft.tar.gz https://github.com/Azure/draft/releases/download/v${DRAFT_VERSION}/draft-linux-amd64.tar.gz

# Extract and install
tar -xzf draft.tar.gz
sudo mv linux-amd64/draft /usr/local/bin/draft

# Verify installation
draft version
```

### Step 2: Verify Installation

```bash
draft version

# Should show:
# Version: v0.0.x
```

---

## Part 2: Generate Dockerfile with Draft

### Step 3: Create a Sample Application

**For .NET:**
```bash
# Create a new directory
mkdir draft-demo
cd draft-demo

# Create a simple .NET API
dotnet new webapi -n DraftApi --no-https
cd DraftApi
```

**For Node.js:**
```bash
# Create a new directory
mkdir draft-demo
cd draft-demo

# Initialize a simple Express app
npm init -y
npm install express

# Create index.js
cat > index.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Draft!' });
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
EOF
```

### Step 4: Generate Dockerfile with Draft

```bash
# Let Draft detect your application type and create a Dockerfile
draft create

# Draft will:
# 1. Detect the language/framework
# 2. Ask for confirmation
# 3. Generate an optimized Dockerfile
```

**You'll be prompted to select:**
- Language version
- Deployment type (e.g., Kubernetes, Helm)
- Additional options

### Step 5: Review Generated Dockerfile

```bash
# View the generated Dockerfile
cat Dockerfile
```

**For .NET, you'll see something like:**
```dockerfile
# Multi-stage build automatically generated
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["DraftApi.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "DraftApi.dll"]
```

### Step 6: Compare with Manual Dockerfile

**Key observations:**
- ✅ Multi-stage build for optimization
- ✅ Layer caching with separate restore
- ✅ Proper base image selection
- ✅ Security best practices
- ✅ .dockerignore file included

```bash
# Draft also generates .dockerignore
cat .dockerignore
```

---

## Part 3: Generate Kubernetes Manifests

### Step 7: Build the Docker Image

```bash
# Build the image
docker build -t draft-api:v1.0 .

# Verify image
docker images draft-api
```

### Step 8: Generate Kubernetes Manifests with Draft

```bash
# Generate K8s manifests
draft generate-manifest

# Draft will create:
# - deployment.yaml
# - service.yaml
# - namespace.yaml (optional)
```

**You'll be prompted for:**
- Application name
- Namespace
- Port mappings
- Replica count
- Resource limits

### Step 9: Review Generated Manifests

**Check the deployment:**
```bash
cat manifests/deployment.yaml
```

You should see a complete deployment with:
- Proper labels and selectors
- Health checks (liveness/readiness probes)
- Resource requests and limits
- Environment variables
- Security contexts

**Check the service:**
```bash
cat manifests/service.yaml
```

You should see:
- Service type (ClusterIP, LoadBalancer, etc.)
- Port configuration
- Proper selectors

---

## Part 4: Generate Helm Chart with Draft

### Step 10: Generate Helm Chart

```bash
# Generate a complete Helm chart
draft generate-chart

# This creates:
# charts/
# ├── Chart.yaml
# ├── values.yaml
# └── templates/
#     ├── deployment.yaml
#     ├── service.yaml
#     ├── _helpers.tpl
#     └── NOTES.txt
```

### Step 11: Review Generated Chart

```bash
# View the chart metadata
cat charts/Chart.yaml

# View default values
cat charts/values.yaml

# View the templated deployment
cat charts/templates/deployment.yaml
```

**Key features:**
- Parameterized with Go templates
- Environment-specific values support
- Best practices included
- Helper functions defined

### Step 12: Customize Values

Edit `charts/values.yaml` to customize:

```yaml
replicaCount: 3

image:
  repository: yourusername/draft-api
  pullPolicy: IfNotPresent
  tag: "v1.0"

service:
  type: LoadBalancer
  port: 80
  targetPort: 8080

resources:
  limits:
    cpu: 500m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

---

## Part 5: Deploy with Draft-Generated Resources

### Step 13: Deploy Using Generated Manifests

```bash
# Create namespace
kubectl create namespace draft-demo

# Apply manifests
kubectl apply -f manifests/ -n draft-demo

# Watch deployment
kubectl get pods -n draft-demo -w
```

### Step 14: Deploy Using Generated Helm Chart

```bash
# Install with Helm
helm install draft-api charts/ -n draft-demo

# Check status
helm status draft-api -n draft-demo

# Verify deployment
kubectl get all -n draft-demo
```

### Step 15: Test the Application

```bash
# Get service details
kubectl get svc -n draft-demo

# For LoadBalancer:
EXTERNAL_IP=$(kubectl get svc draft-api -n draft-demo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://${EXTERNAL_IP}

# For NodePort or port-forward:
kubectl port-forward -n draft-demo svc/draft-api 8080:80

# In another terminal:
curl http://localhost:8080
```

---

## Part 6: Advanced Draft Features

### Step 16: Update Application with Draft Workflow

```bash
# Make changes to your code
# For example, update the API response

# Draft can update manifests automatically
draft update

# This regenerates manifests based on code changes
```

### Step 17: Use Draft with GitHub Actions

Draft can generate CI/CD workflows:

```bash
# Generate GitHub Actions workflow
draft generate-workflow github

# This creates .github/workflows/draft.yaml
cat .github/workflows/draft.yaml
```

The workflow includes:
- Build Docker image
- Push to registry
- Deploy to Kubernetes
- Run tests

### Step 18: Customize Draft Templates

Draft uses customizable templates:

```bash
# View available templates
draft info

# Set custom template location
draft set-config template-location=/path/to/templates

# Create custom template
draft create --template=custom-dotnet
```

---

## Part 7: Compare Manual vs. Draft Approach

### Time Comparison

**Manual Approach (from Exercises 2-4):**
- Write Dockerfile: ~10 minutes
- Write K8s manifests: ~15 minutes
- Create Helm chart: ~20 minutes
- **Total: ~45 minutes**

**Draft Approach:**
- Generate Dockerfile: ~2 minutes
- Generate manifests: ~2 minutes
- Generate Helm chart: ~3 minutes
- **Total: ~7 minutes**

### Quality Comparison

**Manual Benefits:**
- Full control over every detail
- Custom optimizations
- Deep understanding of configuration

**Draft Benefits:**
- ✅ Consistent best practices
- ✅ Faster iteration
- ✅ Reduced human error
- ✅ Auto-updates with code changes
- ✅ Template reusability across teams

---

## Part 8: Cleanup

```bash
# Uninstall Helm release
helm uninstall draft-api -n draft-demo

# Or delete manifests
kubectl delete -f manifests/ -n draft-demo

# Delete namespace
kubectl delete namespace draft-demo

# Remove local images (optional)
docker rmi draft-api:v1.0
```

---

## Key Draft Concepts Review

### Auto-Detection
- Draft analyzes your source code
- Detects language and framework
- Suggests appropriate configurations

### Templates
- Pre-built configurations for common scenarios
- Customizable and extensible
- Language-specific optimizations

### Generators
- `draft create` - Generate Dockerfile
- `draft generate-manifest` - Generate K8s YAML
- `draft generate-chart` - Generate Helm chart
- `draft generate-workflow` - Generate CI/CD

### Integration
- Works with existing toolchains
- Supports multiple deployment targets
- Integrates with CI/CD pipelines

---

## Key Takeaways

✅ **Draft accelerates Kubernetes adoption**
✅ **Auto-generates production-ready configurations**
✅ **Reduces boilerplate and errors**
✅ **Enforces best practices automatically**
✅ **Customizable for specific needs**
✅ **Great for teams standardizing deployments**

---

## Real-World Use Cases

### Use Draft When:
- Starting new projects
- Standardizing across multiple services
- Onboarding developers to Kubernetes
- Prototyping quickly
- Maintaining consistency across teams

### Stick with Manual When:
- Highly customized requirements
- Learning Kubernetes deeply
- Fine-tuning performance
- Complex multi-service architectures
- Existing mature configurations

---

## Bonus Challenges

### Challenge 1: Multi-Service Application

Create a multi-service app with Draft:

```bash
# Frontend
mkdir frontend
cd frontend
npm init -y
draft create

# Backend
cd ../
mkdir backend
dotnet new webapi -n Backend
cd backend
draft create

# Generate manifests for both
cd ..
draft generate-manifest --app=frontend
draft generate-manifest --app=backend
```

### Challenge 2: Add Custom Healthchecks

Edit Draft-generated deployment to add custom health endpoints:

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 30
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 5
```

### Challenge 3: Integrate with Azure Container Registry

```bash
# Generate manifests for ACR
draft generate-manifest --registry=myregistry.azurecr.io

# This configures:
# - Image pull secrets
# - Correct registry URLs
# - Azure-specific annotations
```

### Challenge 4: Create Custom Template

Create a custom Draft template for your organization's standards:

```bash
# Create template directory
mkdir -p ~/.draft/templates/my-org-dotnet

# Copy and customize templates
cp -r ~/.draft/templates/dotnet/* ~/.draft/templates/my-org-dotnet/

# Edit templates to match your standards
# - Add required labels
# - Set default resource limits
# - Include monitoring annotations

# Use custom template
draft create --template=my-org-dotnet
```

---

## Common Issues & Solutions

**Issue:** Draft doesn't detect my language
**Solution:** Ensure required files exist (e.g., `.csproj`, `package.json`). Use `--language` flag to specify.

**Issue:** Generated manifests missing features
**Solution:** Edit generated files or customize templates. Draft creates a starting point.

**Issue:** Port conflicts in generated config
**Solution:** Edit manifests to change ports or use `--port` flag during generation.

**Issue:** Resource limits too high/low
**Solution:** Adjust `values.yaml` or manifests directly after generation.

**Issue:** Draft command not found
**Solution:** Verify installation and add to PATH. Check with `draft version`.

---

## Draft Command Reference

```bash
# Core commands
draft create                    # Generate Dockerfile
draft generate-manifest         # Generate K8s manifests
draft generate-chart           # Generate Helm chart
draft generate-workflow        # Generate CI/CD workflow
draft update                   # Update configurations

# Configuration
draft set-config               # Set Draft configuration
draft get-config               # View Draft configuration
draft info                     # Show Draft information

# Templates
draft list-templates           # List available templates
draft create --template=NAME   # Use specific template

# Help
draft help                     # Show help
draft version                  # Show version
```

---

## Additional Resources

- [Azure Draft GitHub](https://github.com/Azure/draft)
- [Draft Documentation](https://draft.sh)
- [Custom Templates Guide](https://github.com/Azure/draft/blob/main/docs/templates.md)
- [Draft Best Practices](https://github.com/Azure/draft/blob/main/docs/best-practices.md)

---

## Next Steps

Now that you've seen how Draft can accelerate development:

1. Combine Draft with GitOps (Exercise 5) for complete automation
2. Use Draft templates across your organization
3. Integrate Draft into your CI/CD pipelines
4. Create custom templates for your tech stack
5. Explore Draft's Azure integration features

**Key Insight:** Draft doesn't replace understanding Kubernetes—it accelerates implementation once you know the fundamentals. Use it as a productivity tool, not a crutch.
