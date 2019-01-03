FROM 192.168.99.100:5000/phusion:0.08.05
MAINTAINER Justin Lueders<justin.lueders@keywcorp.com>

COPY Dockerfile /var/opt/docker/Docker.nifi

#RUN useradd -mrU -d /home/nifi -m nifi

#Run hadoop as non-root user
RUN adduser --system --group --home /home/nifi --shell /bin/bash nifi

USER nifi
RUN mkdir -p /home/nifi/.ssh
COPY config/nifi.pub /home/nifi/.ssh
RUN cat /home/nifi/.ssh/nifi.pub >> /home/nifi/.ssh/authorized_keys

USER root
