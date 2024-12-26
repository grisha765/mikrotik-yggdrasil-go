#!/bin/bash

conf_file=/yggdrasil.conf

[ -f "${conf_file}" ] || yggdrasil -genconf >${conf_file}

sed -i "/Peers: \[.*\]/c\  Peers: [ ${PEERS} ]" ${conf_file}

if [[ -n "${PRIVATE_KEY}" ]]; then
  sed -i "/PrivateKey: .*/c\  PrivateKey: ${PRIVATE_KEY}" ${conf_file}
fi

if [[ "${IPV6_FORWARDING}" == 1 ]]; then
  current_forwarding=$(sysctl -n net.ipv6.conf.all.forwarding)
  if [[ "${current_forwarding}" != 1 ]]; then
    sysctl -w net.ipv6.conf.all.forwarding=1
  fi
fi

exec /usr/bin/yggdrasil -useconffile ${conf_file}
