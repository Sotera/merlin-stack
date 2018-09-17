#!/usr/bin/env bash
docker run -dt --name merlin-hadoop-base-alpine -h namenode -e HADOOP_MACHINE_ROLE=namenode 52.0.211.45:5000/merlin-hadoop-base-alpine:0.07.16
