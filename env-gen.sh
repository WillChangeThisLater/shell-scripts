#!/opt/homebrew/bin/bash

set -euo pipefail

declare -A env_variables

get_secret_from_ps() {
  set -euo pipefail

  local parameterName="$1"

  # remove leading @secret and whatever double quotes we find
  secretName=$(echo "$parameterName" | sed 's/.*@secret //' | tr -d '"')

  # get the secret and echo it out
  secret=$(aws ssm get-parameter --name "$secretName" --with-decryption | jq -r '.Parameter.Value')
  echo $secret
}

set +u
if [ -z "$1" ]; then
    echo "Usage: $0 <env.txt>"
    exit 1
fi
set -u


while IFS= read -r line
do

    # Skip empty lines
    [ -z "$line" ] && continue

    # Split the line into variable and value
    variable_name="${line%%=*}"
    variable_value="${line#*=}"

    # Check if the variable value starts with @secret
    if [[ "$variable_value" =~ @secret* ]]; then
        # Fetch the secret from the parameter store
        secret_value=$(get_secret_from_ps "$variable_value")
    else
        # Use the value as is
        secret_value="$variable_value"
    fi

    env_variables["$variable_name"]="$secret_value"

done < "$1"

for key in "${!env_variables[@]}"; do
    echo "export $key=${env_variables[$key]}"
done
