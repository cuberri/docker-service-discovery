#!/bin/bash

# reload nginx configuration if the frontserver_reload event is received
if [[ "${SERF_EVENT}" = "user" && "${SERF_USER_EVENT}" = "frontserver_reload" ]]; then
	echo "reloading nginx"
	kill -HUP $(cat /var/run/nginx.pid)
	exit 0
fi

echo "Nothing to do"
