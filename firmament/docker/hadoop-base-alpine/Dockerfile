FROM 52.0.211.45:5000/hadoop-base-alpine:0.07.11
MAINTAINER John Reeme <john.reeme@keywcorp.com>
COPY Dockerfile /root/merlin-hadoop-base-alpine-Dockerfile

WORKDIR /usr/local

# Install additional requirements to hadoop-base-alpine base image
COPY ./config/requirements.txt requirements.txt
COPY ./config/libpst-0.6.71-r0.apk libpst-0.6.71-r0.apk
RUN apk add --no-cache screen
RUN apk add --no-cache --allow-untrusted libpst-0.6.71-r0.apk
RUN pip install -r requirements.txt

