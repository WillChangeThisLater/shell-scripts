#!/bin/bash

set -euox pipefail

./slink.sh slink.sh
for file in *.{sh,py}; do
  if [[ "$file" != "slink.sh" && "$file" != "setup.sh" ]]; then 
    slink "$file"
  fi
done
