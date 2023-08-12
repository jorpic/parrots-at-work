#!/usr/bin/env bash

function log_wait_for_topic() { # topic
  while [ 1 ] ; do
    echo waiting for redpanda to start...
    local res=$(rpk -X brokers=redpanda:9092 topic create "$1")
    if [[ "$res" =~ "TOPIC_ALREADY_EXISTS" ]] ; then
      break
    fi
    sleep 1
  done
}

function log_event() { # topic, event, payload
  jq -nc --arg ev "$2" --argjson val "$3" '{event: $ev, value: $val}' \
    | rpk -X brokers=redpanda:9092 topic produce "$1" \
    1>&2
}

function log_event_decode() {
  local line
  while read -r line ; do
    local value=$(jq -r .value <<< "$line")

    echo -n "$line" | jq -c --unbuffered \
      --arg ev "$(jq -r .event <<< "$value")" \
      --argjson val "$(jq -c .value <<< "$value")" \
      '.event = $ev | .value = $val'
  done
}

function log_consume() { # topic
  rpk -X brokers=redpanda:9092 topic consume "$1" \
    | jq --unbuffered -c | log_event_decode
}
