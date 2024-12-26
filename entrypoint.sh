#!/bin/bash

conf_file=/yggdrasil.conf

[ -f "${conf_file}" ] || yggdrasil -genconf >${conf_file}

sed -i "/Peers: \[.*\]/c\  Peers: [ ${PEERS} ]" ${conf_file}

if [[ -n "${PRIVATEKEY}" ]]; then
  sed -i "/PrivateKey: .*/c\  PrivateKey: ${PRIVATEKEY}" ${conf_file}
fi

exec /usr/bin/yggdrasil -useconffile ${conf_file}
