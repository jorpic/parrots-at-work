#!/usr/bin/env bash


docker compose rm
docker compose down -v

docker image rm $(docker image ls -q)
docker rm $(docker ps -a -q)

docker image rm paw/lib
docker image rm paw/auth

docker build -t paw/lib -f lib/Dockerfile lib
docker build -t paw/auth -f auth/Dockerfile auth

docker compose up
