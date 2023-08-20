#!/usr/bin/env bash

function load_jwt_key() {
  while [ 1 ] ; do
    if curl -s auth:3000/jwt_key | jq -r '.pub' > pub ; then
      break
    fi
    sleep 1
  done
}
