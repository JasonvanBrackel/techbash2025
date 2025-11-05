# Exercise 1: Review Existing Container with dive

**Duration:** 15 minutes  
**Objective:** Understand container image composition and layer structure

## Prerequisites
- Docker Desktop running
- Internet connection (to pull images)

## What You'll Learn
- How to explore container image layers
- Identify wasted space in images
- Understand image efficiency
- See the impact of Dockerfile commands on image size

## Step 1: Install dive

If you haven't already installed dive, you can run it directly with Docker:

```bash
# Run dive as a Docker container
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest <image-name>
```

Or install it locally:

**Windows (with Chocolatey):**
```powershell
choco install dive
```

**macOS:**
```bash
brew install dive
```

**Linux:**
```bash
wget https://github.com/wagoodman/dive/releases/download/v0.11.0/dive_0.11.0_linux_amd64.deb
sudo apt install ./dive_0.11.0_linux_amd64.deb
```

## Step 2: Pull .NET Images to Analyze

Pull two different .NET images - one SDK and one runtime:

```bash
# Pull the full SDK image (large)
docker pull mcr.microsoft.com/dotnet/sdk:8.0

# Pull the runtime-only image (smaller)
docker pull mcr.microsoft.com/dotnet/aspnet:8.0

# Pull a sample application (if available)
docker pull mcr.microsoft.com/dotnet/samples:aspnetapp
```

## Step 3: Explore the SDK Image

```bash
dive mcr.microsoft.com/dotnet/sdk:8.0
```

**What to look for:**
- Total image size (top right)
- Number of layers (left panel)
- Wasted space percentage
- Which layers add the most size

**Navigation in dive:**
- `Tab` - Switch between layers and file tree
- `↑/↓` - Navigate through layers
- `Ctrl+A` - Show aggregate file changes
- `Ctrl+L` - Show layer changes only
- `Space` - Collapse/expand directories
- `Ctrl+C` - Exit

## Step 4: Compare with Runtime Image

```bash
dive mcr.microsoft.com/dotnet/aspnet:8.0
```

**Questions to Answer:**
1. How much smaller is the runtime image?
2. What layers are missing compared to SDK?
3. What's the efficiency score?

## Step 5: Analyze the Sample App

```bash
dive mcr.microsoft.com/dotnet/samples:aspnetapp
```

**Look for:**
- How many layers does it have?
- Which layer contains the application code?
- Are there any unnecessarily large files?
- What's causing wasted space?

## Step 6: Document Your Findings

Fill in this comparison table:

| Image | Total Size | Layers | Wasted Space | Efficiency |
|-------|-----------|--------|--------------|------------|
| SDK 8.0 | ___ MB | ___ | ___ MB | ___% |
| ASP.NET 8.0 | ___ MB | ___ | ___ MB | ___% |
| Sample App | ___ MB | ___ | ___ MB | ___% |

## Discussion Questions

1. **Why is the SDK image so much larger than the runtime?**
   - What's included in SDK but not runtime?

2. **What's the benefit of using runtime images for production?**
   - Security implications?
   - Resource usage?

3. **How does layer caching work?**
   - Why do we see shared layers?

## Key Takeaways

✅ Container images are built in layers  
✅ Each Dockerfile instruction creates a new layer  
✅ SDK images contain build tools (unnecessary in production)  
✅ Runtime images are optimized for running apps only  
✅ Multi-stage builds let us use SDK for building, runtime for deployment  
✅ Layer order matters for caching and efficiency  

## Bonus Challenge

If you finish early, analyze a non-.NET image and compare:

```bash
# Try a Node.js image
docker pull node:20
dive node:20

# Or a Python image
docker pull python:3.12
dive python:3.12
```

How do they compare to .NET images in terms of size and efficiency?

## Next Steps

In the next exercise, we'll build our own .NET container using a multi-stage Dockerfile to create the smallest possible production image!

---

**Troubleshooting:**

**Issue:** "Cannot connect to Docker daemon"
- **Solution:** Make sure Docker Desktop is running

**Issue:** dive command not found
- **Solution:** Run using Docker: `docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest <image>`

**Issue:** Image pull fails
- **Solution:** Check internet connection and try again