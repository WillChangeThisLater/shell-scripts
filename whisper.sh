#!/bin/bash

set -euo pipefail

# This is a funny, hacky little script.
#


# get the current shell from $SHELL variable
# if not set, default to /bin/sh
function getShell() {
  shell="${SHELL:-/bin/sh}"
  echo "$shell"
}

# install some common packages
function install_packages() {

  packages="curl wget vim"

  if command -v apt-get &> /dev/null; then
    echo "Detected APT package manager"
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y $packages
  elif command -v dnf &> /dev/null; then
    echo "Detected DNF package manager"
    dnf install -y $packages
  elif command -v yum &> /dev/null; then
    echo "Detected YUM package manager"
    yum install -y $packages
  elif command -v pacman &> /dev/null; then
    echo "Detected Pacman package manager"
    pacman -Sy --noconfirm $packages
  elif command -v zypper &> /dev/null; then
    echo "Detected Zypper package manager"
    zypper install -y $packages
  elif command -v apk &> /dev/null; then
    echo "Detected APK package manager"
    apk add --no-cache $packages
  else
    echo "No known package manager found!"
    exit 1
  fi
}

set +u
file="$1"
if [ -z "$1" ]; then
  file="."
fi
set -u

echo "function unpackDir() {"
    echo "cat <<'EOF' | base64 -d | tar -xzf -"
    tar -czf - "$file" 2>/dev/null | base64
    echo "EOF"
echo "}"

# main function. this is the entry point to everything
function main() {

  # skipping this for now
  #install_packages
  unpackDir

  echo "Using shell $(getShell)"
  $(getShell)
}

# all functions have to be declared to be used
declare -f getShell
declare -f install_packages
declare -f main

# you can expose specific functions if you want

# this is what actually runs the 'setup' function
echo "main"
