FROM docker-registry.parrot-les.keyw:5000/hadoop-base:0.08.01
MAINTAINER John Reeme <john.reeme@keywcorp.com>

COPY Dockerfile /var/opt/docker/

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

# Install additional requirements to hadoop-base-alpine base image
COPY ./config/requirements.txt /var/tmp/requirements.txt

RUN pip install --upgrade pip==18.0
RUN hash -r pip
RUN pip install -r /var/tmp/requirements.txt
RUN python -m spacy download en
RUN echo "alias etl='cd /mnt/merlin/merlin-etl'" >> /root/.bashrc
RUN echo "export PATH=/mnt/merlin/merlin-etl/share/bin:$PATH" >> /root/.bashrc

COPY config/update_classpath.sh /var/tmp/update_classpath.sh
RUN chmod 755 /var/tmp/update_classpath.sh
RUN /var/tmp/update_classpath.sh

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

WORKDIR /mnt/merlin/merlin-etl
