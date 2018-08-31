#!/usr/bin/env bash


STACK_NAME="full-stack-merlin"

MACHINE_NAME="$1"
if [ -z "$MACHINE_NAME" ]; then
  MACHINE_NAME=$(docker-machine ls | grep stagingServer | awk '{print$1}') 
fi

eval $(docker-machine env $MACHINE_NAME)
docker exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -it $(docker ps | grep 'stagingserver' | awk '{print $1}') /bin/bash
