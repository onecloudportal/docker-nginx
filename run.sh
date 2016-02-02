#!/bin/bash

# If the application directory is empty, copy the sample site.
APPLICATION_HOME="/data/www"
if [ ! "$(ls -A $APPLICATION_HOME)" ]; then
    cp -r /hello-world-nginx/* $APPLICATION_HOME
fi

# Copy sites-enabled content if the directory is empty
SITES_ENABLED="/etc/nginx/sites-enabled"
if [ ! "$(ls -A $SITES_ENABLED)" ]; then
    cp -r /sites-enabled/* $SITES_ENABLED
fi

# Start Supervisor
exec supervisord -n

