profile=$(
  aws configure list-profiles \
  | gum choose \
      --header "Choose a AWS profile to use" \
      --selected "personal"
)

region=$(
  gum choose \
    --header "Choose a AWS Region" \
    --selected "ap-east-2" \
    "ap-east-2" "ap-east-1"
)

sg_name=$(
  aws ec2 describe-security-groups \
    --region $region \
    --profile $profile \
    --query "SecurityGroups[*].[GroupName]" \
    --output text \
  | gum choose \
      --header "Choose a Security Group to configure"
)

sg_id=$(aws ec2 describe-security-groups \
  --region $region \
  --profile $profile \
  --filters "Name=group-name,Values=${sg_name}"\
  --query "SecurityGroups[0].[GroupId]"
)

aws ec2 describe-security-group-rules \
  --region $region \
  --profile $profile \
  --filters "Name=group-id,Values=${sg_id}" \
  --output json | jq
