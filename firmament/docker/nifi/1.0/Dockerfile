FROM 192.168.99.100:5000/phusion:0.08.05
MAINTAINER Justin Lueders<justin.lueders@keywcorp.com>

COPY Dockerfile /var/opt/docker/Docker.nifi

#Begin adduser (nifi)
ARG _ROOT_HOME=/root
ARG _KEY_FILE_NAME=parrot
ARG _USER=nifi
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
#End adduser (nifi)

ARG _NIFI_PUBLIC_KEY=nifi.pub
ARG _NIFI_SSH_DIR=$_HOME/.ssh
ARG _NIFI_PUBLIC_KEY_PATH=$_NIFI_SSH_DIR/$_NIFI_PUBLIC_KEY
COPY config/$_NIFI_PUBLIC_KEY $_NIFI_PUBLIC_KEY_PATH
RUN \
  cat $_NIFI_PUBLIC_KEY_PATH >> /home/nifi/.ssh/authorized_keys && \
  rm $_NIFI_PUBLIC_KEY_PATH

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
