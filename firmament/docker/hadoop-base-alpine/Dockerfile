FROM 52.0.211.45:5000/hadoop-base-alpine:0.07.14
MAINTAINER John Reeme <john.reeme@keywcorp.com>
COPY Dockerfile /root/merlin-hadoop-base-alpine-Dockerfile

WORKDIR /usr/local

# Install additional requirements to hadoop-base-alpine base image
COPY ./config/requirements.txt requirements.txt
RUN apt-get install -y libigraph0-dev python-pip build-essential python-dev libpst-dev readpst

RUN pip install -r requirements.txt
RUN curl -o /usr/local/hadoop/share/hadoop/yarn/lib/elasticsearch-spark-20_2.11-6.3.2.jar https://repo.maven.apache.org/maven2/org/elasticsearch/elasticsearch-spark-20_2.11/6.3.2/elasticsearch-spark-20_2.11-6.3.2.jar
RUN echo "alias etl='cd /mnt/merlin/merlin-etl'" >> /root/.bashrc
RUN echo "export PATH=/mnt/merlin/merlin-etl/share/bin:$PATH" >> /root/.bashrc
WORKDIR /mnt/merlin/merlin-etl
