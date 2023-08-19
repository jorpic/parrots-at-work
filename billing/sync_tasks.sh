#!/usr/bin/env bash

. lib/redpanda.sh

function sync_tasks() {
  while read -r event ; do
    echo -n "$event" \
      | jq -r '.value | [.tid, .title, .fee, .reward] | @csv' \
      | sqlite3 -csv db ".import '|cat -' task"
  done
}

log_consume task_streaming \
  | jq -c --unbuffered 'select(.event == "created")' \
  | sync_tasks
