FROM docker-registry.parrot-scif.keyw:5000/hadoop-base:0.08.06
MAINTAINER John Reeme <john.reeme@keywcorp.com>

COPY Dockerfile /var/opt/docker/Docker.hadoop

ARG _USER=hadoop
ARG _GROUP=$_USER
ARG _HOME=/home/$_USER

ARG _APT_PACKAGES="\
  libigraph0-dev \
  libpst-dev \
  readpst \
  python-igraph \
  python-opencv \
"

RUN \
  apt-get update && apt-get install -y --no-install-recommends $_APT_PACKAGES && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install additional python requirements
RUN mkdir -p /var/opt/python
COPY ./config/requirements.txt /var/opt/python/requirements.txt

RUN pip install -r /var/opt/python/requirements.txt
RUN python -m spacy download en
RUN echo "alias etl='cd /mnt/merlin/merlin-etl'" >> $_HOME/.bashrc

ENV PATH /mnt/merlin/merlin-etl/share/bin:${PATH}

#Create /mnt/merlin & /mnt/logs mountpoints so ownership can be set to hadoop.hadoop
RUN mkdir -p /mnt/merlin /mnt/logs
RUN chown -R $_USER.$_GROUP /mnt/merlin /mnt/logs

ARG _OPT_CLASSPATH=/var/opt/java
ARG _UPDATE_CLASSPATH=$_OPT_CLASSPATH/update_classpath.sh
RUN mkdir -p $_OPT_CLASSPATH
COPY config/update_classpath.sh $_UPDATE_CLASSPATH
RUN chmod 700 $_UPDATE_CLASSPATH
RUN $_UPDATE_CLASSPATH

ARG _DOCKER_ENTRYPOINT=/usr/local/bin/docker-entrypoint.sh
COPY docker-entrypoint.sh $_DOCKER_ENTRYPOINT

RUN chmod 755 $_DOCKER_ENTRYPOINT

WORKDIR /mnt/merlin/merlin-etl
