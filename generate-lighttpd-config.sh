#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Create lighttpd config for the specified number of t-rex instances
configfile=/srv/lighttpd/lighttpd.conf

echo '
server.modules += ( "mod_setenv" )
server.modules += ( "mod_proxy" )
server.modules += ( "mod_rewrite" )
server.modules += ( "mod_accesslog" )

server.document-root = "/var/www/"
server.port = 80

server.username = "www"
server.groupname = "www"

server.errorlog = "/dev/stderr"

accesslog.filename = "/dev/fd/2"

proxy.server = (
  "" => (' > $configfile # overwrite current config file

for i in $(seq 1 "$TREX_INSTANCES")
do
  let PORT=6000+$i-1
  if [ ! $i -eq "$TREX_INSTANCES" ]
  then
    echo "    ( \"host\" => \"127.0.0.1\", \"port\" => $PORT )," >> $configfile # append to new config file
  else
    echo "    ( \"host\" => \"127.0.0.1\", \"port\" => $PORT )" >> $configfile # append to new config file
  fi
done

echo '  )
)
' >> $configfile # append to new config file

cat $configfile
