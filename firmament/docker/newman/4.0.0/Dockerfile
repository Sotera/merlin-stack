FROM 10.1.70.193:5000/phusion-python:0.08.05
MAINTAINER Justin Lueders<justin.lueders@keywcorp.com>

COPY Dockerfile /var/opt/docker/Docker.newman

#Begin adduser (hadoop)
ARG _ROOT_HOME=/root
ARG _KEY_FILE_NAME=parrot
ARG _USER=newman
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
#End adduser (hadoop)

ARG _APT_PACKAGES="\
  git \
  python-igraph \
"

RUN \
  apt-get update && apt-get install -y --no-install-recommends $_APT_PACKAGES && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install additional python requirements
ARG _REQUIREMENTS_PATH=/var/opt/python
ARG _REQUIREMENTS_TEXT=requirements.txt
ARG _REQUIREMENTS_TEXT_PATH=$_REQUIREMENTS_PATH/$_REQUIREMENTS_TEXT
RUN mkdir -p $_REQUIREMENTS_PATH
COPY config/$_REQUIREMENTS_TEXT $_REQUIREMENTS_TEXT_PATH

RUN pip install -r $_REQUIREMENTS_TEXT_PATH
RUN printf "Installing \e[0;36mNewman\e[0m \n"

RUN mkdir -p /srv/software
WORKDIR /srv/software

RUN git clone -b update_ex_5.x https://github.com/Sotera/newman.git /srv/software/newman3

RUN ln -s /srv/software/newman3 /srv/software/newman

#Init the flask environment
WORKDIR /srv/software/newman3/bin

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

#Newman specific chown so flask can loe
RUN chown -R $_USER.$_GROUP /etc/service/$_SERVICE_NAME/log

EXPOSE 5000
