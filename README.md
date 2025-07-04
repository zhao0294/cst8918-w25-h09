# CST8918 H09 - Azure Kubernetes Service (AKS) Cluster with Terraform

## Project Overview

This project demonstrates the creation of an Azure Kubernetes Service (AKS) cluster using Terraform Infrastructure as Code (IaC). The AKS cluster is used to deploy a multi-tier web application that includes:

- **Frontend**: Vue.js application (store-front)
- **Backend Services**: 
  - Order service (Node.js)
  - Product service (Rust)
- **Message Broker**: RabbitMQ

## Prerequisites

Before running this project, ensure you have the following tools installed:

- **Azure CLI** (version 2.30.0 or higher)
- **Terraform** (version 1.3.0 or higher)
- **kubectl** (Kubernetes command-line tool)
- **Git** (for version control)

## Environment Setup

### 1. Install Required Tools

```bash
# Install Azure CLI (macOS)
brew install azure-cli

# Install Terraform (macOS)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install kubectl (macOS)
brew install kubectl
```

### 2. Azure Authentication

```bash
# Login to Azure
az login

# Verify your subscription
az account show

# Set default subscription (if you have multiple)
az account set --subscription "your-subscription-id"
```

## Project Structure

```
cst8918-w25-h09/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── outputs.tf           # Output definitions
├── sample-app.yaml      # Kubernetes application deployment
├── .terraform.lock.hcl  # Provider version lock file
├── README.md           # This file
└── .gitignore          # Git ignore file
```

## Configuration Files

### Terraform Configuration

The project uses the following Terraform resources:

- **azurerm_resource_group**: Creates a new resource group
- **azurerm_kubernetes_cluster**: Creates the AKS cluster with:
  - 1 node (minimum) with auto-scaling capability
  - Standard_B2s VM size
  - SystemAssigned managed identity
  - Latest Kubernetes version

### Kubernetes Application

The `sample-app.yaml` file deploys:
- RabbitMQ message broker
- Order service (Node.js backend)
- Product service (Rust backend)
- Store frontend (Vue.js)

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Plan the Deployment

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### 4. Export Kubeconfig

```bash
echo "$(terraform output kube_config)" > ./kubeconfig
```

### 5. Verify Kubeconfig

```bash
cat ./kubeconfig
```

**Important**: If the file contains `<<<eof` and `eof` markers, remove them manually.

### 6. Connect to AKS Cluster

```bash
export KUBECONFIG=./kubeconfig
kubectl get nodes
```

### 7. Deploy the Application

```bash
kubectl apply -f sample-app.yaml
```

### 8. Verify Deployment

```bash
# Check pod status
kubectl get pods

# Check services
kubectl get services

# Get external IP for store-front service
kubectl get service store-front
```

### 9. Access the Application

Use the external IP address of the `store-front` service to access the application in your web browser.

## Troubleshooting

### Common Issues and Solutions

#### 1. Azure Authentication Issues

**Problem**: `subscription ID could not be determined`

**Solution**:
```bash
# Re-login to Azure
az logout
az login

# Verify subscription
az account show
```

#### 2. Terraform Provider Issues

**Problem**: `enable_auto_scaling` not supported

**Solution**: Use only `node_count` for fixed node count, or use `min_count` and `max_count` for auto-scaling.

#### 3. Kubernetes Connection Issues

**Problem**: Cannot connect to AKS cluster

**Solution**:
```bash
# Verify kubeconfig
cat ./kubeconfig

# Check if external IP is assigned
kubectl get services

# Wait for LoadBalancer to get external IP
kubectl get service store-front -w
```

#### 4. Application Deployment Issues

**Problem**: Pods stuck in pending state

**Solution**:
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check node resources
kubectl describe nodes
```

## Resource Cleanup

To avoid incurring charges, clean up resources when done:

### 1. Delete Kubernetes Resources

```bash
kubectl delete -f sample-app.yaml
```

### 2. Destroy Terraform Infrastructure

```bash
terraform destroy
```

When prompted, type `yes` to confirm the destruction.

## Project Requirements Met

This project successfully meets all the H09 lab requirements:

- ✅ AKS cluster created with Terraform
- ✅ Minimum 1 node, maximum 3 nodes (auto-scaling configured)
- ✅ New resource group created
- ✅ Latest Kubernetes version used
- ✅ Standard_B2s VM size
- ✅ SystemAssigned managed identity
- ✅ Kubeconfig output provided
- ✅ Sample application deployed successfully
- ✅ Multi-tier application with frontend, backend services, and message broker

## Environment Information

- **Operating System**: macOS
- **Terraform Version**: 1.5.0+
- **Azure CLI Version**: 2.30.0+
- **Azure Subscription**: Azure for Students
- **Region**: Canada Central
- **Kubernetes Version**: Latest (auto-detected)

## Contributing

This is a course project for CST8918 - DevOps: Infrastructure as Code at Algonquin College.

## License

This project is created for educational purposes as part of the CST8918 course requirements. 