#!/bin/bash

PEERS="${PEERS:-}"

conf_file=/yggdrasil.conf

[ -f "${conf_file}" ] || yggdrasil -genconf >${conf_file}

sed -i "/Peers: \[.*\]/c\  Peers: [ ${PEERS} ]" ${conf_file}

exec /usr/bin/yggdrasil -useconffile ${conf_file}
