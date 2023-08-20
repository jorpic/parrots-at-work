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

function check_json { # topic, event, version, payload
  local res
  if ! res=$(boon "schema_$1_$2_$3" <(jq -c <<< "$4") 2>&1) ; then
    echo ERROR: schema check failed $@
    echo "$res"
    return 1
  fi
}

function log_event() { # topic, event, version, payload
  check_json $1 $2 $3 "$4" \
    && jq -nc --arg ev "$2" --arg ver $3 --argjson val "$4" \
      '{event_name: $ev, event_version: ($ver | tonumber), value: $val}' \
      | rpk -X brokers=redpanda:9092 topic produce "$1"
}

function log_event_decode() { # topic
  local line
  while read -r line ; do
    local value=$(jq -rc .value <<< "$line")
    local event_name=$(jq -r .event_name <<< "$value")
    local event_version=$(jq -r .event_version <<< "$value")
    value=$(jq -c .value <<< "$value")

    check_json $1 $event_name $event_version "$value"

    echo -n "$line" | jq -c --unbuffered \
      --arg ev "$event_name" \
      --arg ver "$event_version" \
      --argjson val "$value" \
      '.event_name = $ev | .event_version = ($ver | tonumber) | .value = $val'
  done
}

function log_consume() { # topic
  rpk -X brokers=redpanda:9092 topic consume "$1" \
    | jq --unbuffered -c | log_event_decode "$1"
}
