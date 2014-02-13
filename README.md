Description
===========

This repository hosts a simple proof of concept of a minimal elastic and service-discovery capable architecture with **docker containers**.

The scenario consists of a classic layered architecture composed of :

* A **proxy server** receiving incoming requests and dispatching into the infrastructure ;
* A set of **front servers** which could process requests for static content and delegate dynamic content processing to backend application servers ;
* A set of **application servers** which could process requests for dynamic content ;

There is no database servers so as to simplify the architecture, but the mecanism could be the same as proposed in the following.
The goal here is to allow easy addition of arbitrary nodes in the architecture to face a potential increase in requests traffic, as shown below.

In other words, at any time :

* The `proxyserver` node must be aware of all the `frontserver` nodes to dispatch the requests to ;
* The `frontserver` nodes must be aware of all the `appserver` nodes to delegate the requests to ;

We want to be elastic, but not (yet) predictive :)

```
              LOW TRAFFIC CONFIGURATION             <=>                HIGH TRAFFIC CONFIGURATION
---------------------------------------------------------------------------------------------------------------
                                                     |                                         +----------+
                                                     |                                    +--->|appserver1|
                                                     |                                    |    +----------+
                                                     |                      +------------+|
                                                     |                 +--->|frontserver1|+
                                                     |                 |    +------------+|    
+-----------+     +------------+     +----------+    |    +-----------+|                  |    +----------+
|proxyserver|+--->|frontserver1|+--->|appserver1|    |    |proxyserver|+                  +--->|appserver2|
+-----------+     +------------+     +----------+    |    +-----------+|                  |    +----------+
                                                     |                 |    +------------+|
                                                     |                 +--->|frontserver2|+
                                                     |                      +------------+|
                                                     |                                    |    +----------+
                                                     |                                    +--->|appserver3|
                                                     |                                         +----------+
```

Technology stack
================

Nodes consist of [docker](https://www.docker.io/) containers :
* The `proxyserver` container is a [hipache](https://github.com/dotcloud/hipache) http proxy (backed by [redis](http://redis.io/)) ;
* The `frontserver` container ise a [nginx](http://nginx.org/) web server ;
* The `appserver` container is [bottle](http://bottlepy.org/) "hello" application ;

In addition, the proposed solutions use :

* A `dnsserver` container providing a DNS service using [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) server ;
* [serf](http://www.serfdom.io/) to provide service-discovery ;

Solutions
=========

* [serf-solution](serf-solution) : this solution is based on [serf](http://www.serfdom.io/) to assure service-discovery and let the nodes to be autonomous ;
* TODO : other solution to come :)

Keywords
========

elastic - service-discovery - docker - hipache - redis - serf - dnsmasq - nginx - bottle
