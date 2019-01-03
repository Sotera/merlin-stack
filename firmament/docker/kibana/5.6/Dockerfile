FROM 52.0.211.45:5000/phusion:0.08.04
MAINTAINER Justin Lueders<justin.lueders@keywcorp.com>

COPY Dockerfile /var/opt/docker/Docker.kibana

# add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r kibana && useradd -r -m -g kibana kibana

RUN apt-get update && apt-get install -y \
		apt-transport-https \
		ca-certificates \
		wget \
# generating PDFs requires libfontconfig and libfreetype6
		libfontconfig \
		libfreetype6 \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

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

#Add runit folder for managing newman process
RUN mkdir /etc/service/kibana
RUN mkdir /etc/service/kibana/log
RUN mkdir /var/log/kibana
RUN chown kibana.kibana /var/log/kibana/ /etc/service/kibana/log/

COPY runit /etc/service/kibana/
COPY runit /etc/service/kibana/
COPY runit /etc/service/kibana/log

RUN chmod 755 /etc/service/kibana/run /etc/service/kibana/log/run /etc/service/kibana/start.sh
