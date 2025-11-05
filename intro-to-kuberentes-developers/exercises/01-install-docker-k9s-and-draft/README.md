# Exercise 01: Install Docker Desktop, kubectl, k9s, and Azure Draft

This exercise will guide you through installing the essential tools needed for working with containers and Kubernetes.

## Prerequisites

- A computer running Windows or macOS (Docker Desktop provides the best experience)
- Administrator/sudo access
- Internet connection
- At least 4GB of RAM and 20GB of disk space

## Tools Overview

### Docker Desktop
Docker Desktop is an all-in-one package that includes Docker Engine, Docker CLI, Docker Compose, kubectl, and a single-node Kubernetes cluster. It's the easiest way to get started with both containers and Kubernetes on your local machine.

### kubectl
kubectl is the Kubernetes command-line tool that allows you to run commands against Kubernetes clusters. You'll use it to deploy applications, inspect and manage cluster resources, and view logs. Docker Desktop includes kubectl, but we'll show you how to install it separately if needed.

### k9s
k9s is a terminal-based UI to interact with your Kubernetes clusters. It makes it easier to navigate, observe, and manage your applications in Kubernetes with a user-friendly interface.

### Azure Draft
Azure Draft simplifies Kubernetes development by automatically generating Dockerfiles, Kubernetes manifests, and deployment configurations for your applications.

## Installation Instructions

### Install Docker Desktop

#### Windows
1. Download Docker Desktop for Windows from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2. Run the installer
3. Follow the installation wizard
4. **Important**: Enable WSL 2 if prompted (recommended)
5. Restart your computer if prompted
6. Launch Docker Desktop from the Start menu
7. Wait for Docker Desktop to fully start (whale icon in system tray)
8. Verify installation:
   ```powershell
   docker --version
   docker run hello-world
   ```

#### macOS
1. Download Docker Desktop for Mac from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
   - Choose Apple Silicon for M1/M2/M3 Macs
   - Choose Intel Chip for Intel-based Macs
2. Open the downloaded .dmg file
3. Drag Docker to your Applications folder
4. Launch Docker from Applications
5. Grant necessary permissions when prompted
6. Wait for Docker Desktop to fully start (whale icon in menu bar)
7. Verify installation:
   ```bash
   docker --version
   docker run hello-world
   ```

### Install kubectl

kubectl is the command-line tool for interacting with Kubernetes clusters. Docker Desktop includes kubectl, but you may want to install it separately for version control or if you're on Linux.

#### Windows (Docker Desktop includes kubectl)
Docker Desktop automatically installs kubectl. Verify:
```powershell
kubectl version --client
```

If you need to install it separately:
```powershell
# Using Chocolatey
choco install kubernetes-cli

# Using Scoop
scoop install kubectl

# Using winget
winget install Kubernetes.kubectl
```

#### macOS (Docker Desktop includes kubectl)
Docker Desktop automatically installs kubectl. Verify:
```bash
kubectl version --client
```

If you need to install it separately:
```bash
# Using Homebrew
brew install kubectl

# Or download directly
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

#### Linux
```bash
# Download the latest release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### Enable Kubernetes in Docker Desktop

**This is a critical step!** Docker Desktop includes a single-node Kubernetes cluster that we'll use for all exercises.

#### Steps (Windows & macOS):
1. Open Docker Desktop
2. Click on the Settings/Preferences icon (gear icon)
3. Navigate to **Kubernetes** in the left sidebar
4. Check the box **"Enable Kubernetes"**
5. Click **"Apply & Restart"**
6. Wait for Kubernetes to start (this may take 5-10 minutes the first time)
7. You'll see a green indicator when Kubernetes is running

#### Verify Kubernetes Installation:
```bash
# Check kubectl is installed and working
kubectl version --client

# Check cluster connection
kubectl cluster-info

# View cluster nodes (you should see one node named "docker-desktop")
kubectl get nodes

# The output should show:
# NAME             STATUS   ROLES           AGE   VERSION
# docker-desktop   Ready    control-plane   1m    v1.xx.x
```

### Install k9s

#### Windows (using Chocolatey)
```powershell
choco install k9s
```

#### Windows (using Scoop)
```powershell
scoop install k9s
```

#### Windows (Manual)
1. Download the latest release from [https://github.com/derailed/k9s/releases](https://github.com/derailed/k9s/releases)
2. Extract the executable
3. Add to your PATH or move to a directory in your PATH

#### macOS (using Homebrew)
```bash
brew install k9s
```

#### Linux
```bash
# Download the latest release (replace VERSION with the latest version number)
VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -sL https://github.com/derailed/k9s/releases/download/${VERSION}/k9s_Linux_amd64.tar.gz | tar xz -C /tmp
sudo mv /tmp/k9s /usr/local/bin/
```

#### Verify k9s Installation
```bash
k9s version
```

### Install Azure Draft

#### Windows (using Winget)
```powershell
winget install Microsoft.draft
```

#### Windows (using Chocolatey)
```powershell
choco install draft
```

#### Windows/macOS/Linux (using script)
```bash
curl -fsSL https://raw.githubusercontent.com/Azure/draft/main/scripts/install.sh | bash
```

#### macOS (using Homebrew)
```bash
brew install azure/draft/draft
```

#### Linux
```bash
# Download the latest release
VERSION=$(curl -s https://api.github.com/repos/Azure/draft/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -sL https://github.com/Azure/draft/releases/download/${VERSION}/draft-linux-amd64.tar.gz | tar xz -C /tmp
sudo mv /tmp/draft /usr/local/bin/
```

#### Verify Draft Installation
```bash
draft version
```

## Verification

Once all tools are installed, verify everything is working:

```bash
# Check Docker
docker --version
docker ps

# Check kubectl
kubectl version --client
kubectl get nodes

# Check k9s
k9s version

# Check Draft
draft version
```

Expected output summary:
- Docker: Shows version and lists running containers (may be empty)
- kubectl: Shows client version and lists the docker-desktop node
- k9s: Shows k9s version information
- Draft: Shows Draft version information

## Common Issues

### Docker
- **Windows/macOS**: Ensure Docker Desktop is running (check system tray/menu bar)
- **Linux**: If you get permission errors, make sure you're in the docker group or use sudo
- **WSL2 on Windows**: Ensure WSL2 is enabled and Docker Desktop is configured to use it

### kubectl
- **Command not found**: Make sure Docker Desktop is installed and running, or install kubectl separately
- **Cannot connect to cluster**: Ensure Kubernetes is enabled in Docker Desktop
- **Wrong context**: Run `kubectl config use-context docker-desktop` to switch to the Docker Desktop cluster
- **Permission denied on Linux**: Make sure your user has access to `~/.kube/config`

### k9s
- k9s requires a Kubernetes cluster to connect to. Make sure you've enabled Kubernetes in Docker Desktop.
- Check that your `~/.kube/config` file exists and is properly configured
- Try running `k9s` - you should see your docker-desktop cluster
- If k9s shows errors, verify kubectl works first: `kubectl get nodes`

### Draft
- Draft requires Docker to be installed and running
- Verify Docker is accessible by running `docker ps`
- If `draft version` fails, ensure Draft is in your PATH

### Docker Desktop Kubernetes Not Starting
- Ensure you have enough disk space and memory
- Try resetting Kubernetes: Settings → Kubernetes → Reset Kubernetes Cluster
- Check Docker Desktop logs: Settings → Troubleshoot → View logs
- On Windows, ensure Hyper-V or WSL2 is properly configured

## Next Steps

Once you have successfully installed all three tools and enabled Kubernetes in Docker Desktop, you're ready to move on to the next exercise where we'll use Azure Draft to containerize and deploy the Weather API application to your local Kubernetes cluster.

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [k9s Documentation](https://k9scli.io/)
- [Azure Draft Documentation](https://docs.microsoft.com/en-us/azure/aks/draft)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
