FROM docker-registry.parrot-scif.keyw:5000/hadoop-base:0.08.02
MAINTAINER John Reeme <john.reeme@keywcorp.com>

COPY Dockerfile /var/opt/docker/Docker.hadoop

# Install aptitude packages
ARG PACKAGES="\
  libigraph0-dev \
  libpst-dev \
  readpst \
  python-igraph \
  python-opencv \
"

RUN apt-get update && apt-get install -y --no-install-recommends $PACKAGES

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install additional python requirements
RUN mkdir -p /var/opt/python
COPY ./config/requirements.txt /var/opt/python/requirements.txt

RUN pip install -r /var/opt/python/requirements.txt
RUN python -m spacy download en
RUN echo "alias etl='cd /mnt/merlin/merlin-etl'" >> /home/hadoop/.bashrc
RUN echo "export PATH=/mnt/merlin/merlin-etl/share/bin:$PATH" >> /home/hadoop/.bashrc
RUN echo "/mnt/merlin/merlin-etl/share/bin:$PATH" > /etc/container_environment/PATH

#Create /mnt/merlin & /mnt/logs mountpoints so ownership can be set to hadoop.hadoop
RUN mkdir -p /mnt/merlin /mnt/logs
RUN chown hadoop.hadoop /mnt/merlin /mnt/logs

RUN mkdir -p /var/opt/java
COPY config/update_classpath.sh /var/opt/java/update_classpath.sh
RUN chmod 700 /var/opt/java/update_classpath.sh
RUN /var/opt/java/update_classpath.sh

#Add runit folder for managing hadoop process
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

WORKDIR /mnt/merlin/merlin-etl
