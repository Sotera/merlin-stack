FROM 52.0.211.45:5000/hadoop-base
MAINTAINER Robert Embleton <robert.embleton@keywcorp.com> and Justin Lueders <justin.lueders@keywcorp.com>
USER root
WORKDIR /usr/local

################################
# Copy the Dockerfile this image was built
# from into the image for posterity
#
################################
COPY Dockerfile /root/merlin-hadoop-base-Dockerfile

################################
#
# Install additional requirements
#
################################
RUN apt-get update && apt-get install -y \
    python-pip python-dev libmysqlclient-dev libpst-dev
RUN pip install --upgrade pip
COPY ./container-files/requirements.txt requirements.txt
RUN pip install -r requirements.txt