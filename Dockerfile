FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8

#Runit
RUN apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

RUN apt-get install -y python-pip build-essential python-dev libxml2-dev libxslt1-dev zlib1g-dev
RUN pip install tox

#MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list && \
    apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org
RUN mkdir -p /data/db
RUN pip install pymongo

RUN git clone --depth 1 https://github.com/openstack/zaqar.git
RUN cd zaqar && \
    tox -e genconfig 
RUN cd zaqar && \
    mkdir -p ~/.zaqar && \
    cp etc/zaqar.conf.sample ~/.zaqar/zaqar.conf && \
    cp etc/logging.conf.sample ~/.zaqar/logging.conf
RUN cd zaqar && \
    pip install -e .

RUN sed -i "s|#storage = sqlalchemy|storage = mongodb|" ~/.zaqar/zaqar.conf
RUN sed -i "s|#bind = 127.0.0.1|bind = 0.0.0.0|" ~/.zaqar/zaqar.conf

#Add runit services
ADD sv /etc/service 
