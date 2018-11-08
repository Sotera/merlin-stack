FROM 52.0.211.45:5000/phusion:0.07.19
MAINTAINER Justin Lueders<justin.lueders@keywcorp.com>
COPY Dockerfile /root/nifi-Dockerfile

RUN useradd -mrU -d /home/nifi -m nifi

COPY /config/nifi.pub /tmp/
RUN mkdir -p /home/nifi/.ssh
RUN cat /tmp/nifi.pub >> /home/nifi/.ssh/authorized_keys && rm -f /tmp/nifi.pub
RUN chown -R nifi:nifi /home/nifi/

#Add runit folder for managing newman process
RUN mkdir /etc/service/nifi
RUN mkdir /etc/service/nifi/log
RUN mkdir /var/log/nifi
RUN chown nifi.nifi /var/log/nifi/ /etc/service/nifi/log/f

COPY runit /etc/service/nifi/
COPY runit /etc/service/nifi/
COPY runit /etc/service/nifi/log

RUN chmod 755 /etc/service/nifi/run /etc/service/nifi/log/run /etc/service/nifi/start.sh
