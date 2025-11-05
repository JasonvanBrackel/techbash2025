# Simple Exercise: Deploy Nginx with K3s

**Duration:** 10 minutes  
**Objective:** Deploy your first application to Kubernetes using K3s

## What You'll Learn
- Install K3s on your local machine
- Deploy a web application to Kubernetes
- Expose the application to access it
- Verify the deployment works

---

## Part 1: Install K3s

### Windows (WSL2)
```bash
# Open WSL2 terminal
curl -sfL https://get.k3s.io | sh -

# Wait for K3s to start (about 30 seconds)
sleep 30

# Setup kubectl access
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
export KUBECONFIG=~/.kube/config
```

### macOS / Linux
```bash
# Install K3s
curl -sfL https://get.k3s.io | sh -

# Wait for K3s to start
sleep 30

# Setup kubectl access
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
export KUBECONFIG=~/.kube/config
```

### Verify Installation
```bash
kubectl get nodes

# Expected output:
# NAME          STATUS   ROLES                  AGE   VERSION
# your-machine  Ready    control-plane,master   30s   v1.28.x
```

---

## Part 2: Deploy Nginx

### Step 1: Create a Deployment

Create a file named `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

### Step 2: Apply the Deployment

```bash
kubectl apply -f nginx-deployment.yaml

# Output: deployment.apps/nginx-deployment created
```

### Step 3: Check Pod Status

```bash
# Watch pods start up
kubectl get pods -w

# Press Ctrl+C when all pods are Running
```

You should see 3 nginx pods:
```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-xxxxxxxxxx-xxxxx   1/1     Running   0          10s
nginx-deployment-xxxxxxxxxx-xxxxx   1/1     Running   0          10s
nginx-deployment-xxxxxxxxxx-xxxxx   1/1     Running   0          10s
```

---

## Part 3: Expose Nginx

### Step 4: Create a Service

Create a file named `nginx-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

### Step 5: Apply the Service

```bash
kubectl apply -f nginx-service.yaml

# Output: service/nginx-service created
```

### Step 6: Get Service Details

```bash
kubectl get svc nginx-service

# Wait for EXTERNAL-IP to appear (K3s uses localhost)
```

---

## Part 4: Access Nginx

### Step 7: Open in Browser

K3s will expose nginx on localhost:

```bash
# Get the service URL
kubectl get svc nginx-service

# For K3s, it typically uses localhost
# Open in browser: http://localhost

# Or use curl
curl http://localhost
```

You should see the **"Welcome to nginx!"** page!

---

## Part 5: Explore Your Deployment

### View All Resources

```bash
# See everything you created
kubectl get all

# Output shows:
# - 3 pods
# - 1 deployment
# - 1 replicaset
# - 1 service
```

### Describe the Deployment

```bash
kubectl describe deployment nginx-deployment
```

### View Pod Logs

```bash
# Get pod name
kubectl get pods

# View logs (replace <pod-name> with actual name)
kubectl logs <pod-name>
```

### Execute Command in Pod

```bash
# Get a shell inside a pod
kubectl exec -it <pod-name> -- /bin/bash

# Once inside, try:
# ls
# cat /usr/share/nginx/html/index.html
# exit
```

---

## Part 6: Scale and Update

### Scale Up

```bash
# Scale to 5 replicas
kubectl scale deployment nginx-deployment --replicas=5

# Watch new pods start
kubectl get pods -w
```

### Scale Down

```bash
# Scale back to 2 replicas
kubectl scale deployment nginx-deployment --replicas=2

# Watch pods terminate
kubectl get pods -w
```

### Update Nginx Version

```bash
# Update to a specific version
kubectl set image deployment/nginx-deployment nginx=nginx:1.25

# Watch rolling update
kubectl rollout status deployment/nginx-deployment
```

---

## Part 7: Test Self-Healing

### Delete a Pod

```bash
# Get pod name
kubectl get pods

# Delete one pod
kubectl delete pod <pod-name>

# Immediately check pods - Kubernetes creates a new one!
kubectl get pods -w
```

Kubernetes automatically replaces the deleted pod to maintain your desired replica count!

---

## Part 8: Customize Nginx

### Create a Custom HTML Page

Create a file named `nginx-configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-html
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>My K3s Demo</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 50px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }
            h1 { font-size: 3em; }
            p { font-size: 1.5em; }
        </style>
    </head>
    <body>
        <h1>🚀 Welcome to My K3s Cluster!</h1>
        <p>This is running on Kubernetes</p>
        <p>Pod: <span id="hostname"></span></p>
        <script>
            fetch('/').then(() => {
                document.getElementById('hostname').textContent = 
                    window.location.hostname;
            });
        </script>
    </body>
    </html>
```

Apply the ConfigMap:

```bash
kubectl apply -f nginx-configmap.yaml
```

### Update Deployment to Use ConfigMap

Edit `nginx-deployment.yaml` to add volume:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: nginx-html
```

Apply the update:

```bash
kubectl apply -f nginx-deployment.yaml

# Wait for rollout
kubectl rollout status deployment/nginx-deployment

# Refresh browser - you should see your custom page!
```

---

## Part 9: Cleanup

### Delete Everything

```bash
# Delete service
kubectl delete service nginx-service

# Delete deployment (also deletes pods and replicaset)
kubectl delete deployment nginx-deployment

# Delete configmap
kubectl delete configmap nginx-html

# Verify everything is gone
kubectl get all
```

### Uninstall K3s (Optional)

If you want to completely remove K3s:

```bash
# Uninstall K3s
sudo /usr/local/bin/k3s-uninstall.sh
```

---

## What You Learned

✅ **Installed K3s** - A lightweight Kubernetes distribution  
✅ **Created a Deployment** - Manages pods and replicas  
✅ **Created a Service** - Exposes pods to network traffic  
✅ **Scaled applications** - Changed replica count  
✅ **Updated applications** - Rolling update to new version  
✅ **Used ConfigMaps** - Injected configuration into pods  
✅ **Tested self-healing** - Kubernetes recreates failed pods  

---

## Key Concepts

### Deployment
- Declares desired state
- Manages ReplicaSets
- Enables updates and rollbacks

### ReplicaSet
- Ensures desired number of replicas
- Automatically created by Deployment
- Provides self-healing

### Service
- Stable network endpoint
- Load balances across pods
- Types: ClusterIP, NodePort, LoadBalancer

### Pod
- Smallest deployable unit
- Runs one or more containers
- Has its own IP address

---

## All-in-One YAML (Quick Deploy)

Want to deploy everything at once? Use this:

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-html
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>K3s Demo</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 50px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }
        </style>
    </head>
    <body>
        <h1>🚀 Welcome to K3s!</h1>
        <p>This is running on Kubernetes</p>
    </body>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: nginx-html
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

Save as `nginx-complete.yaml` and deploy:

```bash
kubectl apply -f nginx-complete.yaml
```

---

## Troubleshooting

**Problem:** K3s won't install  
**Solution:** Check if ports 6443 or 443 are in use. Try `sudo netstat -tulpn | grep :6443`

**Problem:** Pods stuck in "Pending"  
**Solution:** Check logs: `kubectl describe pod <pod-name>`

**Problem:** Can't access nginx in browser  
**Solution:** 
- Check service: `kubectl get svc`
- Try port-forward: `kubectl port-forward svc/nginx-service 8080:80`
- Access at: http://localhost:8080

**Problem:** "Connection refused"  
**Solution:** Wait a bit longer - pods take 30-60 seconds to fully start

---

## Next Steps

Now that you've deployed nginx, try:

1. **Deploy a different app** - Try `deployment.apps/hello-kubernetes`
2. **Add health checks** - Add liveness and readiness probes
3. **Use namespaces** - Organize resources by environment
4. **Try Helm** - Package this as a Helm chart
5. **Add Ingress** - Use hostname-based routing

---

## Commands Summary

```bash
# Install K3s
curl -sfL https://get.k3s.io | sh -

# Deploy
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml

# Check status
kubectl get all
kubectl get pods -w

# Scale
kubectl scale deployment nginx-deployment --replicas=5

# Access logs
kubectl logs <pod-name>

# Shell into pod
kubectl exec -it <pod-name> -- /bin/bash

# Cleanup
kubectl delete deployment nginx-deployment
kubectl delete service nginx-service

# Uninstall K3s
sudo /usr/local/bin/k3s-uninstall.sh
```

---

**🎉 Congratulations!** You've deployed your first application to Kubernetes!