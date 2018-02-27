#!/usr/bin/env bash
set -evx

CLUSTER_PREFIX=merlin
SPOT_PRICE=0.067
NUM_WORKER_HOSTS=1
HADOOP_IMAGE=52.0.211.45:5000/hadoop-base:03
HADOOP_NAMENODE_IMAGE=52.0.211.45:5000/hadoop-namenode:01
SPARK_IMAGE=gettyimages/spark:2.0.2-hadoop-2.7
NGINX_IMAGE=52.0.211.45:5000/nginx:stable

DRIVER_OPTIONS="\
--driver virtualbox \
--virtualbox-cpu-count 2 \
--engine-insecure-registry 52.0.211.45:5000"

MASTER_OPTIONS="$DRIVER_OPTIONS \
--engine-label role=master"

MASTER_MACHINE_NAME=${CLUSTER_PREFIX}-master
docker-machine create $MASTER_OPTIONS $MASTER_MACHINE_NAME

MASTER_IP=$(docker-machine ip $MASTER_MACHINE_NAME)

docker-machine ssh $MASTER_MACHINE_NAME docker swarm init --advertise-addr $MASTER_IP

TOKEN=$(docker-machine ssh $MASTER_MACHINE_NAME docker swarm join-token worker -q)

WORKER_OPTIONS="$DRIVER_OPTIONS"
WORKER_MACHINE_NAME=${CLUSTER_PREFIX}-worker-

for INDEX in $(seq $NUM_WORKER_HOSTS)
do
    (
        docker-machine create $WORKER_OPTIONS $WORKER_MACHINE_NAME$INDEX
        docker-machine ssh $WORKER_MACHINE_NAME$INDEX docker swarm join --token $TOKEN $MASTER_IP:2377
    ) &
done
wait

eval $(docker-machine env $MASTER_MACHINE_NAME)

docker-machine ls

docker stack deploy -c merlin.yml merlin
docker stack deploy -c etl.yml etl


