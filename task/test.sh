#!/usr/bin/env bash

auth=localhost:8001
task=localhost:8002/task

echo ======== create a bird
curl -s $auth/bird --data '{"name":"PeepChirp"}'

echo ======== login
JWT=$(curl -s $auth/bird/login --data '{"name":"PeepChirp"}' | jq -r .jwt)
Auth="Auth: Bearer $JWT"

echo ======== create a task
curl -s -H "$Auth" --data '{"title": "sudo make me a sandwich"}' $task

echo ======== get all tasks...
curl -s -H "$Auth" $task | jq -c '.[] | {tid, assigned_to, fee, reward, status}'

echo ======== complete nonexistent task
curl -s -H "$Auth" --data '{"task_id": 2}' $task/complete

echo ======== complete the task
curl -s -H "$Auth" --data '{"task_id": 1}' $task/complete

echo ======== complete the same task again
curl -s -H "$Auth" --data '{"task_id": 1}' $task/complete

echo ======== add more workers
curl -s $auth/bird --data '{"name":"peep"}'
curl -s $auth/bird --data '{"name":"peeppeep"}'
curl -s $auth/bird --data '{"name":"peeppeepchirp"}'
curl -s $auth/bird --data '{"name":"peeppeepchirptweet"}'
curl -s $auth/bird --data '{"name":"peeppeepchirptweetchirrup"}'
curl -s $auth/bird --data '{"name":"peeppeepchirptweetchirruppeep"}'

echo ======== add more tasks
curl -s -H "$Auth" $task --data '{"title": "sudo make me a sandwich"}' > /dev/null
curl -s -H "$Auth" $task --data '{"title": "sudo make me a sandwich"}' > /dev/null
curl -s -H "$Auth" $task --data '{"title": "sudo make me a sandwich"}' > /dev/null
curl -s -H "$Auth" $task --data '{"title": "sudo make me a sandwich"}' > /dev/null
curl -s -H "$Auth" $task --data '{"title": "sudo make me a sandwich"}' > /dev/null
curl -s -H "$Auth" $task --data '{"title": "sudo make me a sandwich"}' > /dev/null
curl -s -H "$Auth" $task --data '{"title": "sudo make me a sandwich"}' > /dev/null
curl -s -H "$Auth" $task | jq -c '.[] | {tid, assigned_to, fee, reward, status}'

echo ======== shuffle as a worker
curl -s -H "$Auth" $task/shuffle --data '{}'

echo ======== register a manager
curl -s $auth/bird --data '{"name": "chirpchirp"}'

echo ======== login as a manager
JWT=$(curl -s $auth/bird/login --data '{"name":"chirpchirp"}' | jq -r .jwt)
Auth="Auth: Bearer $JWT"

echo ======== shuffle
curl -s -H "$Auth" $task/shuffle --data '{}'
curl -s -H "$Auth" $task | jq -c '.[] | {tid, assigned_to, fee, reward, status}'

echo ======== shuffle
curl -s -H "$Auth" $task/shuffle --data '{}'
curl -s -H "$Auth" $task | jq -c '.[] | {tid, assigned_to, fee, reward, status}'
