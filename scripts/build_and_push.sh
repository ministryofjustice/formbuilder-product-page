#!/bin/sh
set -e

echo "*** Updating Ubuntu ***"
sudo apt update
echo "**********************************"
echo
echo "*** Installing kubctl ***"
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl
echo "**********************************"
echo
echo "*** Test install kubctl ***"
kubectl version --client
echo "**********************************"
echo

if [ "${CIRCLE_BRANCH}" == "main" ]; then
  echo "PRODUCTION"
  echo $ENVIRONMENT
else
  echo "*** Setting up Kubectl config STAGING ***"
  echo $ENVIRONMENT
  echo -n ${EKS_CLUSTER_CERT_STAGING} | base64 -d > ./ca.crt
  kubectl config set-cluster ${EKS_CLUSTER_NAME} --certificate-authority=./ca.crt --server=https://${EKS_CLUSTER_NAME}
  kubectl config set-credentials ${EKS_SERVICE_ACCOUNT_STAGING} --token=${EKS_TOKEN_STAGING}
  kubectl config set-context ${EKS_CLUSTER_NAME} --cluster=${EKS_CLUSTER_NAME} --user=${EKS_SERVICE_ACCOUNT_STAGING} --namespace=${EKS_NAMESPACE_STAGING}
  kubectl config use-context ${EKS_CLUSTER_NAME}
  echo "**********************************"
  echo
  echo "*** Exporting environment variables STAGING ***"
  export AWS_DEFAULT_REGION=eu-west-2
  export AWS_ACCESS_KEY_ID=$(kubectl get secrets -n ${EKS_NAMESPACE_STAGING} ${ECR_CREDENTIALS_SECRET_STAGING} -o json | jq -r '.data["access_key"]' | base64 -d)
  export AWS_SECRET_ACCESS_KEY=$(kubectl get secrets -n ${EKS_NAMESPACE_STAGING} ${ECR_CREDENTIALS_SECRET_STAGING} -o json | jq -r '.data["secret_access_key"]' | base64 -d)
  export ECR_REPO_URL=$(kubectl get secrets -n ${EKS_NAMESPACE_STAGING} ${ECR_CREDENTIALS_SECRET_STAGING} -o json | jq -r '.data["repo_url"]' | base64 -d)
  echo "**********************************"
  echo
fi

