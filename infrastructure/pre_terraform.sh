#!/bin/bash
set -e

SG_NAME="app-server-sg"
VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --region eu-west-1 --query "Vpcs[0].VpcId" --output text)
SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$SG_NAME Name=vpc-id,Values=$VPC_ID --region eu-west-1 --query "SecurityGroups[0].GroupId" --output text)

if [ "$SG_ID" != "None" ] && [ "$SG_ID" != "" ]; then
  echo "Security group $SG_NAME already exists with ID $SG_ID. Importing into Terraform state..."
  terraform import aws_security_group.app_server_sg $SG_ID || true
else
  echo "Security group $SG_NAME does not exist. Terraform will create it."
fi 