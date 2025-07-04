# Deployment Guide - CST8918 H09 AKS Cluster

## Quick Start Deployment

This guide provides step-by-step instructions for deploying the AKS cluster and sample application.

## Prerequisites Check

Before starting, verify your environment:

```bash
# Check Azure CLI
az version

# Check Terraform
terraform version

# Check kubectl
kubectl version --client

# Verify Azure login
az account show
```

## Step 1: Infrastructure Deployment

### 1.1 Initialize Terraform

```bash
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/azurerm...
- Installing hashicorp/azurerm v4.35.0...
Terraform has been successfully initialized!
```

### 1.2 Plan Deployment

```bash
terraform plan
```

This will show you what resources will be created:
- Resource Group: `h09-aks-rg`
- AKS Cluster: `h09-aks-cluster`
- Node Pool: 1 node with Standard_B2s VM size

### 1.3 Apply Configuration

```bash
terraform apply
```

When prompted, type `yes` to confirm.

Expected output:
```
Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

The deployment will take approximately 5-10 minutes.

## Step 2: Kubernetes Cluster Access

### 2.1 Export Kubeconfig

```bash
echo "$(terraform output kube_config)" > ./kubeconfig
```

### 2.2 Verify Kubeconfig

```bash
cat ./kubeconfig
```

**Important**: If you see `<<<eof` at the beginning and `eof` at the end, remove these lines manually.

### 2.3 Set Environment Variable

```bash
export KUBECONFIG=./kubeconfig
```

### 2.4 Test Cluster Connection

```bash
kubectl get nodes
```

Expected output:
```
NAME                                STATUS   ROLES   AGE   VERSION
aks-default-12345678-vmss000000     Ready    agent   5m    v1.28.0
```

## Step 3: Application Deployment

### 3.1 Deploy the Sample Application

```bash
kubectl apply -f sample-app.yaml
```

Expected output:
```
deployment.apps/rabbitmq created
configmap/rabbitmq-enabled-plugins created
service/rabbitmq created
deployment.apps/order-service created
service/order-service created
deployment.apps/product-service created
service/product-service created
deployment.apps/store-front created
service/store-front created
```

### 3.2 Monitor Deployment Progress

```bash
kubectl get pods -w
```

Wait until all pods show `Running` status. This may take 2-3 minutes.

### 3.3 Check Service Status

```bash
kubectl get services
```

Expected output:
```
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
kubernetes     ClusterIP      10.0.0.1        <none>          443/TCP                      10m
order-service  ClusterIP      10.0.123.45     <none>          3000/TCP                     2m
product-service ClusterIP     10.0.123.46     <none>          3002/TCP                     2m
rabbitmq       ClusterIP      10.0.123.47     <none>          5672/TCP,15672/TCP           2m
store-front    LoadBalancer   10.0.123.48     <pending>       80:30000/TCP                 2m
```

### 3.4 Wait for External IP

The `store-front` service will get an external IP address. Monitor it:

```bash
kubectl get service store-front -w
```

Wait until you see an external IP address assigned.

## Step 4: Application Verification

### 4.1 Check All Components

```bash
# Check all pods are running
kubectl get pods

# Check all services
kubectl get services

# Check deployments
kubectl get deployments
```

### 4.2 Access the Application

Once the `store-front` service has an external IP:

1. Open your web browser
2. Navigate to `http://<EXTERNAL-IP>`
3. You should see the store frontend application

### 4.3 Verify Application Components

The application includes:
- **Store Frontend**: Vue.js application (port 80)
- **Order Service**: Node.js backend (port 3000)
- **Product Service**: Rust backend (port 3002)
- **RabbitMQ**: Message broker (ports 5672, 15672)

## Step 5: Troubleshooting

### 5.1 Common Issues

#### Pods Not Starting

```bash
# Check pod events
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>
```

#### Services Not Getting External IP

```bash
# Check service events
kubectl describe service store-front

# Check if LoadBalancer is working
kubectl get events --sort-by='.lastTimestamp'
```

#### Application Not Accessible

```bash
# Check if pods are ready
kubectl get pods -o wide

# Check service endpoints
kubectl get endpoints
```

### 5.2 Useful Commands

```bash
# Get detailed information about resources
kubectl describe deployment store-front
kubectl describe service store-front
kubectl describe pod <pod-name>

# Check logs for specific containers
kubectl logs deployment/store-front
kubectl logs deployment/order-service
kubectl logs deployment/product-service
kubectl logs deployment/rabbitmq

# Check cluster events
kubectl get events --sort-by='.lastTimestamp'
```

## Step 6: Cleanup

### 6.1 Remove Application

```bash
kubectl delete -f sample-app.yaml
```

### 6.2 Destroy Infrastructure

```bash
terraform destroy
```

When prompted, type `yes` to confirm.

## Success Criteria

Your deployment is successful when:

1. ✅ AKS cluster is created and accessible
2. ✅ All pods are in `Running` status
3. ✅ `store-front` service has an external IP
4. ✅ Application is accessible via web browser
5. ✅ All services are communicating properly

## Next Steps

After successful deployment:

1. Explore the application functionality
2. Monitor resource usage
3. Test application scaling
4. Document any issues encountered
5. Prepare for submission

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Ensure Azure subscription has sufficient quota
4. Check Terraform and kubectl versions
5. Review Azure portal for any resource issues 