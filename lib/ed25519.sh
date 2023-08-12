#!/usr/bin/env bash

. lib/base64url.sh

function ed25519_generate_keys() {
  local key_dir=$1
  openssl genpkey -algorithm Ed25519 -out "$key_dir/key"
  openssl pkey -in "$key_dir/key" -pubout -out "$key_dir/pub"
}


function ed25519_sign() {
  local key_path=$1
  local tmp=$(mktemp -d)
  echo -n $2 > "$tmp/msg"
  openssl pkeyutl -sign -inkey "$key_path" -rawin -in "$tmp/msg" | base64url
  rm -rf $tmp
}


function ed25519_verify_sig() {
  local key_path=$1
  local tmp=$(mktemp -d)
  echo -n $2 > "$tmp/msg"
  echo -n $3 | base64url -d > "$tmp/sig"
  openssl pkeyutl -verify -pubin -inkey "$key_path" -rawin -in "$tmp/msg" -sigfile "$tmp/sig" \
    > /dev/null
  local res=$?
  rm -rf $tmp
  return $res
}


function ed25519_test() {
  local tmp=$(mktemp -d)
  ed25519_generate_keys "$tmp"
  local sig=$(ed25519_sign "$tmp/key" "hello, world!")
  ed25519_verify_sig "$tmp/pub" "hello, world!" "$sig"
  local res=$?
  rm -rf $tmp
  return $res
}
