#################################################################################
### Template script to create an AWS Cluster
### Risk Management: 2022-09-13 Initial Version 
#################################################################################

export clusterName=riskaipcluster
export nodeGroupName=risk-standard-workers
export awsRegionName=us-east-2
export awsAccountID=359623030854
export awsContainerImageRegistries=602401143452.dkr.ecr.us-east-2.amazonaws.com

# Creating AWS Cluster https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html
echo "Creating AWS Cluster..."

eksctl create cluster --name ${clusterName} --region ${awsRegionName} --version 1.23 \
--nodegroup-name ${nodeGroupName} --node-type t3.xlarge --nodes 1 --nodes-min 1 --nodes-max 3 --managed

# Configure connection to an existing AWS EKS Kubernetes cluster on kubectl tool
aws eks update-kubeconfig --region ${awsRegionName}  --name ${clusterName} --alias ${clusterName}

# Creating an IAM OIDC provider for your cluster:  https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
echo "Creating an IAM OIDC provider..." 

export oidc_id=$(aws eks describe-cluster --name ${clusterName} --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

aws iam list-open-id-connect-providers | grep ${oidc_id}

eksctl utils associate-iam-oidc-provider --cluster ${clusterName} --approve

export oidc_id=$(aws eks describe-cluster --name ${clusterName} --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

# Deploy the Amazon EBS CSI driver  https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/ 
echo "Deploying the Amazon EBS CSI driver..." 

curl -o risk-ebs-csi-iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.9.0/docs/example-iam-policy.json

aws iam create-policy --policy-name RiskAmazonEKS_EBS_CSI_Driver_Policy --policy-document file://risk-ebs-csi-iam-policy.json

cat <<EOF > risk-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${awsAccountID}:oidc-provider/oidc.eks.${awsRegionName}.amazonaws.com/id/${oidc_id}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${awsRegionName}.amazonaws.com/id/${oidc_id}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

aws iam create-role \
--role-name RiskAmazonEKS_EBS_CSI_DriverRole \
--assume-role-policy-document file://"risk-trust-policy.json"
  
aws iam attach-role-policy \
--policy-arn arn:aws:iam::${awsAccountID}:policy/RiskAmazonEKS_EBS_CSI_Driver_Policy \
--role-name RiskAmazonEKS_EBS_CSI_DriverRole

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system \
eks.amazonaws.com/role-arn=arn:aws:iam::${awsAccountID}:role/RiskAmazonEKS_EBS_CSI_DriverRole

kubectl delete pods -n kube-system -l=app=ebs-csi-controller


# Deploy Metrics Server https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
echo "Deploying Metrics Server..." 
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml


exit 0

