#!/bin/bash

INITIAL_PORT_OFFSET=2000

set -o errexit
set -o nounset
set -o pipefail

configfile=/etc/supervisor/conf.d/supervisord.conf

# lighttpd config
echo '
[supervisord]
nodaemon=true
pidfile=/tmp/supervisord.pid
logfile=/dev/null
logfile_maxbytes=0

[program:lighttpd]
priority=999 ; high priority = start last, shutdown first
command=/bin/sh -c "/etc/scripts/generate-lighttpd-config.sh && exec lighttpd -D -f /srv/lighttpd/lighttpd.conf"
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
user=www
autorestart=unexpected
startretries=3
startsecs=3
stopsignal=INT ; lighttpd uses SIGINT for graceful shutdown
stopwaitsecs=15
' > "$configfile"

# trex config, iterate over TREX_CONFIG1, TREX_CONFIG2, etc environment vars and build supervisor config
for conf in "${!TREX_CONFIG@}"
do
  instance_nr=$(echo "$conf" | tr -dc '0-9')
echo "
[program:trex_${instance_nr}]
priority=20 ; low priority = start first, shutdown last
command=/usr/bin/t_rex serve --config=/var/data/in/${!conf}
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
user=www
autorestart=unexpected
startretries=3
startsecs=2
stopsignal=TERM ; t-rex (actixweb) uses SIGTERM for graceful shutdown
stopwaitsecs=15
numprocs=%(ENV_TREX_COUNT${instance_nr})s
numprocs_start=$((INITIAL_PORT_OFFSET+(instance_nr*1000))) ; should match port offset in generate-lighttpd-config.sh
process_name=%(program_name)s_%(process_num)s
environment=PORT=\"%(process_num)s\" ; set port number
"
done >> "$configfile"

cat "$configfile"
