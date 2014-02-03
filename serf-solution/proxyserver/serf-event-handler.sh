#!/bin/bash

# event management :
#   - member-join                  : add entries to redis if the new nodes' role is frontserver
#   - member-failed | member-leave : remove entries if if the nodes' role is frontserver

case ${SERF_EVENT} in
	member-join )
		while read line; do
			NODE=$(echo ${line} | awk '{print $1}')
			ADDR=$(echo ${line} | awk '{print $2}')
			ROLE=$(echo ${line} | awk '{print $3}')
			if [ "${ROLE}" = "frontserver" ]; then
				echo "  got new frontserver : ${ADDR} (${NODE}). Adding it to redis (if not already exists)"
				# we can push either NODE or ADDR since we have the dns resolution
				# let's use ADDR to avoid a useless DNS request
				entry="http://${ADDR}:8080"
		    	/usr/bin/redis-cli lrange frontend:localhost 0 -1 | grep -q ${ADDR} \
		    	|| /usr/bin/redis-cli rpush frontend:localhost $entry
	    	fi
		done
		;;
	member-leave | member-failed )
		while read line; do
			if [ "${ROLE}" = "frontserver" ]; then
				NODE=$(echo ${line} | awk '{print $1}')
				ROLE=$(echo ${line} | awk '{print $3}')
				ROLES="$ROLE $ROLES"
				entry="http://${ADDR}:8080"
				echo "  removing frontserver ${ADDR} (${NODE}) from redis"
				/usr/bin/redis-cli lrem frontend:localhost 0 $entry
			fi
		done
		;;
	* )
		echo "Nothing to do"
		;;
esac
