#!/usr/bin/env bash
#HADOOP_MACHINE_ROLE=$1

${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
#cd ${HADOOP_HOME}/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == ${cp}; curl -LO ${cp} ; done; cd -
export CLASSPATH=${CLASSPATH}:${HIVE_HOME}/lib/*:.
export CLASSPATH=${CLASSPATH}:${HADOOP_HOME}/lib/*:.
export CLASSPATH=${CLASSPATH}:${JAVA_HOME}/lib/*:.

#HADOOP_MACHINE_ROLE=('namenode'|'datanode'|'spark_worker'|'staging_server')
case ${HADOOP_MACHINE_ROLE} in
  namenode)
    # Check for existence of $HADOOP_DATA/dfs/name/current/VERSION, if not then format
    if [ ! -f ${HADOOP_DATA}/dfs/name/current/VERSION ]; then
      echo "Formatting hdfs namenode"
      ${HADOOP_HOME}/bin/hdfs namenode -format
    fi
    ${HADOOP_HOME}/sbin/hadoop-daemon.sh start namenode
    ${HADOOP_HOME}/sbin/yarn-daemon.sh start resourcemanager
    echo "Creating tmp dir for worker startup polling"

    hdfs dfs -mkdir -p /tmp

    while ! hdfs dfs -test -e hdfs://namenode:9000/tmp
    do
        echo "Attempting to create hdfs:/tmp"
        hdfs dfs -mkdir -p /tmp
        sleep 2
    done

    hdfs dfs -chmod 0777 /tmp
    echo "Creating hive scratch and warehouse directories in hdfs"
    hdfs dfs -mkdir -p /user/hive/warehouse
    hdfs dfs -chmod 0777 /user/hive
    hdfs dfs -chmod 0777 /user/hive/warehouse
    hdfs dfs -mkdir -p /tmp/hive
    hdfs dfs -chmod 0777 /tmp/hive
    mkdir /tmp/hive
    chmod -R 0777 /tmp/hive
    mkdir ${HIVE_HOME}/tmp
    ;;
  datanode)
    while ! hdfs dfs -test -e hdfs://namenode:9000/tmp; do sleep 2; done
    ${HADOOP_HOME}/sbin/hadoop-daemon.sh start datanode
    ;;
  sparkworker)
    while ! hdfs dfs -test -e hdfs://namenode:9000/tmp; do sleep 2; done
    ${HADOOP_HOME}/sbin/yarn-daemon.sh start nodemanager
    ;;
  stagingserver)
    IPS="$(hostname --all-ip-addresses || hostname -I)"
    echo "Jupyter will be running on one of the following IPs":
    echo $IPS

    PYSPARK_DRIVER_PYTHON="jupyter" \
    PYSPARK_DRIVER_PYTHON_OPTS="notebook --no-browser --port=9999 --ip='*' --allow-root --notebook-dir='/mnt/merlin/notebooks' --NotebookApp.token=''" \
    screen -dmS spark dse pyspark \
    --conf spark.driver.maxResultSize=10g \
    --conf spark.kryoserializer.buffer.max=2000m \
    --name merlin_notebook \
    --driver-memory 10g \
    --executor-memory 10g \
    --conf spark.dynamicAllocation.enabled=true \
    --conf spark.shuffle.enabled=trueS
    ;;
  *)
    echo "Unknown Hadoop Machine Role Encountered"
    exit 1
    ;;
esac

echo "Starting container as ${HADOOP_MACHINE_ROLE}"

while true;
do
  echo ">> docker-entrypoint heartbeat << @ "`date`
  sleep 60;
done
