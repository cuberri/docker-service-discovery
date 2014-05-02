Table of Contents
=================

- [Description](#description)
- [Starting and stopping nodes](#starting-and-stopping-nodes)
  - [Launch a private docker registry](#launch-a-private-docker-registry)
  - [Build the containers](#build-the-containers)
  - [Run the containers](#run-the-containers)
  - [Be elastic](#be-elastic)
    - [Scaling up](#scaling-up)
    - [Scaling down](#scaling-down)

Description
===========

This is an implementation of a serf-based practical solution to provide elasticity and service-discovery to an architecture of docker containers.

All the nodes join the same cluster and are autonomous. The nodes are given a role in the cluster (dnsserver, proxyserver, frontserver, appserver).


Starting and stopping nodes
===========================

## Launch a private docker registry

The containers are not pushed to any public registry. You need to use your registry our launch a temporary private one :

```
$ docker run -d -p 5000:5000 registry
...
9947495abfcc7b408bc6f725f0852d5629823db49c9b891e6fa9b33eccb720e2

$ docker ps
CONTAINER ID        IMAGE                            COMMAND                CREATED             STATUS              PORTS                    NAMES
9947495abfcc        samalba/docker-registry:latest   /bin/sh -c cd /docke   3 seconds ago       Up 2 seconds        0.0.0.0:5000->5000/tcp   docker-registry
```

## Build the containers

From the root directory of this repository :

```
$ docker build -t localhost:5000:dnsserver serf-solution/dnsserver
...
$ docker build -t localhost:5000:appserver serf-solution/appserver
...
$ docker build -t localhost:5000:frontserver serf-solution/frontserver
...
$ docker build -t localhost:5000:proxyserver serf-solution/proxyserver
...
```

The containers should be built and tagged :

```
$ docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
localhost:5000            proxyserver         a389c4152c96        3 minutes ago       470.9 MB
localhost:5000            frontserver         1651e592074e        7 minutes ago       455.2 MB
localhost:5000            appserver           c69ec28e16a5        10 minutes ago      382.5 MB
localhost:5000            dnsserver           0a27c9de88b3        13 minutes ago      383.3 MB
...
```

## Run the containers

Running a `dnsserver` node :

```
$ docker run -d --name dnsserver -h dnsserver --dns localhost localhost:5000:dnsserver
```

We have to get the IP Address of the container. It will be used as the serf cluster name for the other nodes to join.

```
$ dns_server_ip=$(docker ps | grep localhost:5000:dnsserver | awk '{print $1}' | sed -n '1 p' | xargs docker inspect | grep IPAddress | cut -d'"' -f4)
$ echo $dns_server_ip 
172.17.0.38
```

--

Run an `appserver` node :

```
$ docker run -d --name appserver1 -h appserver1 --dns $dns_server_ip localhost:5000:appserver
```

--

Run a `frontserver` node

```
$ docker run -d --name frontserver1 -h frontserver1 --dns $dns_server_ip localhost:5000:frontserver
```

--

Run a `proxyserver` node (note the -p option to expose the port 80 on which we'll make requests)

```
$ docker run -d --name proxyserver -h proxyserver --dns $dns_server_ip -p 80:80 localhost:5000:proxyserver
```

--

Check the running containers :

```
$ docker ps
CONTAINER ID        IMAGE                            COMMAND                CREATED             STATUS              PORTS                    NAMES
789504848568        localhost:5000:proxyserver       /usr/bin/supervisord   2 seconds ago       Up 1 seconds        6379/tcp, 80/tcp         proxyserver         
017edb57491b        localhost:5000:frontserver       /usr/bin/supervisord   32 seconds ago      Up 31 seconds       8080/tcp                 frontserver1        
f9d6765a0bf7        localhost:5000:appserver         /usr/bin/supervisord   2 minutes ago       Up 2 minutes        8080/tcp                 appserver1          
f67bc7e17c91        localhost:5000:dnsserver         /usr/bin/supervisord   5 minutes ago       Up 5 minutes        53/tcp                   dnsserver           
9947495abfcc        samalba/docker-registry:latest   /bin/sh -c cd /docke   About an hour ago   Up About an hour    0.0.0.0:5000->5000/tcp   docker-registry
```

--

Test the connectivity by making an HTTP request :

```
$ curl "http://localhost/hello"
Hello frontserver1, I'm appserver1 !
```

## Be elastic

### Scaling up

So far, we are in the "LOW TRAFFIC CONFIGURATION" situation denoted by the schema below :

```
+-----------+     +------------+     +----------+
|proxyserver|+--->|frontserver1|+--->|appserver1|
+-----------+     +------------+     +----------+
```

What if we face an increase of the traffic ? We analyse the traffic and decide that we must add several nodes to support that situation.

Say we want to add one `frontserver` node and two `appserver` nodes. We just have to run as many containers as we want and name them differently :

```
$ docker run -d --name frontserver2 -h frontserver2 --dns $dns_server_ip localhost:5000:frontserver
$ docker run -d --name appserver2 -h appserver2 --dns $dns_server_ip localhost:5000:appserver
$ docker run -d --name appserver3 -h appserver3 --dns $dns_server_ip localhost:5000:appserver
```

Check the running containers :

```
$ docker ps
CONTAINER ID        IMAGE                            COMMAND                CREATED             STATUS              PORTS                          NAMES
cb48c752f551        localhost:5000:appserver         /usr/bin/supervisord   2 seconds ago       Up 1 seconds        8080/tcp                       appserver3          
aae5bb16941e        localhost:5000:appserver         /usr/bin/supervisord   7 seconds ago       Up 6 seconds        8080/tcp                       appserver2          
f12d1103a24e        localhost:5000:frontserver       /usr/bin/supervisord   13 seconds ago      Up 13 seconds       8080/tcp                       frontserver2        
6c5c0da72942        localhost:5000:proxyserver       /usr/bin/supervisord   11 minutes ago      Up 11 minutes       0.0.0.0:80->80/tcp, 6379/tcp   proxyserver         
017edb57491b        localhost:5000:frontserver       /usr/bin/supervisord   13 minutes ago      Up 13 minutes       8080/tcp                       frontserver1        
f9d6765a0bf7        localhost:5000:appserver         /usr/bin/supervisord   15 minutes ago      Up 15 minutes       8080/tcp                       appserver1          
f67bc7e17c91        localhost:5000:dnsserver         /usr/bin/supervisord   18 minutes ago      Up 18 minutes       53/tcp                         dnsserver           
9947495abfcc        samalba/docker-registry:latest   /bin/sh -c cd /docke   About an hour ago   Up About an hour    0.0.0.0:5000->5000/tcp         docker-registry
```

Make some requests to verify the effective load balancing :

```
$ curl "http://localhost/hello"
Hello frontserver2, I'm appserver1 !

core@docker-service-discovery ~/docker-service-discovery $ curl "http://localhost/hello"
Hello frontserver2, I'm appserver3 !

core@docker-service-discovery ~/docker-service-discovery $ curl "http://localhost/hello"
Hello frontserver2, I'm appserver2 !

core@docker-service-discovery ~/docker-service-discovery $ curl "http://localhost/hello"
Hello frontserver1, I'm appserver3 !

core@docker-service-discovery ~/docker-service-discovery $ curl "http://localhost/hello"
Hello frontserver1, I'm appserver2 !

core@docker-service-discovery ~/docker-service-discovery $ curl "http://localhost/hello"
Hello frontserver1, I'm appserver1 !
```

We're done ! We are now in the following "HIGH TRAFFIC CONFIGURATION" :

```
                                     +----------+
                                +--->|appserver1|
                                |    +----------+
                  +------------+|
             +--->|frontserver1|+
             |    +------------+|    
+-----------+|                  |    +----------+
|proxyserver|+                  +--->|appserver2|
+-----------+|                  |    +----------+
             |    +------------+|
             +--->|frontserver2|+
                  +------------+|
                                |    +----------+
                                +--->|appserver3|
                                     +----------+
```

--

### Scaling down

What if the traffic peak is behind us ? Let's scale down !

Stop some containers :

```
$ docker stop appserver3
$ docker stop appserver2
$ docker stop frontserver2
```

Check the running containers :

```
$ docker ps
CONTAINER ID        IMAGE                            COMMAND                CREATED             STATUS              PORTS                          NAMES
6c5c0da72942        localhost:5000:proxyserver       /usr/bin/supervisord   21 minutes ago      Up 21 minutes       0.0.0.0:80->80/tcp, 6379/tcp   proxyserver         
017edb57491b        localhost:5000:frontserver       /usr/bin/supervisord   24 minutes ago      Up 24 minutes       8080/tcp                       frontserver1        
f9d6765a0bf7        localhost:5000:appserver         /usr/bin/supervisord   25 minutes ago      Up 25 minutes       8080/tcp                       appserver1          
f67bc7e17c91        localhost:5000:dnsserver         /usr/bin/supervisord   29 minutes ago      Up 29 minutes       53/tcp                         dnsserver           
9947495abfcc        samalba/docker-registry:latest   /bin/sh -c cd /docke   About an hour ago   Up About an hour    0.0.0.0:5000->5000/tcp         docker-registry
```

Check that we came back to the "LOW TRAFFIC CONFIGURATION" by making some HTTP requests :

```
$ curl "http://localhost/hello"
Hello frontserver1, I'm appserver1 !
```

From now on, all the instanciated containers are persisted. Thus we can add or remove nodes by specifying their names (`docker start/stop node_name` instead of `docker run ...`) :

And we're elastic ! :)
