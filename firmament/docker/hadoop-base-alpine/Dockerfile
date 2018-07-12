FROM 52.0.211.45:5000/hadoop-base-alpine:0.07.11
MAINTAINER John Reeme <john.reeme@keywcorp.com>
COPY Dockerfile /root/merlin-hadoop-base-alpine-Dockerfile

WORKDIR /usr/local

# Install additional requirements to hadoop-base-alpine base image
RUN apk add --no-cache screen
#RUN apt-get install -y python-pip python-dev libmysqlclient-dev libpst-dev screen readpst
#RUN pip install --upgrade pip
#COPY ./container-files/requirements.txt requirements.txt
#RUN pip install -r requirements.txt

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 10.0.1

RUN set -ex; \
	\
	apk add --no-cache --virtual .fetch-deps libressl; \
	\
	wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
	\
	apk del .fetch-deps; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py
