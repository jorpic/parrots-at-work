#!/usr/bin/env bash

docker image rm paw/lib
docker image rm paw-auth
docker image rm paw-task

docker build -t paw/lib -f lib/Dockerfile lib

docker compose up
docker compose down -v
