#!/usr/bin/env bash
docker run -dt --name hadoop -h namenode -e HADOOP_MACHINE_ROLE=namenode -p 2222:22 10.1.70.193:5000/hadoop:0.08.05
