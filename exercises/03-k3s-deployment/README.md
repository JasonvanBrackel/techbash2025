# Exercise 3: Setup K3s and Deploy .NET Application

**Duration:** 20 minutes  
**Objective:** Install K3s, deploy your containerized .NET API, and expose it with Kubernetes

## Prerequisites
- Docker image from Exercise 2 (pushed to Docker Hub)
- Admin/sudo access on your machine
- kubectl installed

## What You'll Learn
- Install K3s locally
- Understand Kubernetes manifests (YAML)
- Deploy a containerized application
- Expose applications with Services
- Access and test your deployment

---

## Part 1: Install K3s

### Windows (using WSL2)

```bash
# In WSL2 terminal
curl -sfL https://get.k3s.io | sh -

# Check installation
sudo k3s kubectl get nodes
```

### macOS

```bash
# Install using brew
brew install k3s

# Or use k3d (K3s in Docker)
brew install k3d
k3d cluster create workshop
```

### Linux

```bash
# Install K3s
curl -sfL https://get.k3s.io | sh -

# Check installation
sudo k3s kubectl get nodes
```

### Alternative: Use Docker Desktop Kubernetes

If K3s installation fails, enable Kubernetes in Docker Desktop:
1. Open Docker Desktop
2. Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"

### Step 1: Configure kubectl

```bash
# For K3s on Linux/WSL
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chmod 644 ~/.kube/config
export KUBECONFIG=~/.kube/config

# For K3d
k3d kubeconfig merge workshop --kubeconfig-switch-context

# For Docker Desktop
# kubectl is automatically configured
```

### Step 2: Verify Kubernetes is Running

```bash
kubectl get nodes

# Should show:
# NAME          STATUS   ROLES                  AGE   VERSION
# your-node     Ready    control-plane,master   30s   v1.28.x
```

---

## Part 2: Create Kubernetes Manifests

### Step 3: Create a Namespace

Create a file named `namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: workshop
  labels:
    name: workshop
    environment: development
```

Apply it:

```bash
kubectl apply -f namespace.yaml
kubectl get namespaces
```

### Step 4: Create a Deployment

Create a file named `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: weather-api
  namespace: workshop
  labels:
    app: weather-api
spec:
  replicas: 3
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
        image: yourusername/weather-api:latest  # Replace with your Docker Hub username
        ports:
        - containerPort: 8080
          name: http
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
        livenessProbe:
          httpGet:
            path: /weatherforecast
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /weatherforecast
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

**Important:** Replace `yourusername` with your actual Docker Hub username!

### Step 5: Create a Service

Create a file named `service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: weather-api-service
  namespace: workshop
  labels:
    app: weather-api
spec:
  type: LoadBalancer  # Change to NodePort if LoadBalancer isn't available
  selector:
    app: weather-api
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
```

### Step 6: (Optional) Create a ConfigMap

Create a file named `configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: weather-api-config
  namespace: workshop
data:
  app_name: "Weather API"
  log_level: "Information"
  feature_flags: "EnableSwagger=true"
```

---

## Part 3: Deploy to Kubernetes

### Step 7: Apply All Manifests

```bash
# Apply each manifest
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f configmap.yaml  # if created

# Or apply all at once
kubectl apply -f .
```

### Step 8: Watch the Deployment

```bash
# Watch pods being created
kubectl get pods -n workshop -w

# Press Ctrl+C to stop watching
```

You should see 3 pods start up:
```
NAME                           READY   STATUS    RESTARTS   AGE
weather-api-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
weather-api-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
weather-api-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
```

### Step 9: Check Deployment Status

```bash
# Get all resources in the namespace
kubectl get all -n workshop

# Describe the deployment
kubectl describe deployment weather-api -n workshop

# Check replica set
kubectl get rs -n workshop
```

---

## Part 4: Access Your Application

### Step 10: Get Service Details

```bash
kubectl get svc -n workshop

# For LoadBalancer type (K3s, cloud providers)
# Note the EXTERNAL-IP

# For NodePort type
# Note the PORT (e.g., 80:30XXX/TCP)
```

### Step 11: Access the Application

**If using LoadBalancer (K3s):**

```bash
# Get the external IP
EXTERNAL_IP=$(kubectl get svc weather-api-service -n workshop -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test the API
curl http://${EXTERNAL_IP}/weatherforecast

# Or in browser
echo "Open: http://${EXTERNAL_IP}/weatherforecast"
```

**If using NodePort:**

```bash
# Get the node port
NODE_PORT=$(kubectl get svc weather-api-service -n workshop -o jsonpath='{.spec.ports[0].nodePort}')

# Test the API (using localhost)
curl http://localhost:${NODE_PORT}/weatherforecast

# Or in browser
echo "Open: http://localhost:${NODE_PORT}/weatherforecast"
```

**If using Docker Desktop:**

```bash
# Forward the port
kubectl port-forward -n workshop svc/weather-api-service 8080:80

# In another terminal or browser
curl http://localhost:8080/weatherforecast
```

---

## Part 5: Explore and Debug

### Step 12: View Logs

```bash
# Get pod names
kubectl get pods -n workshop

# View logs from one pod
kubectl logs -n workshop <pod-name>

# Follow logs in real-time
kubectl logs -n workshop <pod-name> -f

# View logs from all pods with label
kubectl logs -n workshop -l app=weather-api
```

### Step 13: Execute Commands in Pod

```bash
# Get a shell in a pod
kubectl exec -it -n workshop <pod-name> -- /bin/bash

# Once inside:
# ls
# pwd
# env | grep ASPNETCORE
# exit
```

### Step 14: Describe Resources

```bash
# Describe deployment
kubectl describe deployment weather-api -n workshop

# Describe a pod
kubectl describe pod <pod-name> -n workshop

# Describe service
kubectl describe svc weather-api-service -n workshop
```

---

## Part 6: Test Kubernetes Features

### Step 15: Test Self-Healing

Delete a pod and watch Kubernetes recreate it:

```bash
# Get pod name
kubectl get pods -n workshop

# Delete one pod
kubectl delete pod <pod-name> -n workshop

# Watch it get recreated
kubectl get pods -n workshop -w
```

The ReplicaSet ensures 3 pods are always running!

### Step 16: Scale the Deployment

```bash
# Scale to 5 replicas
kubectl scale deployment weather-api -n workshop --replicas=5

# Watch the new pods start
kubectl get pods -n workshop -w

# Scale back down
kubectl scale deployment weather-api -n workshop --replicas=3
```

### Step 17: Update the Deployment

Update the image tag (if you have a new version):

```bash
# Update image
kubectl set image deployment/weather-api -n workshop \
  weather-api=yourusername/weather-api:v2.0

# Watch rolling update
kubectl rollout status deployment/weather-api -n workshop

# Check rollout history
kubectl rollout history deployment/weather-api -n workshop
```

### Step 18: Rollback (if needed)

```bash
# Rollback to previous version
kubectl rollout undo deployment/weather-api -n workshop

# Or rollback to specific revision
kubectl rollout undo deployment/weather-api -n workshop --to-revision=1
```

---

## Part 7: Cleanup

### Step 19: Delete Resources

```bash
# Delete all resources in namespace
kubectl delete all --all -n workshop

# Or delete individual resources
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
kubectl delete -f configmap.yaml

# Delete namespace
kubectl delete namespace workshop
```

---

## Key Kubernetes Concepts Review

### Deployment
- Declares desired state
- Manages ReplicaSets
- Enables rolling updates and rollbacks

### ReplicaSet
- Ensures specified number of pod replicas
- Created automatically by Deployment
- Provides self-healing

### Pod
- Smallest deployable unit
- One or more containers
- Shared network and storage

### Service
- Stable endpoint for pods
- Load balances across pod replicas
- Types: ClusterIP, NodePort, LoadBalancer

### ConfigMap
- Non-sensitive configuration data
- Injected as env vars or files

---

## Key Takeaways

✅ **K3s is a lightweight, production-ready Kubernetes**  
✅ **Deployments manage application lifecycle**  
✅ **Services provide stable networking**  
✅ **Kubernetes provides self-healing and scaling**  
✅ **kubectl is your primary interaction tool**  
✅ **YAML manifests define desired state**  

---

## Common Issues & Solutions

**Issue:** Image pull error  
**Solution:** Verify image exists on Docker Hub and is public. Check image name spelling.

**Issue:** Pods stuck in "Pending"  
**Solution:** Check resources: `kubectl describe pod <name> -n workshop`

**Issue:** Service has no EXTERNAL-IP  
**Solution:** Use NodePort or port-forward instead of LoadBalancer

**Issue:** Connection refused  
**Solution:** Verify pod is running and healthy: `kubectl get pods -n workshop`

**Issue:** K3s won't start  
**Solution:** Check if ports 6443, 443 are in use. Try k3d or Docker Desktop instead.

---

## Next Exercise

In Exercise 4, we'll package this application with Helm for easier deployment and configuration management!