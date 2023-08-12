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
  jq -nc --argjson payload "$3" "{$2: \$payload}" \
    | rpk -X brokers=redpanda:9092 topic produce "$1" \
    1>&2
}
