#!/usr/bin/env bash

. lib/base64url.sh
. lib/ed25519.sh


function jwt_sign() {
  local key_path=$1
  local payload=$2
  header='{"alg":"ES256","typ":"JWT"}'
  jwt=$(echo -n $header | base64url).$(echo -n $payload | base64url)
  echo -n $jwt.$(ed25519_sign "$key_path" "$jwt")
}

function jwt_payload() {
  echo -n "$1" | sed 's/.*\.\(.*\)\..*/\1/' | base64url -id
}

## FIXME: check `exp > now`
function jwt_check() { # pub_key jwt
  ed25519_verify_sig "$1" ${2%.*} ${2##*.}
}


function jwt_test_payload() {
  local payload='{"hello":"world"}'
  local jwt='eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6IndvcmxkIn0.KkC_NHITxQlUml9qsH6b-6PisGtEVOrP-l2DqStj-zedcqyY9KcAWBBGFsylOMK94hp6j-VdlRj8dQVHJeFZDw'
  [ "$(jwt_payload $jwt)" = "$payload" ]
}

function jwt_test_sig() {
  local msg="hello, world!"

  local tmp=$(mktemp -d)
  ed25519_generate_keys "$tmp"

  local jwt=$(jwt_sign "$tmp/key" "$msg")
  jwt_check "$tmp/pub" "$jwt"
  local res=$?

  rm -r "$tmp"
  return $res
}
