#!/usr/bin/env bash

set -o pipefail

. lib/http.sh
. lib/redpanda.sh
. lib/service.sh

sqlite3 db < schema.sql
log_prepare_topics task_{streaming,lifecycle}
load_jwt_key
load_json_schemas \
  {bird,task}_streaming/created/1 \
  task_lifecycle/{created,reassigned,completed}/1

./sync_birds.sh &
./log_shuffles.sh &


# FIXME: can fail if there are no workers
function create_task() { # title
  local res
  if res=$(sqlite3 -json db 2>&1 <<EOF
    insert into task(title, fee, reward, assigned_to)
      select
        '' || x'$(echo -n "$1" | xxd -ps)',
        (abs(random()) % 10) + 10,
        (abs(random()) % 20) + 20,
        bid
      from bird where role = 'worker' order by random() limit 1
    returning *;
EOF
    ) ; then
    res=$(jq -c '.[0]' <<< "$res")
    log_event task_streaming created 1 "$res"
    log_event task_lifecycle created 1 \
      "$(jq -c '{bird: .assigned_to, task: .tid}' <<< "$res")"
    http_response 200 "$res"
  else
    res=$(jq -nc --arg err "$res" '{error: $err}')
    http_response 400 "$res"
  fi
}


function complete_task() { # bird_id, task_id
  local bid="cast(x'$(echo -n $1 | xxd -ps)' as int)"
  local tid="cast(x'$(echo -n $2 | xxd -ps)' as int)"
  local res
  if res=$(sqlite3 db 2>&1 <<EOF
    create temporary table response(code int not null, resp text not null);
    create temporary view my_task as
      select * from task where tid = $tid;

    begin immediate;
    insert into response
      select 404, json_object('error', 'Task not found')
      where not exists (select * from my_task);

    insert into response
      select 400, json_object('error', 'Already completed')
      from my_task
      where status = 'completed'
        and not exists (select * from response);

    insert into response
      select 401, json_object('error', 'This is not your task!')
      from my_task
      where assigned_to <> $bid
        and not exists (select * from response);

    update task
      set status = 'completed'
      where assigned_to = $bid
        and tid = $tid
        and not exists (select * from response);

    insert into response
      select 200, json_object(
          'tid', tid,
          'title', title,
          'status', status,
          'assigned_to', assigned_to)
      from my_task
      where not exists (select * from response);
    commit;

    select json_object('code', code, 'resp', resp) from response;
EOF
    ) ; then
    local code=$(jq -r .code <<< "$res")
    res=$(jq -r .resp <<< "$res")
    [ "$code" = "200" ] && \
      log_event task_lifecycle completed 1 "{\"bird\": $1, \"task\": $2}"
    http_response "$code" "$res"
  else
    res=$(jq -nc --arg err "$res" '{error: $err}')
    http_response 500 "$res"
  fi
}

function shuffle_tasks() {
  local res
  if res=$(sqlite3 -json db 2>&1 <<EOF
    begin immediate;

    with
      new_shuffle_id(val) as
        (select 1+max(shuffle_id) from shuffle),
      random_worker(worker, num) as
        (select bid, row_number() over () from bird where role = 'worker'),
      max_worker_num(val) as
        (select count() from random_worker)
      insert into shuffle(shuffle_id, task_id, assigned_to)
        select
          coalesce(new_shuffle_id.val, 0), tid, worker
        from task, new_shuffle_id, max_worker_num, random_worker
          where task.status <> 'completed'
            and random_worker.num = abs(random()) % max_worker_num.val + 1;

    update task
      set assigned_to = shuffle.assigned_to
      from shuffle
        where tid = shuffle.task_id
          and shuffle_id = coalesce((select max(shuffle_id) from shuffle), 0);
      commit;
EOF
    ) ; then
    http_response 200 '{"done": true}'
  else
    res=$(jq -nc --arg err "$res" '{error: $err}')
    http_response 500 "$res"
  fi
}


function handle_request() {
  local request res
  read -r request

  if ! request=$(http_parse_jwt pub "$request") ; then
    return
  fi

  local role=$(jq -r '.auth.role' <<< "$request")
  local bird=$(jq -r '.auth.bid' <<< "$request")
  local route=$(jq -r '.method + .path' <<< "$request")
  echo $route role: $role, bird: $bird 1>&2

  case $route in
    GET/task)
      res=$(echo 'select * from all_tasks' | sqlite3 -json db | jq -c)
      [ -z "$res" ] && res='[]'
      http_response 200 "$res"
      ;;
    POST/task)
      create_task "$(jq -r '.body.title' <<< "$request")"
      ;;
    POST/task/complete)
      complete_task "$bird" "$(jq -r '.body.task_id' <<< "$request")"
      ;;
    POST/task/shuffle)
      [ "$role" = 'manager' ] && shuffle_tasks \
        || http_response 403 '{"error": "You are not a manager!"}'
      ;;
    *)
      http_response 404 '{"Tweet!": "Tweet!"}'
      ;;
  esac
}

http_server 0.0.0.0 3000 handle_request
