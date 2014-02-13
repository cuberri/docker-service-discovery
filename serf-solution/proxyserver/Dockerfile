# proxyserver
#
# Based on the 'base' docker image, this container provides :
# - hipache proxy server listening on port 80, dispatching requests to front
#   servers
# - supervisord for process management
#
# VERSION 1.0.0
#
# DOCKER-VERSION 0.7.5

FROM base

MAINTAINER Christophe Uberri <cuberri@gmail.com>

# Get a clean worker
RUN apt-get update && apt-get upgrade -y

# Install deps
RUN apt-get install -y curl unzip git redis-server supervisor

# build hipache with all deps installed
# from https://github.com/dotcloud/hipache/blob/master/Dockerfile
RUN cd /usr/local;curl -L http://nodejs.org/dist/v0.8.26/node-v0.8.26-linux-x64.tar.gz | tar xzf - --strip-components=1
RUN npm install hipache -g
RUN mkdir -p /var/log/nginx
ADD config.json /usr/local/lib/node_modules/hipache/config/config_proxyserver.json

# install serf
RUN curl -L -o /tmp/serf.zip https://dl.bintray.com/mitchellh/serf/0.4.1_linux_386.zip && unzip -d /usr/local/bin /tmp/serf.zip
ADD serf-event-handler.sh /home/proxyserver/serf-event-handler.sh
RUN chmod +x /home/proxyserver/serf-event-handler.sh

# configure supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# cleaning
RUN apt-get autoremove -y --purge curl unzip

# Expose squid port
EXPOSE 80
EXPOSE 6379

CMD ["/usr/bin/supervisord", "-n"]
