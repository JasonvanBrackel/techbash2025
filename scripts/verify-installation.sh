#!/bin/bash

echo "=== Container & Kubernetes Workshop - Installation Verification ==="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -n "Checking Docker... "
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓${NC} $DOCKER_VERSION"
else
    echo -e "${RED}✗${NC} Docker not found"
fi

echo -n "Checking .NET SDK... "
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    echo -e "${GREEN}✓${NC} .NET $DOTNET_VERSION"
else
    echo -e "${RED}✗${NC} .NET SDK not found"
fi

echo -n "Checking kubectl... "
if command -v kubectl &> /dev/null; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null)
    echo -e "${GREEN}✓${NC} $KUBECTL_VERSION"
else
    echo -e "${RED}✗${NC} kubectl not found"
fi

echo -n "Checking Helm... "
if command -v helm &> /dev/null; then
    HELM_VERSION=$(helm version --short)
    echo -e "${GREEN}✓${NC} $HELM_VERSION"
else
    echo -e "${RED}✗${NC} Helm not found"
fi

echo -n "Checking Git... "
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✓${NC} $GIT_VERSION"
else
    echo -e "${RED}✗${NC} Git not found"
fi

echo ""
echo "=== Docker Test ==="
docker run hello-world 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Docker is working correctly"
else
    echo -e "${RED}✗${NC} Docker test failed"
fi

echo ""
echo "Setup verification complete!"
