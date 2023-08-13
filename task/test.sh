#!/usr/bin/env bash

auth=localhost:8001
task=localhost:8002/task

echo create a bird...
curl -s $auth/bird --data '{"name":"PeepChirp"}'

echo login...
JWT=$(curl -s $auth/bird/login --data '{"name":"PeepChirp"}' | jq -r .jwt)
Auth="Auth: Bearer $JWT"

echo create a task...
curl -H "$Auth" --data '{"title": "sudo make me a sandwich"}' $task

echo get all tasks...
curl -H "$Auth" localhost:8002/task

echo complete nonexistent task...
curl -H "$Auth" --data '{"task_id": 2}' $task/complete

echo complete the task...
curl -H "$Auth" --data '{"task_id": 1}' $task/complete

echo complete the same task again...
curl -H "$Auth" --data '{"task_id": 1}' $task/complete
