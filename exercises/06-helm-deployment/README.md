# Exercise 6: Deploy Application with Helm

**Duration:** 15 minutes  
**Objective:** Create a Helm chart for your .NET API and deploy to multiple environments

## Prerequisites
- Helm CLI installed (v3.x)
- Kubernetes cluster running (K3s or Docker Desktop)
- Weather API image from Exercise 2

## What You'll Learn
- Create a Helm chart from scratch
- Parameterize Kubernetes manifests
- Deploy to different environments (dev, staging, prod)
- Upgrade and rollback releases
- Manage values and overrides

---

## Part 1: Install and Verify Helm

### Step 1: Install Helm (if not already installed)

**Windows:**
```powershell
choco install kubernetes-helm
```

**macOS:**
```bash
brew install helm
```

**Linux:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Step 2: Verify Installation

```bash
helm version

# Should show version 3.x.x
```

---

## Part 2: Create a Helm Chart

### Step 3: Create Chart Structure

```bash
# Create a new Helm chart
helm create weather-api-chart

# View the structure
tree weather-api-chart
# Or on Windows: dir weather-api-chart /s
```

You'll see:
```
weather-api-chart/
├── Chart.yaml           # Chart metadata
├── values.yaml          # Default values
├── charts/              # Dependencies
└── templates/           # Kubernetes manifests
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── _helpers.tpl
    └── tests/
```

### Step 4: Update Chart Metadata

Edit `weather-api-chart/Chart.yaml`:

```yaml
apiVersion: v2
name: weather-api
description: A Helm chart for Weather API .NET application
type: application
version: 1.0.0
appVersion: "1.0"
maintainers:
  - name: Your Name
    email: your.email@example.com
keywords:
  - dotnet
  - api
  - weather
```

### Step 5: Configure Default Values

Edit `weather-api-chart/values.yaml`:

```yaml
# Default values for weather-api
replicaCount: 3

image:
  repository: yourusername/weather-api  # Change to your Docker Hub username
  pullPolicy: IfNotPresent
  tag: "latest"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext: {}
  # fsGroup: 2000

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

service:
  type: LoadBalancer
  port: 80
  targetPort: 8080

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: weather-api.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 500m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity: {}

# Application-specific configuration
env:
  aspnetcoreEnvironment: Production
  logLevel: Information

configMap:
  enabled: true
  data:
    app_name: "Weather API"
    feature_flags: "EnableSwagger=true"
```

### Step 6: Update Deployment Template

Edit `weather-api-chart/templates/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "weather-api.fullname" . }}
  labels:
    {{- include "weather-api.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "weather-api.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "weather-api.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "weather-api.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: {{ .Chart.Name }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: {{ .Values.service.targetPort }}
          protocol: TCP
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: {{ .Values.env.aspnetcoreEnvironment | quote }}
        - name: LOG_LEVEL
          value: {{ .Values.env.logLevel | quote }}
        {{- if .Values.configMap.enabled }}
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: {{ include "weather-api.fullname" . }}-config
              key: app_name
        {{- end }}
        livenessProbe:
          httpGet:
            path: /weatherforecast
            port: http
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /weatherforecast
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

### Step 7: Create ConfigMap Template

Create `weather-api-chart/templates/configmap.yaml`:

```yaml
{{- if .Values.configMap.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "weather-api.fullname" . }}-config
  labels:
    {{- include "weather-api.labels" . | nindent 4 }}
data:
  {{- range $key, $value := .Values.configMap.data }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
{{- end }}
```

---

## Part 3: Create Environment-Specific Values

### Step 8: Create Development Values

Create `values-dev.yaml`:

```yaml
replicaCount: 1

image:
  tag: "latest"

env:
  aspnetcoreEnvironment: Development
  logLevel: Debug

service:
  type: NodePort

resources:
  limits:
    cpu: 200m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi

configMap:
  enabled: true
  data:
    app_name: "Weather API - DEV"
    feature_flags: "EnableSwagger=true,EnableDebug=true"
```

### Step 9: Create Staging Values

Create `values-staging.yaml`:

```yaml
replicaCount: 2

image:
  tag: "v1.0"

env:
  aspnetcoreEnvironment: Staging
  logLevel: Information

service:
  type: LoadBalancer

resources:
  limits:
    cpu: 300m
    memory: 192Mi
  requests:
    cpu: 75m
    memory: 96Mi

configMap:
  enabled: true
  data:
    app_name: "Weather API - STAGING"
    feature_flags: "EnableSwagger=true"
```

### Step 10: Create Production Values

Create `values-prod.yaml`:

```yaml
replicaCount: 5

image:
  tag: "v1.0"

env:
  aspnetcoreEnvironment: Production
  logLevel: Warning

service:
  type: LoadBalancer

resources:
  limits:
    cpu: 500m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

configMap:
  enabled: true
  data:
    app_name: "Weather API - PRODUCTION"
    feature_flags: "EnableSwagger=false"
```

---

## Part 4: Deploy with Helm

### Step 11: Validate Your Chart

```bash
# Lint the chart
helm lint weather-api-chart

# Dry-run to see generated manifests
helm install weather-api-dev weather-api-chart \
  --values values-dev.yaml \
  --dry-run --debug
```

### Step 12: Deploy to Development

```bash
# Create dev namespace
kubectl create namespace dev

# Install to dev
helm install weather-api-dev weather-api-chart \
  --values values-dev.yaml \
  --namespace dev

# Check status
helm status weather-api-dev -n dev

# Verify deployment
kubectl get all -n dev
```

### Step 13: Deploy to Staging

```bash
# Create staging namespace
kubectl create namespace staging

# Install to staging
helm install weather-api-staging weather-api-chart \
  --values values-staging.yaml \
  --namespace staging

# Verify
kubectl get all -n staging
```

### Step 14: Deploy to Production

```bash
# Create prod namespace
kubectl create namespace prod

# Install to prod
helm install weather-api-prod weather-api-chart \
  --values values-prod.yaml \
  --namespace prod

# Verify
kubectl get all -n prod
```

---

## Part 5: Manage Helm Releases

### Step 15: List Releases

```bash
# List all releases
helm list --all-namespaces

# List releases in specific namespace
helm list -n dev
```

### Step 16: Upgrade a Release

Update `values-dev.yaml` to change replica count:

```yaml
replicaCount: 2
```

Then upgrade:

```bash
helm upgrade weather-api-dev weather-api-chart \
  --values values-dev.yaml \
  --namespace dev

# Watch the rollout
kubectl rollout status deployment -n dev
```

### Step 17: View Release History

```bash
helm history weather-api-dev -n dev
```

### Step 18: Rollback a Release

```bash
# Rollback to previous version
helm rollback weather-api-dev -n dev

# Or rollback to specific revision
helm rollback weather-api-dev 1 -n dev

# Verify rollback
helm history weather-api-dev -n dev
```

### Step 19: Override Values from Command Line

```bash
# Override specific values
helm upgrade weather-api-dev weather-api-chart \
  --values values-dev.yaml \
  --set replicaCount=3 \
  --set image.tag=v2.0 \
  --namespace dev
```

---

## Part 6: Advanced Helm Features

### Step 20: View Generated Manifests

```bash
# See what Helm will deploy
helm get manifest weather-api-dev -n dev

# Template the chart locally
helm template weather-api-dev weather-api-chart \
  --values values-dev.yaml
```

### Step 21: Get Values for a Release

```bash
# Show all values for a release
helm get values weather-api-dev -n dev

# Show all values including defaults
helm get values weather-api-dev -n dev --all
```

### Step 22: Export Chart as Package

```bash
# Package the chart
helm package weather-api-chart

# Creates: weather-api-1.0.0.tgz
```

---

## Part 7: Cleanup

### Step 23: Uninstall Releases

```bash
# Uninstall dev release
helm uninstall weather-api-dev -n dev

# Uninstall staging release
helm uninstall weather-api-staging -n staging

# Uninstall prod release
helm uninstall weather-api-prod -n prod

# Delete namespaces
kubectl delete namespace dev
kubectl delete namespace staging
kubectl delete namespace prod
```

---

## Key Helm Concepts Review

### Chart
- Package of Kubernetes manifests
- Reusable and shareable
- Versioned

### Release
- Instance of a chart running in cluster
- Has unique name
- Tracked by Helm

### Values
- Configuration parameters
- Can be overridden per environment
- Multiple files can be combined

### Templates
- Go templating for Kubernetes YAML
- Dynamic manifest generation
- Reusable components

---

## Key Takeaways

✅ **Helm simplifies Kubernetes deployments**  
✅ **Values files enable environment-specific configs**  
✅ **Templates make manifests reusable**  
✅ **Releases are tracked and can be rolled back**  
✅ **Charts can be packaged and shared**  
✅ **Helm manages the complete lifecycle**  

---

## Bonus Challenges

### Challenge 1: Add a Secret

Create a secret template in `templates/secret.yaml`:

```yaml
{{- if .Values.secret.enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "weather-api.fullname" . }}-secret
  labels:
    {{- include "weather-api.labels" . | nindent 4 }}
type: Opaque
data:
  {{- range $key, $value := .Values.secret.data }}
  {{ $key }}: {{ $value | b64enc | quote }}
  {{- end }}
{{- end }}
```

Add to `values.yaml`:

```yaml
secret:
  enabled: false
  data: {}
```

### Challenge 2: Add Ingress

Enable ingress in `values-dev.yaml`:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: weather-api-dev.local
      paths:
        - path: /
          pathType: Prefix
```

### Challenge 3: Create a Dependency

Add a Redis cache dependency in `Chart.yaml`:

```yaml
dependencies:
  - name: redis
    version: "17.x.x"
    repository: "https://charts.bitnami.com/bitnami"
    condition: redis.enabled
```

---

## Common Issues & Solutions

**Issue:** Chart lint fails  
**Solution:** Check YAML syntax and template errors

**Issue:** Values not applied  
**Solution:** Verify values file path and keys match templates

**Issue:** Upgrade fails  
**Solution:** Check `helm history` and use `--force` flag if needed

**Issue:** Template errors  
**Solution:** Use `helm template` to debug locally

---

## Next Exercise

In Exercise 5, we'll implement GitOps with Flux to automatically deploy when you push to Git!