#!/bin/bash

INITIAL_PORT_OFFSET=2000

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
' > "$configfile"

for count in "${!TREX_COUNT@}"
do
  # extract the instance number e.g. '1' from TREX_COUNT1, '2' from TREX_COUNT2, etc
  instance_nr=$(echo "$count" | tr -dc '0-9')

  # construct environment variable name (e.g. TREX_TMS1, TREX_TMS2, etc)
  tilematrixset_env_var=$(printf 'TREX_TMS%s' "$instance_nr")

  echo "\$HTTP[\"url\"] =~ \"^/${!tilematrixset_env_var}\" {

  proxy.server = (\"\" => (" >> "$configfile"

  # create offset to prevent overlapping port ranges
  port_offset=$((INITIAL_PORT_OFFSET+(instance_nr*1000)))

  # generate lighttpd mod_proxy forwards for each trex instance
  for i in $(seq 1 "${!count}")
  do
    PORT=$((port_offset+i-1)) # should align with supervisord port config for trex
    echo "    ( \"host\" => \"127.0.0.1\", \"port\" => $PORT )," >> "$configfile"
  done

  echo '  ))
}
  ' >> "$configfile"
done

cat "$configfile"
