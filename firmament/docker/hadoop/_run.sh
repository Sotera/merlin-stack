#!/usr/bin/env bash
docker run -dt --name merlin-hadoop -h namenode -e HADOOP_MACHINE_ROLE=namenode -p 2222:22 docker-registry.parrot-les.keyw:5000/merlin-hadoop:0.08.01
