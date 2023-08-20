#!/usr/bin/env bash

function load_jwt_key() {
  while [ 1 ] ; do
    if curl -s auth:3000/jwt_key | jq -r '.pub' > pub ; then
      break
    fi
    sleep 1
  done
}

function load_json_schemas() {
  for path in $@ ; do
    local file="schema_$(echo -n "$path" | tr '/' '_')"
    while ! curl -s "schema_registry:3000/$path" -o $file ; do
      sleep 1
    done
  done
}
