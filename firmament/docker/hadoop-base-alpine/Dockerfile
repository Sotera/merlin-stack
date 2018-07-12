FROM 52.0.211.45:5000/hadoop-base-alpine:0.07.11
MAINTAINER John Reeme <john.reeme@keywcorp.com>
COPY Dockerfile /root/merlin-hadoop-base-alpine-Dockerfile

WORKDIR /usr/local

# Install additional requirements to hadoop-base-alpine
RUN apt-get install -y python-pip python-dev libmysqlclient-dev libpst-dev screen readpst
RUN pip install --upgrade pip
COPY ./container-files/requirements.txt requirements.txt
RUN pip install -r requirements.txt
