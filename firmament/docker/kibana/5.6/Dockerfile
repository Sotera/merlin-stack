FROM 10.1.70.193:5000/phusion:0.08.05
MAINTAINER Justin Lueders<justin.lueders@keywcorp.com>

COPY Dockerfile /var/opt/docker/Docker.kibana

#Begin adduser (kibana)
ARG _ROOT_HOME=/root
ARG _KEY_FILE_NAME=parrot
ARG _USER=kibana
ARG _GROUP=$_USER
ARG _HOME=/home/$_USER
ARG _USER_ID=907
ARG _GROUP_ID=907
RUN addgroup --gid $_GROUP_ID $_GROUP
RUN adduser --system --uid=$_USER_ID --gid=$_GROUP_ID --home $_HOME --shell /bin/bash $_USER
RUN mkdir -p $_HOME/.ssh
RUN chmod 700 $_HOME/.ssh
RUN cat /root/.ssh/$_KEY_FILE_NAME.pub >> $_HOME/.ssh/authorized_keys
RUN chown $_USER.$_GROUP $_HOME/.ssh/authorized_keys
RUN chmod 644 $_HOME/.ssh/authorized_keys

RUN \
  cp $_ROOT_HOME/.vimrc $_HOME/.vimrc && \
  cp $_ROOT_HOME/.profile $_HOME/.profile && \
  cp $_ROOT_HOME/.bashrc $_HOME/.bashrc

RUN chown -R $_USER.$_GROUP $_HOME
#Add user to docker_env group so it can participate in phusion ENV vars
RUN usermod -aG docker_env $_USER
#End adduser (kibana)

# generating PDFs requires libfontconfig and libfreetype6
ARG _APT_PACKAGES="\
  apt-transport-https \
  ca-certificates \
  wget \
  libfontconfig \
  libfreetype6 \
"

RUN \
  apt-get update && apt-get install -y --no-install-recommends $_APT_PACKAGES && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -ex; \
# https://artifacts.elastic.co/GPG-KEY-elasticsearch
	key='46095ACC8548582C1A2699A9D27D666CD88E42B4'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --batch --export "$key" > /etc/apt/trusted.gpg.d/elastic.gpg; \
	rm -rf "$GNUPGHOME"; \
	apt-key list

# https://www.elastic.co/guide/en/kibana/5.0/deb.html
RUN echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' > /etc/apt/sources.list.d/kibana.list

ENV KIBANA_VERSION 5.6.14

RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends kibana=$KIBANA_VERSION \
	&& rm -rf /var/lib/apt/lists/* \
	\
# the default "server.host" is "localhost" in 5+
	&& sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" /etc/kibana/kibana.yml \
	&& grep -q "^server\.host: '0.0.0.0'\$" /etc/kibana/kibana.yml \
	\
# ensure the default configuration is useful when using --link
	&& sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 'http://elasticsearch:9200'!" /etc/kibana/kibana.yml \
	&& grep -q "^elasticsearch\.url: 'http://elasticsearch:9200'\$" /etc/kibana/kibana.yml

ENV PATH /usr/share/kibana/bin:$PATH

#Configure runit for service
ARG _SERVICE_NAME=$_USER
RUN mkdir /etc/service/$_SERVICE_NAME
RUN mkdir /etc/service/$_SERVICE_NAME/log
RUN mkdir /var/log/$_SERVICE_NAME
RUN chown -R $_USER.$_GROUP /var/log/$_SERVICE_NAME

COPY runit/start.sh /etc/service/$_SERVICE_NAME/
COPY runit/run /etc/service/$_SERVICE_NAME/
COPY runit/log/run /etc/service/$_SERVICE_NAME/log

RUN chmod 755 /etc/service/$_SERVICE_NAME/run /etc/service/$_SERVICE_NAME/log/run /etc/service/$_SERVICE_NAME/start.sh

WORKDIR /var/log/$_SERVICE_NAME

