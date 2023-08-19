#!/usr/bin/env bash

docker image rm paw/lib
docker image rm paw-auth
docker image rm paw-task
docker image rm paw-billing
docker image rm paw-schema_registry

docker build -t paw/lib -f lib/Dockerfile lib

docker compose up
docker compose down -v
