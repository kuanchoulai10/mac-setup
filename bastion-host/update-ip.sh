#!/usr/bin/env bash
set -euo pipefail

# Function to install Homebrew
install_homebrew() {
  echo "Homebrew is not installed."
  read -p "Do you want to install Homebrew? (y/n): " install_brew
  if [ "$install_brew" = "y" ] || [ "$install_brew" = "Y" ]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Homebrew installed successfully."
  else
    echo "Homebrew is required to install missing dependencies. Exiting."
    exit 1
  fi
}

# Check if Homebrew is installed
check_homebrew() {
  if ! command -v brew &> /dev/null; then
    install_homebrew
  fi
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "AWS CLI is not installed."
  read -p "Do you want to install AWS CLI? (y/n): " install_aws
  if [ "$install_aws" = "y" ] || [ "$install_aws" = "Y" ]; then
    check_homebrew
    echo "Installing AWS CLI..."
    brew install awscli
    echo "AWS CLI installed successfully."
  else
    echo "AWS CLI is required. Exiting."
    exit 1
  fi
fi

# Check if gum is installed
if ! command -v gum &> /dev/null; then
  echo "gum is not installed."
  read -p "Do you want to install gum? (y/n): " install_gum
  if [ "$install_gum" = "y" ] || [ "$install_gum" = "Y" ]; then
    check_homebrew
    echo "Installing gum..."
    brew install gum
    echo "gum installed successfully."
  else
    echo "gum is required. Exiting."
    exit 1
  fi
fi

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
      --header "Choose a Security Group to configure" \
      --selected "bastion-sg"
)

sg_id=$(aws ec2 describe-security-groups \
  --region $region \
  --profile $profile \
  --filters "Name=group-name,Values=${sg_name}"\
  --query "SecurityGroups[0].GroupId" \
  --output text
)

# Function to get and format security group rules
get_security_group_rules() {
  aws ec2 describe-security-group-rules \
    --region $region \
    --profile $profile \
    --filters "Name=group-id,Values=${sg_id}" \
    --query "SecurityGroupRules[?IsEgress==\`false\`].[SecurityGroupRuleId,Description,CidrIpv4,IpProtocol,FromPort,ToPort]" \
    --output text \
    | awk '{printf "%s | %s | CIDR: %s | Protocol: %s | Port: %s-%s\n", $1, $2, $3, $4, $5, $6}'
}

# Choose action: modify existing rule, create new rule, or delete rules
action=$(gum choose \
  --header "What would you like to do?" \
  "Modify existing rule" \
  "Create new rule" \
  "Delete rules"
)

if [ "$action" = "Modify existing rule" ]; then
  # Get security group rules
  rules_output=$(get_security_group_rules)

  if [ -z "$rules_output" ]; then
    gum style --foreground 196 "No security group rules found. Please create a new rule instead."
    exit 0
  fi

  # Format them for selection
  selected_rule=$(echo "$rules_output" | gum choose \
    --header "Choose a security group rule to modify CIDR")

  # Extract the rule ID, description, protocol, and ports from the selected rule
  rule_id=$(echo "$selected_rule" | awk -F' \\| ' '{print $1}')
  rule_desc=$(echo "$selected_rule" | awk -F' \\| ' '{print $2}')
  rule_protocol=$(echo "$selected_rule" | awk -F'Protocol: ' '{print $2}' | awk -F' \\|' '{print $1}')
  rule_from_port=$(echo "$selected_rule" | awk -F'Port: ' '{print $2}' | awk -F'-' '{print $1}')
  rule_to_port=$(echo "$selected_rule" | awk -F'Port: ' '{print $2}' | awk -F'-' '{print $2}' | awk -F' \\|' '{print $1}')

  # Get current IP
  my_ip=$(curl -s https://checkip.amazonaws.com)

  # Ask if user wants to modify, showing current IP in the prompt
  if gum confirm "Your current IP: ${my_ip}. Do you want to modify ${rule_desc}'s CIDR to ${my_ip}/32?"; then
    # Revoke the old rule
    gum style --foreground 244 "Revoking old rule..."
    aws ec2 revoke-security-group-ingress \
      --region "$region" \
      --profile "$profile" \
      --group-id "$sg_id" \
      --security-group-rule-ids "$rule_id" > /dev/null

    gum style --foreground 244 "Old rule revoked."

    # Add the new rule with updated CIDR
    gum style --foreground 244 "Authorizing new rule..."
    aws ec2 authorize-security-group-ingress \
      --region "$region" \
      --profile "$profile" \
      --group-id "$sg_id" \
      --ip-permissions "IpProtocol=$rule_protocol,FromPort=$rule_from_port,ToPort=$rule_to_port,IpRanges=[{CidrIp=${my_ip}/32,Description=${rule_desc}}]" > /dev/null

    gum style --foreground 244 "New rule authorized."

    gum style --foreground 46 "✓ Successfully updated ${rule_desc} CIDR to ${my_ip}/32"
  else
    exit 0
  fi

elif [ "$action" = "Create new rule" ]; then
  # Create new rule
  my_ip=$(curl -s https://checkip.amazonaws.com)

  new_rule_desc=$(gum input \
    --prompt "Enter rule description (e.g., MACBOOK-SSH, HOME-SSH) > ")

  new_rule_protocol=$(gum choose \
    --header "Choose protocol" \
    --selected "tcp" \
    "tcp" "udp" "icmp" "all")

  if [ "$new_rule_protocol" != "icmp" ] && [ "$new_rule_protocol" != "all" ]; then
    new_rule_from_port=$(gum input \
      --prompt "Enter from port > " \
      --value "22")

    new_rule_to_port=$(gum input \
      --prompt "Enter to port > " \
      --value "22")
  else
    new_rule_from_port="-1"
    new_rule_to_port="-1"
  fi

  new_rule_cidr=$(gum input \
    --prompt "Enter CIDR > " \
    --value "${my_ip}/32")

  # Confirm before creating
  if gum confirm "Description: ${new_rule_desc} | Protocol: ${new_rule_protocol} | Port: ${new_rule_from_port}-${new_rule_to_port} | CIDR: ${new_rule_cidr}. Create this rule?"; then
    gum style --foreground 244 "Creating new rule..."

    if [ "$new_rule_protocol" = "all" ]; then
      aws ec2 authorize-security-group-ingress \
        --region "$region" \
        --profile "$profile" \
        --group-id "$sg_id" \
        --ip-permissions "IpProtocol=-1,IpRanges=[{CidrIp=${new_rule_cidr},Description=${new_rule_desc}}]" > /dev/null
    else
      aws ec2 authorize-security-group-ingress \
        --region "$region" \
        --profile "$profile" \
        --group-id "$sg_id" \
        --ip-permissions "IpProtocol=${new_rule_protocol},FromPort=${new_rule_from_port},ToPort=${new_rule_to_port},IpRanges=[{CidrIp=${new_rule_cidr},Description=${new_rule_desc}}]" > /dev/null
    fi

    gum style --foreground 46 "✓ Successfully created new rule: ${new_rule_desc}"
  else
    exit 0
  fi

elif [ "$action" = "Delete rules" ]; then
  # Get security group rules
  rules_output=$(get_security_group_rules)

  if [ -z "$rules_output" ]; then
    gum style --foreground 196 "No security group rules found. Please create a new rule instead."
    exit 0
  fi

  # Use gum choose with --no-limit for multi-selection
  selected_rules=$(echo "$rules_output" | gum choose \
    --no-limit \
    --header "Choose security group rules to delete (space to select, enter to confirm)")

  if [ -z "$selected_rules" ]; then
    echo "No rules selected. Exiting."
    exit 0
  fi

  # Show selected rules and confirm
  echo "Selected rules to delete:"
  echo "$selected_rules" | while IFS= read -r rule; do
    echo "  • $rule"
  done
  echo ""

  if gum confirm "Delete these rules?"; then
    # Delete rules one by one
    while IFS= read -r rule_line; do
      rule_id=$(echo "$rule_line" | awk -F' \\| ' '{print $1}')
      rule_desc=$(echo "$rule_line" | awk -F' \\| ' '{print $2}')

      gum style --foreground 244 "Deleting rule: ${rule_desc} (${rule_id})..."
      aws ec2 revoke-security-group-ingress \
        --region "$region" \
        --profile "$profile" \
        --group-id "$sg_id" \
        --security-group-rule-ids "$rule_id" > /dev/null

      gum style --foreground 46 "✓ Deleted: ${rule_desc}"
    done <<< "$selected_rules"

    gum style --foreground 46 "✓ All selected rules deleted successfully"
  else
    exit 0
  fi
fi
