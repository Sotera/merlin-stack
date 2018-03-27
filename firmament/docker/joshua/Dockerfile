########################################
# build
########################################
FROM 52.0.211.45:5000/alpine-jre:3.7-8 AS build

# Install needed packages. Notes:
#   * dumb-init: a proper init system for containers, to reap zombie children
#   * musl: standard C library
#   * linux-headers: commonly needed, and an unusual package name from Alpine.
#   * build-base: used so we include the basic development packages (gcc)
#   * bash: so we can access /bin/bash
#   * git: to ease up clones of repos
#   * ca-certificates: for SSL verification during Pip and easy_install
#   * python: the binaries themselves
#   * python-dev: are used for gevent e.g.
#   * py-setuptools: required only in major version 2, installs easy_install so we can install Pip.
ENV PACKAGES="\
  wget \
  git \
  python2 \
  python2-dev \
  py-setuptools\
"

RUN apk update

RUN apk add --no-cache $PACKAGES

RUN mkdir /src

COPY ./container-files/* /src/

RUN tar xfz /src/apache-joshua-ar-en-2016-11-18.tgz -C /src && \
    tar xfz /src/apache-joshua-fa-en-2016-11-18.tgz -C /src && \
    tar xfz /src/apache-joshua-es-en-2016-11-18.tgz -C /src && \
    rm /src/*.tgz

RUN git clone https://github.com/justinlueders/joshua_translation_engine.git /src/joshua-decoder

########################################
# production
########################################
FROM 52.0.211.45:5000/alpine-jre:3.7-8 AS production
LABEL maintainer="justin.lueders@keywcorp.com"

ENV PACKAGES="\
  python2 \
  git \
  curl\
  perl \
"

RUN apk update

RUN apk add --no-cache $PACKAGES

# make some useful symlinks that are expected to exist
RUN if [[ ! -e /usr/bin/python ]];        then ln -sf /usr/bin/python2.7 /usr/bin/python; fi && \
  if [[ ! -e /usr/bin/python-config ]]; then ln -sf /usr/bin/python2.7-config /usr/bin/python-config; fi && \
  if [[ ! -e /usr/bin/easy_install ]];  then ln -sf /usr/bin/easy_install-2.7 /usr/bin/easy_install; fi

# Install and upgrade Pip
RUN easy_install pip && \
  pip install --upgrade pip && \
  if [[ ! -e /usr/bin/pip ]]; then ln -sf /usr/bin/pip2.7 /usr/bin/pip; fi

COPY --from=build /src /src

WORKDIR /src/joshua-decoder

RUN pip install -r requirements.txt
RUN python -m nltk.downloader -d /usr/local/share/nltk_data all

EXPOSE 5000

STOPSIGNAL SIGTERM
WORKDIR /src

# Remove dummy files from 52.0.211.45:5000/alpine:3.7
RUN \
  rm /var/local/supervisor/dummy.sh && \
  rm /etc/supervisor.d/dummy.conf

COPY joshua-start.sh /var/local/supervisor/
COPY joshua-supervisord.conf /etc/supervisor.d/

RUN chmod 755 /var/local/supervisor/joshua-start.sh

ENTRYPOINT ["/usr/bin/dumb-init","--"]
CMD ["/usr/bin/supervisord"]

#curl http://localhost:5000/joshua/translate/english -i -H "Content-Type: application/json" -X POST -d '{"inputLanguage": "Spanish", "inputText": "vuelo"}' -v
