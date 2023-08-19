#!/usr/bin/env bash

. lib/redpanda.sh

function process_tasks() {
  while read -r event ; do
    local bird=$(jq -r .value.bird <<< "$event")
    local task=$(jq -r .value.task <<< "$event")
    case "$(jq -r .event_name <<< "$event")" in
      created | reassigned)
        sqlite3 db <<EOF
          insert into tx(bird_id, amount, reason)
            select $bird, -1 * task.fee, json_object('task_fee', task.tid)
              from task where tid = $task;
EOF
        ;;
      completed)
        sqlite3 db <<EOF
          insert into tx(bird_id, amount, reason)
            select $bird, task.reward, json_object('task_reward', task.tid)
              from task where tid = $task;
EOF
        ;;
      *) echo ERROR: unknown event type in topic process_tasks: $event
    esac
  done
}

log_consume task_lifecycle | process_tasks
