#!/usr/bin/env bash

. lib/redpanda.sh

function sync_birds() {
  while read -r event ; do
    echo -n "$event" \
      | jq -r '.value | [.bid, .name, .role] | @csv' \
      | sqlite3 -csv db ".import '|cat -' bird"
  done
}

log_consume bird_streaming | sync_birds
