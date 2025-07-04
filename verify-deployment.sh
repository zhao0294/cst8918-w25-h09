#!/bin/bash

# CST8918 H09 - Deployment Verification Script
# This script helps verify the AKS cluster and application deployment

echo "=========================================="
echo "CST8918 H09 - Deployment Verification"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

echo ""
echo "1. Checking Terraform State..."
if [ -f "terraform.tfstate" ]; then
    print_status 0 "Terraform state file exists"
else
    print_status 1 "Terraform state file not found"
    exit 1
fi

echo ""
echo "2. Checking Kubeconfig..."
if [ -f "kubeconfig" ]; then
    print_status 0 "Kubeconfig file exists"
    
    # Check if kubeconfig has proper content
    if grep -q "apiVersion" kubeconfig; then
        print_status 0 "Kubeconfig appears to be valid"
    else
        print_warning "Kubeconfig may not be properly formatted"
    fi
else
    print_status 1 "Kubeconfig file not found"
    print_warning "Run: echo \"\$(terraform output kube_config)\" > ./kubeconfig"
fi

echo ""
echo "3. Checking Kubernetes Cluster Connection..."
export KUBECONFIG=./kubeconfig

if kubectl get nodes > /dev/null 2>&1; then
    print_status 0 "Successfully connected to AKS cluster"
    
    echo "   Cluster nodes:"
    kubectl get nodes --no-headers | while read line; do
        echo "   - $line"
    done
else
    print_status 1 "Failed to connect to AKS cluster"
    print_warning "Check if cluster is running and kubeconfig is correct"
fi

echo ""
echo "4. Checking Application Deployments..."
if kubectl get deployments > /dev/null 2>&1; then
    print_status 0 "Deployments found"
    
    echo "   Deployment status:"
    kubectl get deployments --no-headers | while read line; do
        echo "   - $line"
    done
else
    print_status 1 "No deployments found"
    print_warning "Run: kubectl apply -f sample-app.yaml"
fi

echo ""
echo "5. Checking Pod Status..."
if kubectl get pods > /dev/null 2>&1; then
    print_status 0 "Pods found"
    
    echo "   Pod status:"
    kubectl get pods --no-headers | while read line; do
        echo "   - $line"
    done
    
    # Check for pods not in Running state
    NOT_RUNNING=$(kubectl get pods --no-headers | grep -v "Running" | grep -v "Completed" | wc -l)
    if [ $NOT_RUNNING -gt 0 ]; then
        print_warning "$NOT_RUNNING pods are not in Running state"
    fi
else
    print_status 1 "No pods found"
fi

echo ""
echo "6. Checking Services..."
if kubectl get services > /dev/null 2>&1; then
    print_status 0 "Services found"
    
    echo "   Service status:"
    kubectl get services --no-headers | while read line; do
        echo "   - $line"
    done
    
    # Check for store-front external IP
    STORE_FRONT_IP=$(kubectl get service store-front -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ ! -z "$STORE_FRONT_IP" ]; then
        print_status 0 "Store-front external IP: $STORE_FRONT_IP"
        echo "   Application URL: http://$STORE_FRONT_IP"
    else
        print_warning "Store-front external IP not yet assigned"
        print_warning "Run: kubectl get service store-front -w"
    fi
else
    print_status 1 "No services found"
fi

echo ""
echo "7. Checking Application Components..."
COMPONENTS=("rabbitmq" "order-service" "product-service" "store-front")

for component in "${COMPONENTS[@]}"; do
    if kubectl get deployment $component > /dev/null 2>&1; then
        READY=$(kubectl get deployment $component -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
        DESIRED=$(kubectl get deployment $component -o jsonpath='{.spec.replicas}' 2>/dev/null)
        
        if [ "$READY" = "$DESIRED" ]; then
            print_status 0 "$component: Ready ($READY/$DESIRED)"
        else
            print_warning "$component: Not ready ($READY/$DESIRED)"
        fi
    else
        print_status 1 "$component: Not found"
    fi
done

echo ""
echo "8. Resource Usage Summary..."
echo "   Cluster resources:"
kubectl top nodes 2>/dev/null || print_warning "Metrics server not available"

echo ""
echo "=========================================="
echo "Verification Complete"
echo "=========================================="

echo ""
echo "Next steps:"
echo "1. If all checks pass, your application should be accessible"
echo "2. Use the store-front external IP to access the application"
echo "3. Monitor logs if any issues: kubectl logs deployment/<component>"
echo "4. Clean up when done: kubectl delete -f sample-app.yaml && terraform destroy"

echo ""
echo "Useful commands:"
echo "- Check pod logs: kubectl logs <pod-name>"
echo "- Describe resources: kubectl describe <resource> <name>"
echo "- Monitor pods: kubectl get pods -w"
echo "- Monitor services: kubectl get services -w" 