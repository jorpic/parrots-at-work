#!/usr/bin/env bash

#set -o pipefail

. lib/jwt.sh


function http_parse_request() { # continuation
  local method path _

  read -r method path _

  local header='{}'
  local content_length=0

  while read -r key val ; do
    key=$(echo -n "${key,,}" | tr -d ':\r\n')
    val=$(echo -n "$val" | tr -d '\r\n')

    [ -z "$key$val" ] && break

    header=$(jq -c --arg key "$key" --arg val "$val" '.[$key]=$val' \
      <<< "$header")

    [ "$key" = "content-length" ] && content_length=$val
  done

  case $method in
    GET)
      body=null
      ;;
    POST)
      ### FIXME: does not fail on a sequence of valid JSON values: `2[]{}`
      body=$(head -c $content_length | jq -c .)
      if [ $? -ne 0 ] ; then
        http_response 400 '{"error": "invalid JSON in body"}'
        return 400
      fi
      ;;
    *)
      http_response 405 '{"error": "method not supported"}'
      return 405
      ;;
  esac

  jq --null-input --compact-output \
    --arg method "$method"         \
    --arg path "$path"             \
    --argjson header "$header"     \
    --argjson body "$body"         \
    '{method: $method, path: $path, header: $header, body: $body}' \
    | $1
}


function http_parse_jwt() {
  local jwt_key_path=$1
  local request=$(jq -c .)

  jwt=$(jq -r '.header.auth' <<< "$request")
  jwt=${jwt#Bearer }
  if ! jwt_check "$jwt_key_path" "$jwt" ; then
    http_response 401 '{"error": "JWT: bad signature or expired"}'
    return 401
  fi

  echo -n "$request" \
    | jq --compact-output \
      --arg jwt "$(jwt_payload $jwt)" \
      '.auth = $jwt'
}


function http_response() { # http_code, json
  local len=$(echo -n "$2" | wc -c)
  tee > response_pipe <<EOF
HTTP/1.1 $1
Content-Type: application/json
Content-Length: $(($len + 2))

${2:-null}
EOF
}


function http_server() { # addr, port, handler
  rm -f response_pipe ; mkfifo response_pipe
  while [ 1 ] ; do
    cat response_pipe | ncat -lC $1 $2 | http_parse_request $3
  done
}
