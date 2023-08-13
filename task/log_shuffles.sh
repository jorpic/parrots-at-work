#!/usr/bin/env bash

. lib/redpanda.sh


function notify_all() {
  local line
  while read -r line ; do
    log_event task reassigned "$line"
  done
}

while [ 1 ] ; do
  sleep 2
  if res=$(sqlite3 -json db <<EOF
    select * from shuffle
      where shuffle_id = (select min(shuffle_id) from shuffle);
EOF
    ) ; then
    echo -n "$res" | jq -c '.[]' | notify_all
    sqlite3 -json db <<EOF
      delete from shuffle
        where shuffle_id = (select min(shuffle_id) from shuffle);
EOF
  fi
done
