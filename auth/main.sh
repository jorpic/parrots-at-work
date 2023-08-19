#!/usr/bin/env bash

set -o pipefail

. lib/http.sh
. lib/redpanda.sh


sqlite3 db < schema.sql
ed25519_generate_keys .
PUB_KEY=$(cat pub)

log_prepare_topics bird_streaming


function is_valid_bird_name() {
  [[ "$1" =~ ^(tweet|tweety|chirp|chirrup|chitter|chatter|peep){1,20}$ ]]
}


function register_bird() { # name
  local name=$(echo -n "$1" | xxd -ps)

  local role
  case $(echo $name | sha256sum | head -c1) in
    0) role=admin ;;
    1 | 2)  role=manager ;;
    3) role=accountant ;;
    *) role=worker ;;
  esac

  local res
  if res=$(sqlite3 -json db 2>&1 <<EOF
    insert into bird(name, role)
      values (lower(x'$name'), '$role')
      returning *;
EOF
    ) ; then
    res=$(jq -c '.[0]' <<< "$res")
    log_event bird_streaming created 1 "$res"
    http_response 200 "$res"
  else
    res=$(jq -nc --arg err "$res" '{error: $err}')
    http_response 400 "$res"
  fi
}


function login_bird() { # name
  local name=$(echo -n "$1" | xxd -ps)

  local res
  if res=$(sqlite3 db 2>&1 <<EOF
      select
        json_object(
          'bid', bid, 'role', role,
          'exp', strftime('%s', 'now') + 666
        )
      from bird
      where name = lower(x'$name');
EOF
    ) ; then
    local jwt=$(jwt_sign key "$res")
    res=$(jq -c --arg jwt "$jwt" '.jwt = $jwt' <<< "$res")
    http_response 200 "$res"
  else
    res=$(jq -nc --arg err "$res" '{error: $err}')
    http_response 403 "$res"
  fi
}


function handle_request() {
  local request res
  read -r request

  local route=$(jq -r '.method + .path' <<< "$request")
  case $route in
    GET/jwt_key)
      http_response 200 "$(jq -nc --arg key "$PUB_KEY" '{pub: $key}')"
      ;;

    POST/bird)
      local name=$(jq -r '.body.name' <<< "$request")
      name=${name,,}
      is_valid_bird_name "$name" && register_bird "$name" \
        || http_response 400 '{"error": "Invalid bird name"}'
      ;;

    POST/bird/login)
      local name=$(jq -r '.body.name' <<< "$request")
      login_bird "$name"
      ;;

    *)
      http_response 404 '{"Chirp!": "Chirp!"}'
      ;;
  esac
}

http_server 0.0.0.0 3000 handle_request
