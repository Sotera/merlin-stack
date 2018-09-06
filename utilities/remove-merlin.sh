#!/usr/bin/env bash


STACK_NAME="full-stack-merlin"


MACHINES=$(docker-machine ls | grep $STACK_NAME | awk '{print $1}')
if [ "$MACHINES" != "" ]; then
    docker-machine rm $MACHINES --force
fi
