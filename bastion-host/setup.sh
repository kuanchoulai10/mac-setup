#!/bin/bash

set -e

# Stage 1
echo "Stage 1: Collecting user inputs ..."
read -p "  Enter AWS region (default: ap-east-2): " AWS_REGION
export AWS_REGION="${AWS_REGION:-ap-east-2}"

DEFAULT_MACBOOK_IP_CIDR="$(curl -s https://checkip.amazonaws.com)/32"
read -p "  Enter your MacBook public IP CIDR (default: $DEFAULT_MACBOOK_IP_CIDR): " MACBOOK_IP_CIDR
export MACBOOK_IP_CIDR="${MACBOOK_IP_CIDR:-$DEFAULT_MACBOOK_IP_CIDR}"

read -p "  Enter your HOME public IP CIDR (default: X.Y.Z.W/32): " HOME_IP_CIDR
export HOME_IP_CIDR="${HOME_IP_CIDR:-X.Y.Z.W/32}"

read -p "  Enter EC2 instance name (default: bastion-ec2): " INSTANCE_NAME
export INSTANCE_NAME="${INSTANCE_NAME:-bastion-ec2}"

read -p "  Enter SSH key pair name (default: bastion-key): " KEY_NAME
export KEY_NAME="${KEY_NAME:-bastion-key}"

read -p "  Enter security group name (default: bastion-sg): " SG_NAME
export SG_NAME="${SG_NAME:-bastion-sg}"



# Stage 2
echo "Stage 2: Creating SSH Key Pair ..."
echo "  Creating SSH key pair '$KEY_NAME' and saving to ~/.ssh/${KEY_NAME}.pem ..."
aws ec2 create-key-pair \
  --region "$AWS_REGION" \
  --key-name "$KEY_NAME" \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/${KEY_NAME}.pem
chmod 400 ~/.ssh/${KEY_NAME}.pem
echo "  SSH private key saved to ~/.ssh/${KEY_NAME}.pem"

echo "  Creating security group '$SG_NAME' ..."
export SG_ID=$(aws ec2 create-security-group \
  --region "$AWS_REGION" \
  --group-name "$SG_NAME" \
  --description "Bastion SG for reverse SSH" \
  --query 'GroupId' \
  --output text)
echo "  Security group created. SG_ID: $SG_ID"

echo "  Authorizing SSH ingress from MacBook public IP ($MACBOOK_IP_CIDR) ..."
aws ec2 authorize-security-group-ingress \
  --region "$AWS_REGION" \
  --group-id "$SG_ID" \
  --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=${MACBOOK_IP_CIDR},Description=MACBOOK-SSH}]"

echo "  Authorizing SSH ingress from HOME public IP ($HOME_IP_CIDR) ..."
aws ec2 authorize-security-group-ingress \
  --region "$AWS_REGION" \
  --group-id "$SG_ID" \
  --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=${HOME_IP_CIDR},Description=HOME-SSH}]"
echo "  Security group ingress rules configured."



# Stage 3
echo "Stage 3: Launching EC2 instance ..."
# 找最新的 Amazon Linux 2023 x86_64 AMI
echo "  Fetching latest Amazon Linux 2023 x86_64 AMI ..."
export AMI_ID=$(aws ec2 describe-images \
  --region "$AWS_REGION" \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023.*-x86_64" "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)
echo "  AMI ID: $AMI_ID"

echo "  Launching EC2 instance ..."
export INSTANCE_ID=$(aws ec2 run-instances \
  --region "$AWS_REGION" \
  --image-id "$AMI_ID" \
  --instance-type t3.micro \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_NAME}}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "  Waiting for EC2 instance ($INSTANCE_ID) to be ready ..."
aws ec2 wait instance-status-ok --region "$AWS_REGION" --instance-ids "$INSTANCE_ID"
export EC2_PUBLIC_IP=$(aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)
echo "  EC2 instance is running. (Public IP: $EC2_PUBLIC_IP)"
