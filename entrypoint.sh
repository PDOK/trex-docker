#!/bin/bash

set -o errexit
set -o pipefail

[[ -z "$TREX_TMS1" ]] && echo "Environment variable TREX_TMS1 is missing. Specify TREX_TMS1 (and optionally TREX_TMS2, TREX_TMS3, etc) environment variables indicating the name of the Tile Matrix Set (TMS) you want to serve." && exit 1
[[ -z "$TREX_CONFIG1" ]] && echo "Environment variable TREX_CONFIG1 is missing. Specify TREX_CONFIG1 (and optionally TREX_CONFIG2, TREX_CONFIG3, etc) environment variables pointing to your trex config files." && exit 1
[[ -z "$TREX_COUNT1" ]] && echo "Environment variable TREX_COUNT1 is missing. Specify TREX_COUNT1 (and optionally TREX_COUNT2, TREX_COUNT3, etc) environment variables indicating the number of processes to run for the given trex config." && exit 1

/etc/scripts/generate-supervisord-config.sh

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
