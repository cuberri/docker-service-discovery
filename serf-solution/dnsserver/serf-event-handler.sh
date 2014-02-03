#!/bin/bash

# sample serf line
# NODE            ADDR         ROLE
# dfaeb89e4569    127.0.0.1    web

# event management :
#   - member-join                  : add entries and emit a frontserver_reload event
#   - member-failed | member-leave : remove dns entries and emit a frontserver_reload event

# used to store the roles of the nodes joining or leaving the cluster
ROLES=

case ${SERF_EVENT} in
	member-join )
		echo "adding dns entries for joined members"
		while read line; do
			NODE=$(echo ${line} | awk '{print $1}')
			ADDR=$(echo ${line} | awk '{print $2}')
			ROLE=$(echo ${line} | awk '{print $3}')
			ROLES="$ROLE $ROLES"
			echo "  new dns entry ${NODE}"
	    	echo -e "$ADDR $ROLE\n$ADDR $NODE" > /etc/dnsmasq-docker/${NODE}
		done
		;;
	member-leave | member-failed )
		echo "removing dns entries"
		while read line; do
			NODE=$(echo ${line} | awk '{print $1}')
			ROLE=$(echo ${line} | awk '{print $3}')
			ROLES="$ROLE $ROLES"
			echo "  delete entry ${NODE}"
			rm -f /etc/dnsmasq-docker/${NODE}
		done
		;;
	* )
		echo "Nothing to do"
		;;
esac

# if at least one entry has been added, reload the dns
if [ "$ROLES" != "" ]; then
	echo "reloading dns entries"
	DNSMASQ_PID=$(supervisorctl status | grep dnsmasq | awk '{print $4}' | tr -d ',')
	kill -SIGHUP $DNSMASQ_PID
fi

# The frontservers need to reload in order to be up to date with appservers
# No need to fire a proxyserver_reload event as they are already aware of the
# updates (hipache listens on frontserver joining and leaving events)
for noderole in $(echo $ROLES | sed 's/ /\n/g' | sort | uniq); do
	if [ "$noderole" = "appserver" ]; then
		echo "at least one appserver node has joined => sending a frontserver_reload event"
		serf event frontserver_reload
	fi
done
