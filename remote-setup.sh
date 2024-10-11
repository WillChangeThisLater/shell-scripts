#!/bin/bash

set -euo pipefail

# Setup script for remote things.
#
# Usage:
#
# ```bash
# docker run -it ubuntu /bin/sh -c "$(./setup.sh)"
# ```
#
# This relies on the 'declare' trick described in this advanced bash
# scripting video: https://www.youtube.com/watch?v=uqHjc7hlqd0&t=1522s
#
# You should be able to run this via SSH too, though
# it will make permanent changes to the system
# (e.g. install_packages will install packages)
# Be warned


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

# main function. this is the entry point to everything
function main() {
  install_packages

  echo "Using shell $(getShell)"
  $(getShell)
}

# all functions have to be declared to be used
declare -f getShell
declare -f install_packages
declare -f main

# you can expose specific functions if you want
#echo "export -f echoGood"

# this is what actually runs the 'setup' function
echo "main"
