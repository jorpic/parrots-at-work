#!/usr/bin/env bash

set -o pipefail

. lib/http.sh


sqlite3 db < schema.sql
ed25519_generate_keys .
PUB_KEY=$(cat pub)


function is_valid_bird_name() {
  [[ "$1" =~ ^(tweet|tweety|chirp|chirrup|chitter|chatter|peep){1,20}$ ]]
}


function register_bird() { # name
  local name=$(echo -n "$1" | xxd -ps)

  local role
  case $(echo $name | sha256sum | head -c1) in
    0) role=admin ;;
    1 | 2 | 3) role=manager ;;
    *) role=worker ;;
  esac

  local res
  if res=$(sqlite3 db 2>&1 <<EOF
    insert into bird(name, role)
      values (lower(x'$name'), '$role')
      returning json_object('bid', bid, 'name', name, 'role', role);
EOF
    ) ; then
    echo -n "$res"
  else
    jq -nc --arg err "$res" '{error: $err}'
    return 1
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
    echo "$res" | jq -c --arg jwt "$(jwt_sign key "$res")" '.jwt = $jwt'
  else
    jq -nc --arg err "$res" '{error: $err}'
    return 403
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
      if ! is_valid_bird_name "$name" ; then
        http_response 400 '{"error": "Invalid bird name"}'
        return
      fi

      if res=$(register_bird "$name") ; then
        http_response 200 "$res"
      else
        http_response 400 "$res"
      fi
      ;;

    POST/bird/login)
      local name=$(jq -r '.body.name' <<< "$request")

      if res=$(login_bird "$name") ; then
        http_response 200 "$res"
      else
        http_response 403 "$res"
      fi
      ;;

    *)
      http_response 404 '{"Chirp!": "Chirp!"}'
      ;;
  esac
}

http_server 0.0.0.0 3000 handle_request
