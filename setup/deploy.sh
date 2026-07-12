#!/bin/bash
set -e

echo "Creating backend infrastructure..."

cd bootstrap
terraform init
terraform apply -auto-approve

BUCKET=$(terraform output -raw bucket_name)

cd ../infrastructure

echo "Creating main infrastructure..."

terraform init -backend-config="bucket=${BUCKET}"
terraform apply -auto-approve

echo "Terraform completed successfully."
echo "Starting Ansible deployment..."

cd ansible

ansible-galaxy collection install -r requirements.yml

ansible docker_hosts -m ping

ansible-playbook playbooks/site.yml

echo "Ansible deployment completed successfully."