# Workshop Quick Reference - All Commands

Print-friendly command reference for the workshop. Each section fits on one page.

---

# Docker Command Reference

## Essential Docker Commands

### Image Operations
```bash
# Pull image from registry
docker pull <image>:<tag>

# Build image from Dockerfile
docker build -t <image-name>:<tag> .
docker build -f Dockerfile.custom -t <name> .

# List images
docker images
docker images -q  # IDs only

# Remove image
docker rmi <image>
docker rmi $(docker images -q)  # Remove all

# Tag image
docker tag <source> <target>

# Push to registry
docker push <image>:<tag>

# Image inspection
docker inspect <image>
docker history <image>
```

### Container Operations
```bash
# Run container
docker run <image>
docker run -d <image>  # Detached
docker run -it <image> bash  # Interactive
docker run -p 8080:80 <image>  # Port mapping
docker run -v /host:/container <image>  # Volume
docker run -e VAR=value <image>  # Environment
docker run --name myapp <image>  # Named
docker run --rm <image>  # Auto-remove

# List containers
docker ps  # Running only
docker ps -a  # All containers

# Container lifecycle
docker start <container>
docker stop <container>
docker restart <container>
docker pause <container>
docker unpause <container>

# Remove containers
docker rm <container>
docker rm -f <container>  # Force
docker container prune  # Remove stopped

# Container inspection
docker logs <container>
docker logs -f <container>  # Follow
docker inspect <container>
docker stats <container>
docker top <container>

# Execute in container
docker exec <container> <command>
docker exec -it <container> bash
docker exec -it <container> sh
```

### Network Operations
```bash
# List networks
docker network ls

# Create network
docker network create <name>

# Connect container
docker network connect <network> <container>

# Inspect network
docker network inspect <name>
```

### Volume Operations
```bash
# List volumes
docker volume ls

# Create volume
docker volume create <name>

# Remove volume
docker volume rm <name>
docker volume prune  # Remove unused
```

### Cleanup Commands
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Remove everything
docker system prune -a --volumes
```

### Multi-stage Dockerfile Template
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["App.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "App.dll"]
```

---

# kubectl Command Reference

## Cluster Information
```bash
# Cluster info
kubectl cluster-info
kubectl version
kubectl api-resources
kubectl get nodes
kubectl describe node <name>
```

## Resource Management

### Get Resources
```bash
# List resources
kubectl get <resource>
kubectl get <resource> -n <namespace>
kubectl get <resource> -A  # All namespaces
kubectl get <resource> -o wide  # More details
kubectl get <resource> -o yaml  # YAML output
kubectl get <resource> -o json  # JSON output
kubectl get <resource> --watch  # Watch changes

# Common resources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get configmaps
kubectl get secrets
kubectl get ingresses
kubectl get all  # Most resources
```

### Describe Resources
```bash
kubectl describe <resource> <name>
kubectl describe <resource> <name> -n <namespace>
```

### Create/Apply Resources
```bash
# Create from file
kubectl create -f <file>
kubectl create -f <directory>

# Apply (create or update)
kubectl apply -f <file>
kubectl apply -f <directory>

# Create from command
kubectl create deployment <name> --image=<image>
kubectl create service clusterip <name> --tcp=80:8080
kubectl create configmap <name> --from-literal=key=value
kubectl create secret generic <name> --from-literal=key=value
```

### Delete Resources
```bash
kubectl delete <resource> <name>
kubectl delete -f <file>
kubectl delete <resource> --all
kubectl delete <resource> --all -n <namespace>
```

### Edit Resources
```bash
kubectl edit <resource> <name>
kubectl set image deployment/<name> <container>=<image>
```

##