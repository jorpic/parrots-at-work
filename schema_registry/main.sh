#!/usr/bin/env bash

. lib/http.sh

function handle_request() {
  local request
  read -r request

  case $(jq -r '.method' <<< "$request") in
    GET)
      local path=$(jq -r '.path' <<< "$request")
      path="registry/${path##*..}.json" # prevent from filesystem escaping
      if [ -e "$path" ] ; then
        http_response 200 "$(cat "$path" | jq -c)"
      else
        http_response 404 '{"Not": "Found!"}'
      fi
      ;;
  esac
}

http_server 0.0.0.0 3000 handle_request
