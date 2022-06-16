#!/bin/sh
set -e

echo "*** Updating and installing required software ***"
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
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

if [ $CIRCLE_BRANCH == "master" ] ;  then
  echo "*** Setting up Kubectl config PROD ***"
  export ENVIRONMENT=prod
  echo ${ENVIRONMENT}
  echo -n ${EKS_CLUSTER_CERT_PROD} | base64 -d > ./ca.crt
  kubectl config set-cluster ${EKS_CLUSTER_NAME} --certificate-authority=./ca.crt --server=https://${EKS_CLUSTER_NAME}
  kubectl config set-credentials ${EKS_SERVICE_ACCOUNT_PROD} --token=${EKS_TOKEN_PROD}
  kubectl config set-context ${EKS_CLUSTER_NAME} --cluster=${EKS_CLUSTER_NAME} --user=${EKS_SERVICE_ACCOUNT_PROD} --namespace=${EKS_NAMESPACE_PROD}
  kubectl config use-context ${EKS_CLUSTER_NAME}
  echo "*** Done ***"
  echo "**********************************"
  echo
  echo "*** Exporting environment variables PROD ***"
  export AWS_DEFAULT_REGION=eu-west-2
  export AWS_ACCESS_KEY_ID=$(kubectl get secrets -n ${EKS_NAMESPACE_PROD} ${ECR_CREDENTIALS_SECRET_PROD} -o json | jq -r '.data["access_key"]' | base64 -d)
  export AWS_SECRET_ACCESS_KEY=$(kubectl get secrets -n ${EKS_NAMESPACE_PROD} ${ECR_CREDENTIALS_SECRET_PROD} -o json | jq -r '.data["secret_access_key"]' | base64 -d)
  export ECR_REPO_URL=$(kubectl get secrets -n ${EKS_NAMESPACE_PROD} ${ECR_CREDENTIALS_SECRET_PROD} -o json | jq -r '.data["repo_url"]' | base64 -d)
  echo "*** Done ***"
  echo "**********************************"
  echo
else
  echo "*** Setting up Kubectl config STAGING ***"
  export ENVIRONMENT=staging
  echo ${ENVIRONMENT}
  echo -n ${EKS_CLUSTER_CERT_STAGING} | base64 -d > ./ca.crt
  kubectl config set-cluster ${EKS_CLUSTER_NAME} --certificate-authority=./ca.crt --server=https://${EKS_CLUSTER_NAME}
  kubectl config set-credentials ${EKS_SERVICE_ACCOUNT_STAGING} --token=${EKS_TOKEN_STAGING}
  kubectl config set-context ${EKS_CLUSTER_NAME} --cluster=${EKS_CLUSTER_NAME} --user=${EKS_SERVICE_ACCOUNT_STAGING} --namespace=${EKS_NAMESPACE_STAGING}
  kubectl config use-context ${EKS_CLUSTER_NAME}
  echo "*** Done ***"
  echo "**********************************"
  echo
  echo "*** Exporting environment variables STAGING ***"
  export AWS_DEFAULT_REGION=eu-west-2
  export AWS_ACCESS_KEY_ID=$(kubectl get secrets -n ${EKS_NAMESPACE_STAGING} ${ECR_CREDENTIALS_SECRET_STAGING} -o json | jq -r '.data["access_key"]' | base64 -d)
  export AWS_SECRET_ACCESS_KEY=$(kubectl get secrets -n ${EKS_NAMESPACE_STAGING} ${ECR_CREDENTIALS_SECRET_STAGING} -o json | jq -r '.data["secret_access_key"]' | base64 -d)
  export ECR_REPO_URL=$(kubectl get secrets -n ${EKS_NAMESPACE_STAGING} ${ECR_CREDENTIALS_SECRET_STAGING} -o json | jq -r '.data["repo_url"]' | base64 -d)
  echo "*** Done ***"
  echo "**********************************"
  echo
fi

echo
echo "*** npm install ***"
npm install
echo "**********************************"
echo
echo "*** install bundler correct version and run ***"
npm install
sudo gem install bundler -v 2.1.4
bundle install
echo "**********************************"
echo
echo "*** Build Middleman site ***"
bundle exec middleman build
echo "**********************************"
echo

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

echo  '*** Building docker image... ***'
login="$(AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} aws ecr get-login --no-include-email)"
${login}
echo "**********************************"
echo

echo '*** Pushing docker image... ***'
out=$(docker push ${ECR_REPO_URL}:latest)
echo $out
echo "**********************************"
echo

if [ $CIRCLE_BRANCH == "master" ] ;  then
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

