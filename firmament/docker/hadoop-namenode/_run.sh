#!/usr/bin/env bash
docker run -dt --name merlin-hadoop-namenode -h merlin-hadoop-namenode -p 8088:8088 -p 50070:50070 -p 9000:9000 -p 8042:8042 -p 8020:8020 52.0.211.45:5000/merlin-hadoop-namenode
