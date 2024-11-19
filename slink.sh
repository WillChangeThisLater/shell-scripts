#!/usr/bin/env bash
#
# Easy way to symlink programs into PATH
#
# Examples:
#
#   slink -f slink.sh
#   slink -f $(pwd)/slink.sh -d /usr/local/bin
#   slink -f slink.sh -d /usr/local/bin -n mylink

function usage {
  cat <<EOF
Usage: $0 [-d <targetDir>] [-n <programName>] [-h help] [-f force] <file>

  -d <targetDir>: The target directory you want to link the program into. Defaults to /usr/local/bin
EOF
  exit 1
}


# using a seperate links() function lets me share this function with machines I SSH into
#
# ```bash
#  # This is a genius trick. See minute 40 of https://www.youtube.com/watch?v=uqHjc7hlqd0 for explanation
#  # Note that we can't `source slink.sh` directly since that would invoke the function
#  ssh -i ~/.ssh/hetzner root@IP "$(source function.sh && declare -f usage && declare -f links); links -h"
# ```
links() {
  # Argument parsing
  if [[ $# -lt 1 ]]; then
    usage
  fi
  force=false
  while getopts "d:n:hf" opt; do
    case "$opt" in
      d)
        targetDir="$OPTARG"
        ;;
      n)
        programName="$OPTARG"
        ;;
      h)
        usage
        ;;
      f)
        force=true
        ;;
      *)
        usage
        ;;
    esac
  done
  shift "$(( OPTIND - 1 ))"
  file=$1
  if [[ -z $file ]]; then
    usage
  fi
  
  # Figure out the directory we'll be linking in,
  # and the link name we want to use
  targetDir="${targetDir:-/usr/local/bin}"
  programName="${programName:-$(basename ${file%%.*})}"

  # Make sure the file passed in exists and is executable
  if ! [[ -f $file ]]; then
    echo "File $file does not exist"
    exit 1
  fi
  if ! [[ -x $file ]]; then
    echo "File $file is not executable"
    exit 1
  fi
  
  # Make sure targetDir exists and shows up in PATH
  if ! [[ -d "$targetDir" ]]; then
    echo "link directory $targetDir does not exist"
    exit 1
  fi
  if [[ ":$PATH:" != *":$targetDir:"* ]]; then
    echo "link directory $targetDir is not in PATH"
    exit 1
  fi
  
  # generate path to the link and make sure it doesn't already exist
  currentpath=$(realpath "$file")
  linkpath="$targetDir/$programName"
  
  if [ "$force" != true ]; then
    # sanity check the programName
    if command -v "$programName" >/dev/null 2>&1; then
      echo "A command named $programName was found somewhere in your PATH. Use -f to force"
      exit 1
    fi
    if [[ -L $linkpath ]]; then
      echo "A symlink already exists at $linkpath. Use -f to force"
      exit 1
    fi
    command="ln -s $currentpath $linkpath"
  else
    command="ln -sf $currentpath $linkpath"
  fi
  
  echo "$command"
  /bin/sh -c "$command"
}

links
