#!/bin/sh
set -e

echo "*** Updating and installing required software ***"
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository --yes \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update && sudo apt-get install -y awscli docker-ce docker-ce-cli \
  containerd.io ruby-full nodejs

sudo curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.8/bin/linux/amd64/kubectl
sudo chmod +x /usr/bin/kubectl
  echo "*** Done ***"
  echo "**********************************"
  echo

if [ $CIRCLE_BRANCH == "main" ] ;  then
  echo "*** Setting up Kubectl config PROD ***"
  token=$(eval "echo \$EKS_TOKEN_PROD" | base64 -d)
  export ENVIRONMENT=prod
  echo ${ENVIRONMENT}
  echo -n ${EKS_CLUSTER_CERT_PROD} | base64 -d > ./ca.crt
  kubectl config set-cluster ${EKS_CLUSTER_NAME} --certificate-authority=./ca.crt --server=https://${EKS_CLUSTER_NAME}
  kubectl config set-credentials circleci --token="${token}"
  kubectl config set-context ${EKS_CLUSTER_NAME} --cluster=${EKS_CLUSTER_NAME} --user=circleci --namespace=${EKS_NAMESPACE_PROD}
  kubectl config use-context ${EKS_CLUSTER_NAME}
  echo "*** Done ***"
  echo "**********************************"
  echo
  echo "*** Exporting environment variables PROD ***"
  export AWS_DEFAULT_REGION=eu-west-2
  export ECR_REPO_URL="${AWS_ECR_REGISTRY_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/formbuilder/formbuilder-product-page"
  ECR_ROLE_TO_ASSUME=${ECR_ROLE_TO_ASSUME_PROD}
  echo "*** Done ***"
  echo "**********************************"
  echo
else
  echo "*** Setting up Kubectl config STAGING ***"
  token=$(eval "echo \$EKS_TOKEN_STAGING" | base64 -d)
  export ENVIRONMENT=staging
  echo ${ENVIRONMENT}
  echo -n ${EKS_CLUSTER_CERT_STAGING} | base64 -d > ./ca.crt
  kubectl config set-cluster ${EKS_CLUSTER_NAME} --certificate-authority=./ca.crt --server=https://${EKS_CLUSTER_NAME}
  kubectl config set-credentials circleci --token="${token}"
  kubectl config set-context ${EKS_CLUSTER_NAME} --cluster=${EKS_CLUSTER_NAME} --user=circleci --namespace=${EKS_NAMESPACE_STAGING}
  kubectl config use-context ${EKS_CLUSTER_NAME}
  echo "*** Done ***"
  echo "**********************************"
  echo
  echo "*** Exporting environment variables STAGING ***"
  export AWS_DEFAULT_REGION=eu-west-2
  export ECR_REPO_URL="${AWS_ECR_REGISTRY_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/formbuilder/formbuilder-product-page-staging"
  ECR_ROLE_TO_ASSUME=${ECR_ROLE_TO_ASSUME_STAGING}
  echo "*** Done ***"
  echo "**********************************"
  echo
fi

if [ "$ENVIRONMENT" == "staging" ]; then
  echo '*** Adding robots file to staging... ***'
  cp ./deploy/templates/staging_robots.txt ./build/robots.txt
  echo "** Done **"
  echo "**********************************"
  echo
  echo '*** Adding basic auth secret file to staging... ***'
  sed s/%BASIC_AUTH_STAGING%/${BASIC_AUTH_STAGING}/g \
    ./deploy/templates/staging_secret.yaml > ./deploy/staging/secret.yaml
  echo "** Done **"
  echo "**********************************"
  echo
fi

echo  '*** Building docker image... ***'
out=$(docker build -t ${ECR_REPO_URL}:latest .)
echo $out
echo "**********************************"
echo

echo  '*** logging in to ECR... ***'
login=$(AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} AWS_IAM_ROLE_ARN=${ECR_ROLE_TO_ASSUME} aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ECR_REGISTRY_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com)
echo $login
echo "**********************************" 
echo

echo '*** Pushing docker image... ***'
out=$(docker push ${ECR_REPO_URL}:latest)
echo $out
echo "**********************************"
echo

if [ $CIRCLE_BRANCH == "main" ] ;  then
  echo '*** prod branches ***'
  echo "*** Applying namespace configuration to ${EKS_NAMESPACE_PROD}... ***"
  kubectl apply --filename "./deploy/${ENVIRONMENT}" -n ${EKS_NAMESPACE_PROD}
  echo "**********************************"
  echo
  echo "*** Restarting pods... ***"
  kubectl rollout restart deployments -n ${EKS_NAMESPACE_PROD}
  echo "**********************************"
  echo
else
  echo '*** staging branches ***'
  echo "*** Applying namespace configuration to ${EKS_NAMESPACE_STAGING}... ***"
  kubectl apply --filename "./deploy/${ENVIRONMENT}" -n ${EKS_NAMESPACE_STAGING}
  echo "**********************************"
  echo
  echo "*** Restarting pods... ***"
  kubectl rollout restart deployments -n ${EKS_NAMESPACE_STAGING}
  echo "**********************************"
  echo
fi

