#!/usr/bin/env bash
set -evx

while getopts u:p: option
do
 case "${option}"
 in
 u) USERNAME=${OPTARG};;
 p) PASSWORD=${OPTARG};;
 esac
done

CLUSTER_PREFIX=merlin
SPOT_PRICE=0.067
NUM_WORKER_HOSTS=1
NUM_WORKERS=3
SPARK_IMAGE=gettyimages/spark:2.0.2-hadoop-2.7

DRIVER_OPTIONS="\
--driver openstack \
--openstack-username $USERNAME \
--openstack-password $PASSWORD \
--openstack-auth-url http://10.1.70.100:5000/v2.0 \
--openstack-flavor-id d2ea7e52-5c57-4856-96c0-cab27c03e160 \
--openstack-image-id f5f3f966-4a87-4b67-acdc-de347e76b0cf \
--openstack-sec-groups All \
--openstack-ssh-user ubuntu \
--openstack-floatingip-pool external-penet \
--openstack-tenant-name Newman \
--engine-insecure-registry 10.1.70.193:5000"

MASTER_OPTIONS="$DRIVER_OPTIONS \
--engine-label role=master"

MASTER_MACHINE_NAME=${CLUSTER_PREFIX}-master
echo docker-machine create $MASTER_OPTIONS $MASTER_MACHINE_NAME

docker-machine create $MASTER_OPTIONS $MASTER_MACHINE_NAME


MASTER_IP=$(docker-machine ip $MASTER_MACHINE_NAME)
echo Swarm master IP = $MASTER_IP

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

docker stack deploy -c merlin_openstack.yml merlin
# docker stack deploy -c etl_os.yml etl
