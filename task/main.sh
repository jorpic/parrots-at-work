#!/usr/bin/env bash

set -o pipefail

. lib/http.sh
. lib/redpanda.sh


sqlite3 db < schema.sql
log_wait_for_topic task
./sync_birds.sh &

while [ 1 ] ; do
  if curl -s auth:3000/jwt_key | jq -r '.pub' > pub ; then
    break
  fi
  sleep 1
done


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
    # FIXME: can fail if there are no workers
    log_event task task_created "$res"
    http_response 200 "$res"
  else
    res=$(jq -nc --arg err "$res" '{error: $err}')
    http_response 400 "$res"
  fi
}


function complete_task() { # bid, task_id
  local res
  if res=$(sqlite3 db 2>&1 <<EOF
    create temporary table response(code int not null, resp text not null);
    create temporary view my_task as
      select * from task
        where tid = cast(x'$(echo -n $2 | xxd -ps)' as int);

    begin;
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
      where assigned_to <> $1
        and not exists (select * from response);

    update task
      set status = 'completed'
      where assigned_to = $1
        and tid = cast(x'$(echo -n $2 | xxd -ps)' as int)
        and not exists (select * from response);

    insert into response
      select 200, json_object(
          'tid', tid,
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
    if [ "$code" = "200" ] ; then
      log_event task task_completed "$res"
    fi
    http_response "$code" "$res"
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
    POST/task)
      create_task "$(jq -r '.body.title' <<< "$request")"
      ;;
    POST/task/complete)
      complete_task "$bird" "$(jq -r '.body.task_id' <<< "$request")"
      ;;
    GET/task)
      res=$(echo 'select * from all_tasks' | sqlite3 -json db | jq -c)
      [ -z "$res" ] && res='[]'
      http_response 200 "$res"
      ;;
    *)
      http_response 404 '{"Tweet!": "Tweet!"}'
      ;;
  esac
}

http_server 0.0.0.0 3000 handle_request
