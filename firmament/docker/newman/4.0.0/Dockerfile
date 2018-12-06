FROM docker-registry.parrot-scif.keyw:5000/phusion-python:0.08.02
MAINTAINER Justin Lueders<justin.lueders@keywcorp.com>

COPY Dockerfile /var/opt/docker/Docker.newman

#Run hadoop as non-root user
RUN adduser --system --group --home /home/newman --shell /bin/bash newman

# Install aptitude packages
ARG PACKAGES="\
  git \
  python-igraph \
"

RUN apt-get update && apt-get install -y --no-install-recommends $PACKAGES

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install additional python requirements
RUN mkdir -p /var/opt/python
COPY ./config/requirements.txt /var/opt/python/requirements.txt

RUN pip install -r /var/opt/python/requirements.txt
RUN printf "Installing \e[0;36mNewman\e[0m \n"

RUN mkdir -p /srv/software
WORKDIR /srv/software

RUN git clone -b update_ex_5.x https://github.com/Sotera/newman.git /srv/software/newman3

RUN ln -s /srv/software/newman3 /srv/software/newman

#Init the flask environment
WORKDIR /srv/software/newman3/bin

#Add runit folder for managing newman process
RUN mkdir /etc/service/newman
RUN mkdir /etc/service/newman/log
RUN mkdir /var/log/newman
RUN chown newman.newman /var/log/newman/ /etc/service/newman/log/

COPY runit/start.sh /etc/service/newman/
COPY runit/run /etc/service/newman/
COPY runit/log/run /etc/service/newman/log

RUN chmod 755 /etc/service/newman/run /etc/service/newman/log/run /etc/service/newman/start.sh
