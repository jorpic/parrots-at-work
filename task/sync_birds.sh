#!/usr/bin/env bash

. lib/redpanda.sh

function sync_birds() {
  while read -r event ; do
    echo sync_birds: $event 1>&2
    # FIXME: upsert
    sqlite3 db 2>&1 <<EOF
      insert into bird(bid, name, role)
        values (
          $(jq -r .value.bid <<< "$event"),
          '$(jq -r .value.name <<< "$event")',
          '$(jq -r .value.role <<< "$event")'
        )
EOF
  done
}

log_consume bird_streaming | sync_birds
