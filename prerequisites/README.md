# Contain Your Enthusiasm Workshop - Prerequisites

## Send this document to attendees 1 week before the workshop

---

Dear Workshop Attendee,

Thank you for registering for "Contain Your Enthusiasm: A Full Day with Containers and Kubernetes" at TechBash! To ensure a smooth workshop experience, please complete the following setup **before the workshop day**.

**Workshop Date:** [Insert Date]  
**Time:** 9:00 AM - 5:00 PM  
**Location:** [Insert Location]

---

## ✅ Prerequisites Checklist

### Required Software (Must Have)

- [ ] **Docker Desktop** (latest stable version)
  - Windows/Mac: https://www.docker.com/products/docker-desktop
  - Verify: `docker --version`
  
- [ ] **.NET 8 SDK** (latest LTS)
  - Download: https://dotnet.microsoft.com/download/dotnet/8.0
  - Verify: `dotnet --version`
  
- [ ] **kubectl** (Kubernetes CLI)
  - Install guide: https://kubernetes.io/docs/tasks/tools/
  - Verify: `kubectl version --client`
  
- [ ] **Helm** (v3.x)
  - Install guide: https://helm.sh/docs/intro/install/
  - Verify: `helm version`
  
- [ ] **Git**
  - Download: https://git-scm.com/downloads
  - Verify: `git --version`

- [ ] **Code Editor** (choose one)
  - Visual Studio 2022 (Community or higher)
  - VS Code with C# extension

### Recommended Software (Strongly Encouraged)

- [ ] **k9s** (Kubernetes terminal UI)
  - Install: https://k9scli.io/topics/install/
  - Makes Kubernetes management much easier!

- [ ] **Flux CLI** (for GitOps exercise)
  - Install: https://fluxcd.io/flux/installation/
  - Verify: `flux --version`

### Required Accounts (Free)

- [ ] **Docker Hub Account**
  - Sign up: https://hub.docker.com/signup
  - We'll use this to share container images

- [ ] **GitHub Account**
  - Sign up: https://github.com/signup
  - Needed for GitOps exercise (Exercise 5)

### Optional (For Cloud Demos)

- [ ] **Azure Free Account** (optional)
  - Sign up: https://azure.microsoft.com/free/
  - Only if you want to try AKS

---

## 🖥️ System Requirements

### Minimum:
- **OS:** Windows 10/11, macOS 12+, or Linux
- **RAM:** 8 GB (16 GB recommended)
- **Disk:** 20 GB free space
- **CPU:** 4 cores (for running local Kubernetes)

### For Windows Users:
- Enable WSL2 (required for Docker Desktop)
- Enable Hyper-V (if available)

---

## 📦 Installation Guides

### Windows (PowerShell as Administrator)

```powershell
# Install Chocolatey (package manager) if not installed
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required tools
choco install docker-desktop -y
choco install dotnet-8.0-sdk -y
choco install kubernetes-cli -y
choco install kubernetes-helm -y
choco install git -y

# Install recommended tools
choco install k9s -y
choco install flux -y
```

### macOS (using Homebrew)

```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install --cask docker
brew install --cask dotnet-sdk
brew install kubectl
brew install helm
brew install git

# Install recommended tools
brew install k9s
brew install flux
```

### Linux (Ubuntu/Debian)

```bash
# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# .NET 8 SDK
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 8.0

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# k9s
curl -sS https://webinstall.dev/k9s | bash

# Flux
curl -s https://fluxcd.io/install.sh | sudo bash
```

---

## ✔️ Verify Your Setup

### Run this verification script:

**Linux/macOS:**
```bash
curl -s https://raw.githubusercontent.com/yourusername/techbash-containers-workshop/main/scripts/verify-installation.sh | bash
```

**Windows PowerShell:**
```powershell
# Download and run verification script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/techbash-containers-workshop/main/scripts/verify-installation.ps1" -OutFile verify.ps1
.\verify.ps1
```

### Manual Verification

Run each command and ensure they work:

```bash
# Docker
docker --version
docker run hello-world

# .NET
dotnet --version

# Kubernetes tools
kubectl version --client
helm version

# Git
git --version

# Optional tools
k9s version
flux --version
```

**Expected Output Examples:**
```
✓ Docker version 24.0.x
✓ .NET 8.0.x
✓ kubectl v1.28.x
✓ Helm v3.13.x
✓ git version 2.x.x
✓ k9s v0.x.x
✓ flux version 2.x.x
```

---

## 🚨 Troubleshooting

### Docker Desktop Not Starting (Windows)
1. Enable WSL2: `wsl --install`
2. Enable Hyper-V (if available)
3. Restart computer
4. Try Docker Desktop again

### kubectl Command Not Found
- Ensure it's in your PATH
- On Windows, close and reopen PowerShell
- On Mac/Linux, run: `source ~/.bashrc` or `source ~/.zshrc`

### Docker Permission Denied (Linux)
```bash
sudo usermod -aG docker $USER
newgrp docker
# Or log out and log back in
```

### Port 8080 Already in Use
- We'll use different ports during the workshop
- Or stop the conflicting service

---

## 📚 Pre-Workshop Preparation (Optional)

If you want to get a head start, review these concepts:

### Containers Basics
- What are containers vs VMs?
- Docker basics
- Container images and layers

### Kubernetes Fundamentals
- Pods, Deployments, Services
- kubectl basics
- YAML manifests

### Recommended Reading
- Docker docs: https://docs.docker.com/get-started/
- Kubernetes concepts: https://kubernetes.io/docs/concepts/
- .NET containerization: https://learn.microsoft.com/en-us/dotnet/core/docker/

---

## 📥 Download Workshop Materials

**Option 1: Clone the repository**
```bash
git clone https://github.com/yourusername/techbash-containers-workshop.git
cd techbash-containers-workshop
```

**Option 2: Download ZIP**
1. Visit: https://github.com/yourusername/techbash-containers-workshop
2. Click "Code" → "Download ZIP"
3. Extract to your preferred location

---

## 🆘 Need Help?

### Before the Workshop
- **Email:** jason@example.com
- **Twitter/X:** @jasonvanbrackel
- **GitHub Issues:** https://github.com/yourusername/techbash-containers-workshop/issues

### Day of Workshop
- **Setup Help Session:** 8:30 AM - 9:00 AM (30 min before start)
- **Location:** [Same room as workshop]

---

## 📋 What to Bring

- [ ] Laptop with all software installed
- [ ] Power adapter/charger
- [ ] Docker Hub credentials (username/password)
- [ ] GitHub credentials
- [ ] Notebook (optional, for notes)
- [ ] Questions and enthusiasm!

---

## 🎯 Workshop Expectations

By the end of this workshop, you will be able to:

✅ Understand container fundamentals and benefits  
✅ Build and optimize Docker images for .NET applications  
✅ Deploy applications to Kubernetes  
✅ Use Helm for package management  
✅ Implement GitOps workflows with Flux  
✅ Manage multi-environment deployments  
✅ Use power tools like K9s for productivity  

---

## 📅 Workshop Schedule Preview

**Morning (9:00 AM - 12:00 PM)**
- Container fundamentals
- Docker essentials
- Building .NET containers

**Lunch Break (12:00 PM - 1:00 PM)**

**Afternoon (1:00 PM - 5:00 PM)**
- Kubernetes concepts
- K3s deployment
- Helm charts
- Flux GitOps
- Power tools

---

## ✨ Bonus: Docker Desktop Settings

After installing Docker Desktop, configure these settings for best experience:

### General
- ✅ Start Docker Desktop when you log in
- ✅ Use WSL 2 based engine (Windows)

### Resources
- **CPUs:** At least 4
- **Memory:** At least 8 GB (16 GB if available)
- **Disk:** At least 20 GB

### Kubernetes (Enable Later During Workshop)
- We'll enable this together in Exercise 3

---

## 📞 Final Checklist Before Workshop Day

- [ ] All required software installed
- [ ] Verification script passes
- [ ] Docker Hub account created
- [ ] GitHub account ready
- [ ] Workshop materials downloaded
- [ ] Laptop charged
- [ ] Docker Desktop running successfully

---

## See You at the Workshop!

If you've completed all the prerequisites, you're ready to go! 🎉

We'll have an early setup session (8:30 AM) for anyone experiencing issues.

Looking forward to an exciting day of learning containers and Kubernetes!

**Questions?** Don't hesitate to reach out: jason@example.com

---

**Jason van Brackel**  
@jasonvanbrackel  
TechBash 2024