#!/usr/bin/env bash

function base64url() {
  if [ -z "$1" ] ; then
    base64 $1 | tr '/+' '_-' | tr -d '=\n'
  else
    tr '_-' '/+' | base64 $1
  fi 2> /dev/null
}
