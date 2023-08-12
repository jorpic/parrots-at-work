#!/usr/bin/env bash

docker compose down -v

docker rm $(docker ps -a -q)

docker image rm paw/lib
docker image rm paw-auth
docker image rm paw-task

docker build -t paw/lib -f lib/Dockerfile lib

docker compose up
