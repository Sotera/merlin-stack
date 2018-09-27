FROM 52.0.211.45:5000/phusion:0.07.17
RUN adduser --system --group newman
RUN mkdir /srv/software
WORKDIR /srv/software
RUN apt-get  update \
  && apt-get install -y python-igraph \
  && apt-get install -y git \
  && apt-get install -y python-pip \
  && rm -rf /var/lib/apt/lists/*

RUN printf "Installing \e[0;36mNewman\e[0m \n"

COPY ./config/requirements.txt requirements.txt
RUN pip install --upgrade pip==18.0
RUN hash -r pip
RUN pip2 install -r requirements.txt

RUN git clone https://github.com/Sotera/newman.git /srv/software/newman3
WORKDIR /srv/software/newman3/
RUN git checkout update_ex_5.x

WORKDIR /srv/software/
RUN ln -s /srv/software/newman3 /srv/software/newman

#Init the flask environment
WORKDIR /srv/software/newman3/bin

#Add runit folder for managing newman process
RUN mkdir /etc/service/newman
RUN mkdir /etc/service/newman/log
RUN mkdir /var/log/newman
RUN chown newman.newman /var/log/newman/ /etc/service/newman/log/

COPY runit/start.sh /etc/service/newman/
COPY runit/run /etc/service/newman/
COPY runit/log/run /etc/service/newman/log

RUN chmod 755 /etc/service/newman/run /etc/service/newman/log/run /etc/service/newman/start.sh
