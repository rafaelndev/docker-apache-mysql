#!/bin/bash

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -f /var/run/apache2/apache2.pid

exec /usr/sbin/apache2ctl -DFOREGROUND
