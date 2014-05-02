# frontserver
#
# Based on the 'base' docker image, this container provides :
# - nginx server listening on port 8080, serving static content and dispatching
#   dynamic content to upstreams (application servers)
# - supervisord for process management
#
# VERSION 1.0.0 - based on dduportal initial work (https://github.com/dduportal/ddu-dockers)
#
# DOCKER-VERSION 0.9.0

FROM ubuntu

MAINTAINER Christophe Uberri <cuberri@gmail.com>

# Get a clean worker
RUN apt-get update && apt-get upgrade -y

# Install deps
RUN apt-get install -y curl unzip supervisor

# Add official nginx repository
RUN curl -o /tmp/nginx_signing.key "http://nginx.org/keys/nginx_signing.key"
RUN apt-key add /tmp/nginx_signing.key
RUN echo "deb http://nginx.org/packages/ubuntu/ $(grep CODENAME /etc/lsb-release | cut -d'=' -f2) nginx" >> /etc/apt/sources.list
RUN echo "deb-src http://nginx.org/packages/ubuntu/ $(grep CODENAME /etc/lsb-release | cut -d'=' -f2) nginx" >> /etc/apt/sources.list
RUN apt-get update

# Install official and basic nginx itself
RUN apt-get install -y nginx

# Configuring nginx
ADD nginx.conf /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/conf.d/*
ADD appserver.conf /etc/nginx/conf.d/appserver.conf

# install serf
RUN curl -L -o /tmp/serf.zip https://dl.bintray.com/mitchellh/serf/0.4.1_linux_386.zip && unzip -d /usr/local/bin /tmp/serf.zip
ADD serf-event-handler.sh /home/frontserver/serf-event-handler.sh
RUN chmod +x /home/frontserver/serf-event-handler.sh

# configure supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# cleaning
RUN apt-get autoremove -y --purge curl unzip

# Expose nginx port
EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
