FROM 52.0.211.45:5000/merlin-hadoop-base

################################
#
# Format hdfs
#
################################
RUN ${HADOOP_HOME}/bin/hdfs namenode -format

CMD [ "/root/hadoop_entrypoint.sh", "-namenode" ]
################################