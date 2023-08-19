#!/usr/bin/env bash

. lib/http.sh
. lib/redpanda.sh
. lib/service.sh

sqlite3 db < schema.sql
log_prepare_topics {bird,task}_streaming task_lifecycle
load_jwt_key

./sync_birds.sh &
./sync_tasks.sh &
./process_tasks.sh &


function handle_request() {
  http_response 404 '{}'
}

http_server 0.0.0.0 3000 handle_request
