#!/bin/bash

# this requires a `profiles.json` file to run
# note that the `default` role only gets fired if your current default profile is NOT set
#
# mine looks something like:
#
# ```json
# {
#     "qa-personal": "arn:aws:iam::123456789012:role/saml-qa",
#     "stg-personal": "arn:aws:iam::123456789012:role/saml-stg",
#     "prd-personal": "arn:aws:iam::123456789012:role/saml-prd",
#     "qa-work": "arn:aws:iam::888888888888:role/saml-qa",
#     "stg-work": "arn:aws:iam::888888888888:role/saml-stg",
#     "prd-work": "arn:aws:iam::888888888888:role/saml-prd",
#     "default": "arn:aws:iam::888888888888:role/saml-qa",
# }
# ```
#
#
# i like to put this on a cron job to auto log me in to all roles every hour
#
# okta 429s if you hit it too fast. the timeout helps a little with that, but
# may need to be adjusted

set -euxo pipefail

awsLogin() {
  role="$1"
  profile="$2"
  echo "Logging into role $role with profile $profile" >&2
  /usr/local/bin/saml2aws login --force --skip-prompt --role "$role" --profile "$profile" &
}

getDefaultArn() {
  set +eu
  cat ~/.aws/credentials | grep -A 7 default | grep x_principal_arn | awk '{print $3}' | sed 's|/[^/]*$||' | sed 's/assumed-role/role/g' | sed 's/aws:sts/aws:iam/g'
  set -eu
}

set +u
if [[ -n "$1" ]]; then
    json_file="$1"
else
    json_file="profiles.json"
fi
set -u

# Check if the JSON file exists
if [[ ! -f "$json_file" ]]; then
    echo "Error: Profile file '$json_file' not found!" >&2
    exit 1
fi

defaultArn=""

# Loop through each key-value pair in the JSON object
jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$json_file" | while IFS= read -r line; do
    # Split the line into key and value using '=' as delimiter
    IFS='=' read -r profileName arn <<< "$line"

    # avoid 429
    sleep 1

    if [[ "$profileName" == "default" ]]; then
        echo "Default role found in $json_file"
        defaultArn="$arn"
    else
        awsLogin "$arn" "$profileName"
    fi
done
defaultProfileArn=$(getDefaultArn)

set +u
if [[ -n "$awsArn" ]]; then
    defaultProfileArn="$awsArn"
fi

if [[ -n "$defaultProfileArn" ]]; then
    awsLogin "$defaultProfileArn" "default"
fi
