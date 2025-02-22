#!/bin/bash

# Usage:
#
# ```bash
# eval "$(./utils.sh)"
# ```

# https://blog.ropnop.com/docker-for-pentesters
dockershell() {
  docker run --rm -i -t --entrypoint=/bin/bash "$@"
}

# 
proxy() {
  # get mitmproxy PIDs
  # if there isn't a proxy running, exit
  proxy_pids=$(ps -x | grep mitmproxy | grep -v grep | awk '{print $1}')
  if [ -z $proxy_pids ]; then
    echo "no proxies running..."
    kill -INT $$
  fi

  # determine how many mitmproxy processes are running
  # if there's more than 1, bail out
  #
  # TODO: maybe at some point we want to make this selectable
  cnt_proxies=$(echo $proxy_pids | wc | awk '{print $1}')
  if [[ $cnt_proxies -gt 1 ]]; then
    echo "Too many proxies running ($cnt_proxies)"
    echo "$proxy_pids"
    kill -INT $$
  fi

  # figure out which port to use & spin up the appropriate command
  PORT=$(lsof -i -n -P -a -p $proxy_pids | grep -i listen | awk '{print $9}' | sed 's/^.*://g' | sort | uniq)
  if ! lsof -i -n -P | grep "$PORT" >/dev/null; then
    echo "Nothing listening on $PORT!"
  else
    echo "Running '${@:1}' using mitmproxy listening on port $PORT" >&2
    http_proxy=http://localhost:"$PORT" https_proxy=https://localhost:"$PORT" REQUESTS_CA_BUNDLE="$HOME/.mitmproxy/mitmproxy-ca-cert.pem" $@
  fi
}

peval() {
  pbpaste && eval "$(pbpaste)"
}

declare -f dockershell
declare -f proxy
declare -f peval
