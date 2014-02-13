# appserver
#
# Based on the 'base' docker image, this container provides :
# - a 'hello world' python web server representing dynamic content on our 
#   infrastructure
# - a serf agent with the 'appserver' role
# - supervisord for process management
#
# VERSION 1.0.0
#
# DOCKER-VERSION 0.7.5

FROM base

MAINTAINER Christophe Uberri <cuberri@gmail.com>

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y curl unzip supervisor

# install the application server (bottle + hello world server)
ADD bottle.py /home/appserver/bottle.py
ADD appserver.py /home/appserver/appserver.py

# install serf
RUN curl -L -o /tmp/serf.zip https://dl.bintray.com/mitchellh/serf/0.4.1_linux_386.zip && unzip -d /usr/local/bin /tmp/serf.zip

# configure supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Boyscout rule
RUN apt-get autoremove -y --purge curl unzip
RUN rm -rf /tmp/*

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
