#!/usr/bin/env bash

USER="$1"
if [ -z "$USER" ]; then
  USER="hadoop"
fi

eval $(docker-machine env rembleton-stack-merlin-stagingServerNode-0)
docker exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -u $USER -it $(docker ps | grep 'stagingserver' | awk '{print $1}') /bin/bash
