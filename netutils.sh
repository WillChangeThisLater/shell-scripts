#!/bin/bash

# How I use this:
#
# ```bash
# eval "$(./netutils.sh)" && cidrrange 10.0.0.4/8
# ```

function cidrrange() {

  # Regular Expression to match CIDR
  regex='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/(0|[1-2]?[0-9]|3[0-2])$'

  # Get input from stdin if arg not provided
  if [ -z "$1" ]; then
    read cidr
  else
    cidr=$1
  fi

  # Validate that the CIDR looks right
  if ! [[ "$cidr" =~ $regex ]]; then
    echo "Invalid CIDR Notation $cidr"
    return 1
  fi

  # Use nmap to show the addresses
  # Apparently '-n' stops nmap from actually scanning these addresses
  nmap -sL "$cidr" -n | grep "scan report" | awk '{print $5}'
}

function incidr() {

  # Regular expressions to match IP and CIDR formats
  ipRegex='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
  cidrRegex='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/(0|[1-2]?[0-9]|3[0-2])$'

  # assume ip address and CIDR are provided as arguments
  ipAddr="$1"
  cidr="$2"

  # validate the IP address
  if ! [[ "$ipAddr" =~ $ipRegex ]]; then
    echo "Invalid IP address $ipAddr"
    return 1
  fi

  # validate the CIDR
  if ! [[ "$cidr" =~ $cidrRegex ]]; then
    echo "Invalid CIDR Notation $cidr"
    return 1
  fi

  # TODO: this is kinda ugly for very big CIDRs
  if cidrrange "$cidr" | grep "$ipAddr" >/dev/null 2>&1; then
    echo "yes"
  else
    echo "no"
  fi
}

function randname() {
    cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 20
}

declare -f cidrrange
declare -f incidr
declare -f randname
