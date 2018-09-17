FROM 52.0.211.45:5000/hadoop-base-alpine:0.07.16
MAINTAINER John Reeme <john.reeme@keywcorp.com>
COPY Dockerfile /root/merlin-hadoop-base-alpine-Dockerfile

WORKDIR /usr/local

# Install additional requirements to hadoop-base-alpine base image
COPY ./config/requirements.txt requirements.txt
RUN apt-get update
RUN apt-get install -y libigraph0-dev python-pip libpst-dev readpst python-igraph

RUN pip install -r requirements.txt
RUN python -m spacy download en
RUN echo "alias etl='cd /mnt/merlin/merlin-etl'" >> /root/.bashrc
RUN echo "export PATH=/mnt/merlin/merlin-etl/share/bin:$PATH" >> /root/.bashrc

COPY config/update_classpath.sh /tmp/update_classpath.sh
RUN chmod 755 /tmp/update_classpath.sh
RUN /tmp/update_classpath.sh

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

WORKDIR /mnt/merlin/merlin-etl
