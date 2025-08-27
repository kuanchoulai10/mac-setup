#!/bin/bash

set -e

export AWS_REGION="ap-east-2" # Taiwan

# 你的目前 MACBOOK 公網 IP（用來限制 EC2 22/tcp）
export MACBOOK_IP_CIDR="$(curl -s https://checkip.amazonaws.com)/32"

# 家裡網路（HOME 所在）公網 IP（初次可手動填；之後若更動可再更新規則）
export HOME_IP_CIDR="X.Y.Z.W/32"



# 建立 SSH Key Pair
export KEY_NAME="bastion-key"
aws ec2 create-key-pair \
  --region "$AWS_REGION" \
  --key-name "$KEY_NAME" \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/${KEY_NAME}.pem
chmod 600 ~/.ssh/${KEY_NAME}.pem

# 建 SG
export SG_NAME="bastion-sg"
export SG_ID=$(aws ec2 create-security-group \
  --region "$AWS_REGION" \
  --group-name "$SG_NAME" \
  --description "Bastion SG for reverse SSH" \
  --query 'GroupId' \
  --output text)
echo "$SG_ID"

# 允許 MACBOOK IP 連 EC2:22（描述=MACBOOK-SSH）
aws ec2 authorize-security-group-ingress \
  --region "$AWS_REGION" \
  --group-id "$SG_ID" \
  --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=${MACBOOK_IP_CIDR},Description=MACBOOK-SSH}]"

# 允許 家裡(HOME) IP 連 EC2:22（描述=HOME-SSH）
aws ec2 authorize-security-group-ingress \
  --region "$AWS_REGION" \
  --group-id "$SG_ID" \
  --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=${HOME_IP_CIDR},Description=HOME-SSH}]"

# 建 EC2

# 找最新的 Amazon Linux 2023 x86_64 AMI
export AMI_ID=$(aws ec2 describe-images \
  --region "$AWS_REGION" \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023.*-x86_64" "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)
echo "$AMI_ID"

export INSTANCE_NAME="bastion-ec2"
export INSTANCE_ID=$(aws ec2 run-instances \
  --region "$AWS_REGION" \
  --image-id "$AMI_ID" \
  --instance-type t3.micro \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_NAME}}]" \
  --query 'Instances[0].InstanceId' \
  --output text)
echo "$INSTANCE_ID"

# 取EC2公網 IP
aws ec2 wait instance-status-ok --region "$AWS_REGION" --instance-ids "$INSTANCE_ID"
export EC2_PUBLIC_IP=$(aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)
echo "$EC2_PUBLIC_IP"
