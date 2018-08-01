FROM 52.0.211.45:5000/hadoop-base-alpine:0.07.14
MAINTAINER John Reeme <john.reeme@keywcorp.com>
COPY Dockerfile /root/merlin-hadoop-base-alpine-Dockerfile

WORKDIR /usr/local

# Install additional requirements to hadoop-base-alpine base image
COPY ./config/requirements.txt requirements.txt
COPY ./config/libpst-0.6.71-r0.apk libpst-0.6.71-r0.apk
RUN apk add --no-cache screen file p7zip
RUN apk add --no-cache --allow-untrusted libpst-0.6.71-r0.apk
RUN pip install -r requirements.txt
RUN curl -o /usr/local/hadoop/share/hadoop/yarn/lib/elasticsearch-spark-20_2.11-6.3.2.jar https://repo.maven.apache.org/maven2/org/elasticsearch/elasticsearch-spark-20_2.11/6.3.2/elasticsearch-spark-20_2.11-6.3.2.jar
RUN echo -e "alias etl 'cd /mnt/merlin/merlin-etl'\r\nexport PATH=\$PATH:/mnt/merlin/merlin-etl/share/bin" >> /root/.bashrc