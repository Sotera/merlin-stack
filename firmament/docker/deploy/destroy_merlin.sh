#!/usr/bin/env bash

CLUSTER_PREFIX=merlin
docker-machine ls | grep "^${CLUSTER_PREFIX}" | cut -d\  -f1 | xargs docker-machine rm -y
