# Exercise 2: Building a .NET Container with Docker

**Duration:** 30 minutes  
**Objective:** Create, containerize, and publish a .NET Web API using Docker multi-stage builds

## Prerequisites
- .NET 8 SDK installed
- Docker Desktop running
- Docker Hub account (free)
- Code editor (VS Code or Visual Studio)

## What You'll Learn
- Create a simple ASP.NET Core Web API
- Write an optimized multi-stage Dockerfile
- Build and run containers locally
- Tag and push images to Docker Hub
- Compare single-stage vs multi-stage builds

---

## Part 1: Create a Simple .NET Web API

### Step 1: Create the Project

```bash
# Create a new directory
mkdir weather-api
cd weather-api

# Create a new Web API project
dotnet new webapi -n WeatherApi --no-https
cd WeatherApi

# Test it runs locally
dotnet run
```

Visit `http://localhost:5000/weatherforecast` to verify it works. Press `Ctrl+C` to stop.

### Step 2: Simplify the API (Optional)

Open `Program.cs` and you should see the minimal API structure. It already has a `/weatherforecast` endpoint.

---

## Part 2: Create a Single-Stage Dockerfile (Bad Practice)

First, let's see why single-stage builds are inefficient.

### Step 3: Create a Basic Dockerfile

In the `WeatherApi` directory, create a file named `Dockerfile.single`:

```dockerfile
# Single-stage build (NOT RECOMMENDED)
FROM mcr.microsoft.com/dotnet/sdk:8.0

WORKDIR /app

# Copy everything
COPY . .

# Restore and build
RUN dotnet restore
RUN dotnet build -c Release

# Run the app
WORKDIR /app/bin/Release/net8.0
CMD ["dotnet", "WeatherApi.dll"]
```

### Step 4: Build the Single-Stage Image

```bash
docker build -f Dockerfile.single -t weather-api:single .
```

### Step 5: Check the Image Size

```bash
docker images weather-api:single

# Use dive to analyze
dive weather-api:single
```

**Note the size!** It will be 700MB+ because it includes the entire SDK.

---

## Part 3: Create a Multi-Stage Dockerfile (Best Practice)

### Step 6: Create an Optimized Dockerfile

In the `WeatherApi` directory, create `Dockerfile`:

```dockerfile
# Multi-stage build - RECOMMENDED

# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore (separate layer for caching)
COPY ["WeatherApi.csproj", "./"]
RUN dotnet restore "WeatherApi.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "WeatherApi.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "WeatherApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080

# Copy only the published output
COPY --from=publish /app/publish .

# Run as non-root user
USER $APP_UID

ENTRYPOINT ["dotnet", "WeatherApi.dll"]
```

### Step 7: Create .dockerignore

Create a `.dockerignore` file to exclude unnecessary files:

```
**/.classpath
**/.dockerignore
**/.env
**/.git
**/.gitignore
**/.project
**/.settings
**/.toolstarget
**/.vs
**/.vscode
**/*.*proj.user
**/*.dbmdl
**/*.jfm
**/azds.yaml
**/bin
**/charts
**/docker-compose*
**/Dockerfile*
**/node_modules
**/npm-debug.log
**/obj
**/secrets.dev.yaml
**/values.dev.yaml
LICENSE
README.md
```

### Step 8: Build the Multi-Stage Image

```bash
docker build -t weather-api:multi .
```

Watch as Docker builds each stage!

### Step 9: Compare Image Sizes

```bash
# List both images
docker images weather-api

# Compare sizes
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep weather-api
```

**Expected Results:**
- Single-stage: ~700-800 MB
- Multi-stage: ~200-220 MB

**That's a 70% reduction!**

### Step 10: Analyze with dive

```bash
# Compare both images
dive weather-api:single
dive weather-api:multi
```

**Observe:**
- Number of layers
- Where the size comes from
- Efficiency score

---

## Part 4: Run and Test Your Container

### Step 11: Run the Container

```bash
docker run -d -p 8080:8080 --name weather-api weather-api:multi
```

**Flags explained:**
- `-d` : Run in detached mode (background)
- `-p 8080:8080` : Map port 8080 on host to port 8080 in container
- `--name weather-api` : Give the container a friendly name
- `weather-api:multi` : The image to run

### Step 12: Test the API

```bash
# Using curl
curl http://localhost:8080/weatherforecast

# Or open in browser
start http://localhost:8080/weatherforecast  # Windows
open http://localhost:8080/weatherforecast   # macOS
```

You should see JSON weather data!

### Step 13: View Container Logs

```bash
docker logs weather-api

# Follow logs in real-time
docker logs -f weather-api
```

### Step 14: Inspect the Running Container

```bash
# See running containers
docker ps

# Get detailed info
docker inspect weather-api

# Execute commands inside the container
docker exec -it weather-api bash
# Once inside, try:
# pwd
# ls
# exit
```

---

## Part 5: Tag and Push to Docker Hub

### Step 15: Log in to Docker Hub

```bash
docker login
```

Enter your Docker Hub username and password.

### Step 16: Tag Your Image

```bash
# Replace 'yourusername' with your Docker Hub username
docker tag weather-api:multi yourusername/weather-api:v1.0
docker tag weather-api:multi yourusername/weather-api:latest
```

### Step 17: Push to Docker Hub

```bash
docker push yourusername/weather-api:v1.0
docker push yourusername/weather-api:latest
```

### Step 18: Verify on Docker Hub

Visit `https://hub.docker.com/r/yourusername/weather-api` to see your published image!

### Step 19: Test Pulling Your Image

```bash
# Stop and remove local container
docker stop weather-api
docker rm weather-api

# Remove local image (optional)
docker rmi weather-api:multi

# Pull from Docker Hub and run
docker run -d -p 8080:8080 --name weather-api yourusername/weather-api:latest
```

---

## Part 6: Cleanup

```bash
# Stop the container
docker stop weather-api

# Remove the container
docker rm weather-api

# Remove images (optional)
docker rmi weather-api:single
docker rmi weather-api:multi
docker rmi yourusername/weather-api:v1.0
docker rmi yourusername/weather-api:latest
```

---

## Key Takeaways

✅ **Multi-stage builds dramatically reduce image size**  
✅ **Separate restore step enables layer caching**  
✅ **Use SDK for building, runtime for production**  
✅ **Always use .dockerignore to exclude unnecessary files**  
✅ **Tag images with versions for better tracking**  
✅ **Docker Hub makes sharing images easy**  

---

## Bonus Challenges

If you finish early, try these:

### Challenge 1: Add Environment Variables

Run your container with custom configuration:

```bash
docker run -d -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Development \
  -e SomeCustomSetting=HelloWorld \
  --name weather-api \
  yourusername/weather-api:latest
```

### Challenge 2: Use Volumes

Create a volume for logs:

```bash
docker run -d -p 8080:8080 \
  -v weather-logs:/app/logs \
  --name weather-api \
  yourusername/weather-api:latest
```

### Challenge 3: Add Health Checks

Add this to your Dockerfile before ENTRYPOINT:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/weatherforecast || exit 1
```

Rebuild and run, then check health status:

```bash
docker ps
```

---

## Common Issues & Solutions

**Issue:** Port 8080 already in use  
**Solution:** Use a different port: `-p 8081:8080`

**Issue:** Container exits immediately  
**Solution:** Check logs with `docker logs weather-api`

**Issue:** Build fails with "restore" error  
**Solution:** Ensure .NET 8 SDK is installed and internet connection is active

**Issue:** Cannot push to Docker Hub  
**Solution:** Make sure you're logged in with `docker login` and using your correct username

---

## Next Exercise

In Exercise 3, we'll deploy this containerized API to Kubernetes!