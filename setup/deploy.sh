#!/bin/bash
set -e

echo "Creating backend infrastructure..."

cd bootstrap
terraform init
terraform apply -auto-approve

BUCKET=$(terraform output -raw bucket_name)

cd ../infrastructure

terraform init -backend-config="bucket=${BUCKET}"

terraform apply -auto-approve
