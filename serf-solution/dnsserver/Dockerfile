# dnsserver
#
# Based on the 'base' docker image, this container provides :
# - a simple dns service provided by dnsmasq
# - a serf agent with the 'dnsserver' role
# - supervisord for process management
#
# VERSION 1.0.0
#
# DOCKER-VERSION 0.9.0

FROM ubuntu

MAINTAINER Christophe Uberri <cuberri@gmail.com>

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y curl unzip dnsmasq supervisor

# configure dnsmasq
RUN mkdir -p /etc/dnsmasq-docker
ADD dnsmasq.conf /etc/dnsmasq.conf

# install serf
RUN curl -L -o /tmp/serf.zip https://dl.bintray.com/mitchellh/serf/0.4.1_linux_386.zip && unzip -d /usr/local/bin /tmp/serf.zip
ADD serf-event-handler.sh /home/dnsserver/serf-event-handler.sh
RUN chmod +x /home/dnsserver/serf-event-handler.sh

# configure supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Boyscout rule
RUN apt-get autoremove -y --purge curl unzip
RUN rm -rf /tmp/*

EXPOSE 53

CMD ["/usr/bin/supervisord", "-n"]
