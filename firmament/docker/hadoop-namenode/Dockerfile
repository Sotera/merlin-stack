FROM 52.0.211.45:5000/merlin-hadoop-base:0.07.11

################################
# Copy the Dockerfile this image was built
# from into the image for posterity
#
################################
COPY Dockerfile /root/merlin-hadoop-namenode-Dockerfile

################################
#
# Format hdfs
#
################################
RUN ${HADOOP_HOME}/bin/hdfs namenode -format

CMD [ "/root/hadoop_entrypoint.sh", "-namenode" ]
################################