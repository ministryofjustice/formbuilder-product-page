#!/bin/sh
set -e

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

echo -n ${K8S_CLUSTER_CERT} | base64 -d > ./ca.crt
kubectl config set-cluster ${K8S_CLUSTER_NAME} --certificate-authority=./ca.crt --server=https://api.${K8S_CLUSTER_NAME}
kubectl config set-credentials ${SERVICE_ACCOUNT} --token=${K8S_TOKEN}
kubectl config set-context ${K8S_CLUSTER_NAME} --cluster=${K8S_CLUSTER_NAME} --user=${SERVICE_ACCOUNT} --namespace=${K8S_NAMESPACE}
kubectl config use-context ${K8S_CLUSTER_NAME}

export AWS_DEFAULT_REGION=eu-west-2
export AWS_ACCESS_KEY_ID=$(kubectl get secrets -n ${K8S_NAMESPACE} ${ECR_CREDENTIALS_SECRET} -o json | jq -r '.data["access_key"]' | base64 -d)
export AWS_SECRET_ACCESS_KEY=$(kubectl get secrets -n ${K8S_NAMESPACE} ${ECR_CREDENTIALS_SECRET} -o json | jq -r '.data["secret_access_key"]' | base64 -d)
export ECR_REPO_URL=$(kubectl get secrets -n ${K8S_NAMESPACE} ${ECR_CREDENTIALS_SECRET} -o json | jq -r '.data["repo_url"]' | base64 -d)

npm install

sudo gem install bundler
bundle install
bundle exec middleman build

echo  'Building docker image...'
out=$(docker build -t ${ECR_REPO_URL}:${ENVIRONMENT}-latest .)
echo $out

echo 'Logging into AWS ECR...'
out=$(aws ecr get-login-password --region eu-west-2 | docker login --username ${ECR_USERNAME} --password-stdin ${ECR_PASSWORD})
echo $out

echo 'Pushing docker image...'
out=$(docker push ${ECR_REPO_URL}:${ENVIRONMENT}-latest)
echo $out

echo "Applying namespace configuration to ${K8S_NAMESPACE}..."
kubectl apply --filename "./deploy/${ENVIRONMENT}" -n ${K8S_NAMESPACE}

echo "Restarting pods..."
kubectl rollout restart deployments -n ${K8S_NAMESPACE}
