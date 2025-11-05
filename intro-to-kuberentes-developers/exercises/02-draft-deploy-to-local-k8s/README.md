# Exercise 02: Use Azure Draft to Containerize and Deploy the Weather API

In this exercise, you'll learn how to use Azure Draft to automatically generate Dockerfiles and Kubernetes manifests for the Weather API application, then deploy it to your local Kubernetes cluster running in Docker Desktop.

## Prerequisites

- Completed Exercise 01 (Docker Desktop, k9s, and Draft installed)
- Docker Desktop running with Kubernetes enabled
- kubectl installed and configured
- .NET SDK installed (should already be present if the app builds)

## Learning Objectives

By the end of this exercise, you will:
- Use Draft to generate Docker and Kubernetes configurations for an existing .NET application
- Build a container image from your application
- Deploy an application to Kubernetes
- Verify and interact with your deployed application
- Use k9s to monitor your deployment
- Make changes and perform rolling updates

## Part 1: Verify Your Environment

Before we start, let's make sure everything from Exercise 01 is working:

```bash
# Verify Docker is running
docker --version
docker ps

# Verify Kubernetes cluster is running
kubectl cluster-info
kubectl get nodes

# You should see the docker-desktop node in a Ready state
# NAME             STATUS   ROLES           AGE   VERSION
# docker-desktop   Ready    control-plane   1h    v1.xx.x

# Verify Draft is installed
draft version

# Verify k9s is installed
k9s version
```

## Part 2: Navigate to the Weather API Application

The Weather API is a simple .NET 8 Web API that returns weather forecast data. Let's explore it:

```bash
# Navigate to the src directory
cd intro-to-kuberentes-developers/src

# List the files
ls -la

# You should see:
# - Program.cs (main application code)
# - WeatherApi.csproj (project file)
# - bin/ and obj/ (build artifacts)
```

### Understanding the Weather API

Let's look at what the application does:

```bash
# View the application code
cat Program.cs
```

The application:
- Exposes a `/weatherforecast` endpoint that returns random weather data
- Uses Swagger/OpenAPI for API documentation (in development mode)
- Runs on port 8080 by default (configured in launchSettings.json or environment)
- Returns JSON data with temperature, date, and weather summary

### Test the Application Locally (Optional)

Before containerizing, let's make sure it works:

```bash
# Build and run the application
dotnet run

# In another terminal, test it:
curl http://localhost:5000/weatherforecast

# Stop the application with Ctrl+C
```

## Part 3: Initialize Draft for the Weather API

Draft will automatically detect that this is a .NET application and generate the necessary files.

```bash
# Make sure you're in the src directory
pwd
# Should show: .../intro-to-kuberentes-developers/src

# Initialize Draft
draft create

# Draft will prompt you for information:
# - It should auto-detect this is a C# application
# - Application name: weather-api (or your preferred name)
# - Port: 8080 (or 5000 depending on your config)
# - Namespace: default
```

### What Draft Creates

After running `draft create`, you'll see new files in your project:

```bash
ls -la

# New files created by Draft:
# - Dockerfile (instructions for building the container)
# - .dockerignore (files to exclude from Docker build)
# - charts/ (Helm chart with Kubernetes manifests)
# - draft.yaml (Draft configuration)
```

### Review the Generated Dockerfile

Let's examine the Dockerfile that Draft created:

```bash
cat Dockerfile
```

The Dockerfile typically includes:
- Multi-stage build (build stage + runtime stage)
- .NET SDK for building the application
- Optimized runtime image (aspnet runtime)
- Proper port exposure
- Security best practices

### Review the Kubernetes Manifests

Draft creates a Helm chart with Kubernetes resources:

```bash
# List the chart contents
ls -la charts/

# View the values file (configurable parameters)
cat charts/weather-api/values.yaml

# View the deployment manifest
cat charts/weather-api/templates/deployment.yaml

# View the service manifest
cat charts/weather-api/templates/service.yaml
```

Key components:
- **Deployment**: Manages your application pods
- **Service**: Provides network access to your pods
- **values.yaml**: Configuration values (replicas, image, ports, etc.)

## Part 4: Customize the Configuration (Optional)

You can customize the `draft.yaml` file if needed:

```bash
cat draft.yaml
```

Typical configuration:
```yaml
language: csharp
languageVersion: "8.0"
variables:
  - name: PORT
    default: "8080"
  - name: APPNAME
    default: "weather-api"
  - name: NAMESPACE
    default: "default"
  - name: IMAGENAME
    default: "weather-api"
  - name: IMAGETAG
    default: "latest"
```

You can also edit `charts/weather-api/values.yaml` to adjust:
- Number of replicas
- Resource limits (CPU, memory)
- Service type and ports
- Environment variables

## Part 5: Build the Container Image

Now let's build the Docker container image for the Weather API:

```bash
# Build the image using the generated Dockerfile
docker build -t weather-api:v1 .

# This will:
# 1. Restore NuGet packages
# 2. Build the .NET application
# 3. Publish the application
# 4. Create a runtime container image
# This may take a few minutes the first time

# Verify the image was built
docker images | grep weather-api

# You should see something like:
# weather-api   v1      abc123def456   1 minute ago   215MB
```

### Test the Container Locally (Optional)

Before deploying to Kubernetes, let's make sure the container works:

```bash
# Run the container locally
docker run -d -p 8080:8080 --name weather-api-test weather-api:v1

# Test the API
curl http://localhost:8080/weatherforecast

# Check logs
docker logs weather-api-test

# Stop and remove the test container
docker stop weather-api-test
docker rm weather-api-test
```

## Part 6: Deploy to Kubernetes

Now let's deploy the Weather API to your local Kubernetes cluster:

### Option A: Deploy Using Helm (Recommended)

```bash
# Install the Helm chart created by Draft
helm install weather-api ./charts/weather-api

# Check the deployment status
helm status weather-api

# List all Helm releases
helm list
```

### Option B: Deploy Using kubectl

```bash
# Apply the Kubernetes manifests
kubectl apply -f charts/weather-api/templates/deployment.yaml
kubectl apply -f charts/weather-api/templates/service.yaml

# Or apply all at once
kubectl apply -f charts/weather-api/templates/
```

### Verify the Deployment

```bash
# Check all resources
kubectl get all

# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get services

# Get detailed pod information
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Follow logs in real-time
kubectl logs -f <pod-name>
```

Expected output:
```
NAME                              READY   STATUS    RESTARTS   AGE
pod/weather-api-xxxxxxxxxx-xxxxx  1/1     Running   0          1m

NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/weather-api   ClusterIP   10.96.xxx.xxx   <none>        8080/TCP   1m

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/weather-api   1/1     1            1           1m
```

## Part 7: Access the Weather API

Now that the application is deployed, let's access it:

### Using Port Forwarding

```bash
# Port forward from your local machine to the Kubernetes service
kubectl port-forward service/weather-api 8080:8080

# Keep this terminal open!
```

### Test the API

In a new terminal window:

```bash
# Test the weather endpoint
curl http://localhost:8080/weatherforecast

# You should see JSON output with weather data like:
# [
#   {
#     "date": "2024-11-05",
#     "temperatureC": 25,
#     "temperatureF": 76,
#     "summary": "Warm"
#   },
#   ...
# ]

# Test with a browser
# Open: http://localhost:8080/weatherforecast

# If Swagger is enabled in your environment
# Open: http://localhost:8080/swagger
```

## Part 8: Monitor with k9s

k9s provides a powerful terminal UI for managing Kubernetes:

```bash
# Launch k9s (make sure port-forward is stopped first, or use a new terminal)
k9s

# Useful k9s navigation:
# - Type ':pods' or ':po' to view pods
# - Type ':svc' to view services
# - Type ':deploy' to view deployments
# - Type ':ns' to view namespaces

# Useful k9s shortcuts when viewing resources:
# - Press 'Enter' or 'd' to describe a resource
# - Press 'l' to view logs
# - Press 'shift+f' to port-forward
# - Press 'y' to view YAML
# - Press 's' to shell into a pod
# - Press 'ctrl+d' to delete a resource (be careful!)
# - Press '?' to see all shortcuts
# - Press ':q' or 'ctrl+c' to quit

# Try these:
# 1. Navigate to pods (:po)
# 2. Select the weather-api pod
# 3. Press 'l' to view logs
# 4. Press 'Esc' to go back
# 5. Press 'd' to describe the pod
```

## Part 9: Make Changes and Perform a Rolling Update

Let's update the Weather API and redeploy it:

### Update the Application Code

Edit the [Program.cs](../../src/Program.cs) file and change the summaries:

```csharp
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild",
    "Warm", "Balmy", "Hot", "Sweltering", "Scorching",
    "Lovely", "Perfect"  // Add new weather descriptions
};
```

### Rebuild and Redeploy

```bash
# Rebuild the image with a new version tag
docker build -t weather-api:v2 .

# Update the deployment to use the new image
kubectl set image deployment/weather-api weather-api=weather-api:v2

# Watch the rollout happen
kubectl rollout status deployment/weather-api

# Check the rollout history
kubectl rollout history deployment/weather-api

# Verify the update - port forward again
kubectl port-forward service/weather-api 8080:8080

# In another terminal, test the updated API
curl http://localhost:8080/weatherforecast
# You might see "Lovely" or "Perfect" in the summaries now!
```

### Understanding Rolling Updates

Kubernetes performs a **rolling update** by default:
1. Creates new pods with the v2 image
2. Waits for them to be ready
3. Terminates old pods
4. Your application has zero downtime!

Watch it happen in k9s:
```bash
k9s
# Type ':po' to see pods
# You'll see old pods terminating and new pods starting
```

### Rollback if Needed

If something goes wrong, you can easily rollback:

```bash
# Rollback to the previous version
kubectl rollout undo deployment/weather-api

# Rollback to a specific revision
kubectl rollout undo deployment/weather-api --to-revision=1

# Check the status
kubectl rollout status deployment/weather-api
```

## Part 10: Scale Your Application

Let's try scaling the Weather API to multiple replicas:

```bash
# Scale to 3 replicas
kubectl scale deployment/weather-api --replicas=3

# Watch the new pods come up
kubectl get pods -w
# Press Ctrl+C to stop watching

# Check the status
kubectl get deployment weather-api

# Use k9s to see all replicas
k9s
# Type ':po' and see 3 weather-api pods running
```

### Test Load Balancing

```bash
# Port forward to the service
kubectl port-forward service/weather-api 8080:8080

# In another terminal, make multiple requests
for i in {1..10}; do
  curl http://localhost:8080/weatherforecast
  echo "Request $i completed"
done

# Kubernetes automatically load balances across all pods!
```

## Part 11: Cleanup

When you're done experimenting:

```bash
# Stop port-forwarding (Ctrl+C in the terminal where it's running)

# If you deployed with Helm:
helm uninstall weather-api

# Or if you deployed with kubectl:
kubectl delete deployment weather-api
kubectl delete service weather-api

# Verify everything is deleted
kubectl get all

# Optional: Clean up Docker images
docker images | grep weather-api
docker rmi weather-api:v1 weather-api:v2

# Note: Keep Docker Desktop and Kubernetes running for future exercises
```

## Understanding What Happened

### Docker Image Build
- Draft created a multi-stage Dockerfile optimized for .NET applications
- The build stage compiles your application with the .NET SDK
- The runtime stage uses a smaller base image (aspnet runtime) for efficiency
- The image includes your application code and all dependencies
- Images are tagged for version control (v1, v2, etc.)

### Kubernetes Deployment
- **Deployment**: Manages your application pods, handles rolling updates, and maintains desired state
- **Service**: Provides a stable network endpoint (ClusterIP) to access your pods
- **Pods**: Running instances of your containerized Weather API application
- **ReplicaSet**: Automatically created by the Deployment to maintain the specified number of pod replicas

### Draft's Role
- Automatically detected your .NET/C# application
- Generated a production-ready multi-stage Dockerfile
- Created a complete Helm chart with Kubernetes manifests
- Simplified the entire containerization and deployment process
- Provided best practices out of the box

### What You Learned
1. How to containerize a .NET application with Docker
2. How to deploy containers to Kubernetes
3. How to access applications running in Kubernetes
4. How to monitor deployments with kubectl and k9s
5. How to perform rolling updates with zero downtime
6. How to scale applications horizontally
7. How to rollback deployments if needed

## Common Issues and Solutions

### Issue: "Cannot connect to Docker daemon"
**Solution**: Ensure Docker Desktop is running (check for the whale icon in system tray/menu bar)

### Issue: "No cluster found" or "connection refused"
**Solution**:
```bash
# Check if Kubernetes is enabled in Docker Desktop
kubectl config get-contexts

# Switch to docker-desktop context if needed
kubectl config use-context docker-desktop

# Verify the cluster is running
kubectl cluster-info
```

### Issue: "ImagePullBackOff" error
**Solution**: This means Kubernetes can't find your local image. Configure imagePullPolicy:
```bash
# Edit the deployment to never pull images (use local only)
kubectl patch deployment weather-api -p '{"spec":{"template":{"spec":{"containers":[{"name":"weather-api","imagePullPolicy":"Never"}]}}}}'

# Or edit values.yaml before deploying:
# image:
#   pullPolicy: Never
```

### Issue: Port forwarding fails or "connection refused"
**Solution**:
```bash
# Ensure the pod is running
kubectl get pods

# Check pod logs for errors
kubectl logs <pod-name>

# Verify the correct port
kubectl get service weather-api
# Use the port shown under PORT(S)

# Make sure you're using the service name, not pod name
kubectl port-forward service/weather-api 8080:8080
```

### Issue: Helm chart fails to install
**Solution**:
```bash
# Check for errors
helm install weather-api ./charts/weather-api --debug

# Delete and retry
helm uninstall weather-api
helm install weather-api ./charts/weather-api

# Or use kubectl instead
kubectl apply -f charts/weather-api/templates/
```

## Challenge Tasks

Ready to go further? Try these challenges:

### 1. Add Health Checks
Add liveness and readiness probes to your deployment:
- Add a `/health` endpoint to the Weather API
- Configure liveness probe in the deployment manifest
- Configure readiness probe to ensure pods are ready before receiving traffic

### 2. Add Environment Variables
Configure the application using environment variables:
- Add an environment variable for the application name
- Use a ConfigMap to store configuration
- Reference the ConfigMap in your deployment

### 3. Configure Resource Limits
Set CPU and memory limits:
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

### 4. Add a New Endpoint
Extend the Weather API:
- Add a new endpoint `/weather/{city}` that returns weather for a specific city
- Rebuild and redeploy using rolling updates
- Test the new endpoint

### 5. Expose with LoadBalancer (Docker Desktop only)
Change the service type to LoadBalancer:
```bash
kubectl patch service weather-api -p '{"spec":{"type":"LoadBalancer"}}'
kubectl get service weather-api
# Access via http://localhost:8080/weatherforecast (no port-forward needed!)
```

### 6. View Application Metrics
Explore resource usage:
```bash
# Install metrics-server (if not already available)
kubectl top nodes
kubectl top pods
```

## Next Steps

Congratulations! You've successfully containerized and deployed the Weather API to Kubernetes. Here's what you can explore next:

### Continue Learning Kubernetes
- **Exercise 03** (if available): Advanced Kubernetes concepts
- Learn about Ingress for HTTP routing
- Explore Persistent Volumes for stateful applications
- Study Namespaces for multi-tenant clusters
- Understand RBAC for security and access control

### Production Considerations
- Set up CI/CD pipelines with GitHub Actions or Azure DevOps
- Deploy to cloud Kubernetes services (AKS, EKS, GKE)
- Implement monitoring with Prometheus and Grafana
- Add logging with ELK or Loki stack
- Configure auto-scaling with HPA (Horizontal Pod Autoscaler)
- Implement network policies for security

### Advanced Draft Usage
- Customize Draft templates for your organization
- Create custom Draft packs for different application types
- Integrate Draft into your CI/CD pipeline

## Additional Resources

### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Docker Documentation](https://docs.docker.com/)
- [Azure Draft Documentation](https://docs.microsoft.com/azure/aks/draft)
- [Helm Documentation](https://helm.sh/docs/)

### Tools
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [k9s Documentation](https://k9scli.io/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Learning Resources
- [Kubernetes By Example](https://kubernetesbyexample.com/)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
- [Kubernetes Patterns](https://k8spatterns.io/)

## Summary

In this exercise, you:
- ✅ Used Azure Draft to generate Docker and Kubernetes configurations
- ✅ Built a container image for the Weather API
- ✅ Deployed the application to your local Kubernetes cluster
- ✅ Accessed and tested the deployed application
- ✅ Monitored your deployment using kubectl and k9s
- ✅ Performed a rolling update with zero downtime
- ✅ Scaled the application horizontally
- ✅ Learned how to rollback deployments

You now have the foundation to containerize and deploy applications to Kubernetes!
