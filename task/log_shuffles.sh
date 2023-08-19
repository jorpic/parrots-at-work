#!/usr/bin/env bash

. lib/redpanda.sh


function notify_all() {
  while read -r line ; do
    log_event task_streaming updated "$line"
    log_event task_lifecycle reassigned \
      "$(jq -c '{bird: .assigned_to, task: .task_id}' <<< "$line")"
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
