﻿#!/usr/bin/env bash


DEPLOY_DIR="vmware/vmware.parrot.keyw"
STACK_NAME="full-stack-merlin"


MACHINES=$(docker-machine ls | grep $STACK_NAME | awk '{print $1}')
if [ "$MACHINES" != "" ]; then
    docker-machine rm $MACHINES --force
fi


cd ~/src/merlin-stack/firmament/deploy/$DEPLOY_DIR
firmament p b -i full-stack.json


eval $(docker-machine env ${STACK_NAME}-managerNode)

echo -ne "\nWaiting for containers"
for x in $(seq 1 10); do
    echo -ne "."
    sleep 5
done
while true; do
    echo -ne "."
    sleep 5
    replicas=$(docker service ls --format "{{.Replicas}}" | sort -u)
    replicated=true
    for replica in $replicas; do
        n=$(echo $replica | awk -F '/' '{print $1}')
        m=$(echo $replica | awk -F '/' '{print $2}')
        if [ "$n" -ne "$m" ]; then
            replicated=false
        fi
    done
    if [ $replicated == true ]; then
        break
    fi
done

echo -e "\nContainers are operational"
