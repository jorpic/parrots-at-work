#!/usr/bin/env bash

. lib/redpanda.sh

function sync_birds() {
  local event
  while read -r event ; do
    echo sync_birds: $event 1>&2
    # FIXME: upsert
    sqlite3 db 2>&1 <<EOF
      insert into bird(bid, name, role, event_offset)
        values (
          $(jq -r .value.bid <<< "$event"),
          '$(jq -r .value.name <<< "$event")',
          '$(jq -r .value.role <<< "$event")',
          '$(jq -r .offset <<< "$event")'
        )
EOF
  done
}

log_consume auth \
  | jq -c --unbuffered  'select(.event == "bird_registered")' \
  | sync_birds
