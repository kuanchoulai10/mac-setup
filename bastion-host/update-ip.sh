#!/usr/bin/env bash
set -e

read -p "Enter AWS region (Default: ap-east-2): " AWS_REGION
export AWS_REGION="${AWS_REGION:-ap-east-2}"

read -p "Enter security group name (Default: bastion-sg): " SG_NAME
export SG_NAME="${SG_NAME:-bastion-sg}"

echo "Select location:"
echo "1) MacBook"
echo "2) Home"
read -p "Enter choice (1 or 2): " CHOICE

case $CHOICE in
  1)
    LOCATION="MACBOOK"
    ;;
  2)
    LOCATION="HOME"
    ;;
  *)
    echo "Invalid choice. Defaulting to MacBook."
    LOCATION="MACBOOK"
    ;;
esac

LOCATION_SSH="${LOCATION}-SSH"
echo "Selected location: ${LOCATION}"


echo "Getting Security Group ID for ${SG_NAME} in region ${AWS_REGION}..."
SG_ID=$(aws ec2 describe-security-groups \
  --region "$AWS_REGION" \
  --filters "Name=group-name,Values=${SG_NAME}" \
  --query 'SecurityGroups[0].GroupId' --output text)
echo "Security Group ID: ${SG_ID}"

echo "Finding rule IDs with description ${LOCATION_SSH}..."
RULE_IDS=$(aws ec2 describe-security-group-rules \
  --region "$AWS_REGION" \
  --filters "Name=group-id,Values=${SG_ID}" \
  --query "SecurityGroupRules[?Description=='${LOCATION_SSH}' && IsEgress==\`false\`].SecurityGroupRuleId" \
  --output text)
echo "Rule IDs found: ${RULE_IDS}"


if [ -n "${RULE_IDS}" ]; then
  echo "Revoking old ${LOCATION_SSH} rules..."
  aws ec2 revoke-security-group-ingress \
    --region "$AWS_REGION" \
    --group-id "$SG_ID" \
    --security-group-rule-ids ${RULE_IDS} > /dev/null
  echo "Old rules revoked." > /dev/null
fi

echo "Fetching new ${LOCATION} public IP..."
LOCATION_CIDR="$(curl -s https://checkip.amazonaws.com)/32"
echo "New ${LOCATION} Public IP: ${LOCATION_CIDR}"

echo "Authorizing new ${LOCATION_SSH} rule..."
aws ec2 authorize-security-group-ingress \
  --region "$AWS_REGION" \
  --group-id "$SG_ID" \
  --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=${LOCATION_CIDR},Description=${LOCATION_SSH}}]"  > /dev/null
echo "New rule authorized."

echo "Updated ${LOCATION_SSH} rule on SG ${SG_ID}"
