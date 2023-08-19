#!/usr/bin/env bash

function log_prepare_topics() { # topics
  for topic in $@ ; do
    while [ 1 ] ; do
      local res=$(rpk -X brokers=redpanda:9092 topic create "$topic")
      if [[ "$res" =~ "TOPIC_ALREADY_EXISTS" ]] ; then
        break
      fi
      echo waiting for redpanda to start $topictj...
      sleep 1
    done
  done
}

function log_event() { # topic, event, payload
  echo $1 $2 $3
  jq -nc --arg ev "$2" --argjson val "$3" '{event: $ev, value: $val}' \
    | rpk -X brokers=redpanda:9092 topic produce "$1"
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
