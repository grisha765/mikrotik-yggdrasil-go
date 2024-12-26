# mikrotik-yggdrasil-go

```plaintext
/container/config set registry-url=https://registry-1.docker.io tmpdir=/usb1/docker/pull username=<username> password=<passwd>

/interface/veth add address=192.168.88.30/24 gateway=192.168.88.1 name=YAGGDRASIl
/interface/bridge/port add bridge=bridge interface=YAGGDRASIl

/container/envs add name=yggdrasil key=PEERS value="\"tls://peer_ip:port\", \"tls://peer2_ip:port\""

# if you have your private key
/container/envs add name=yggdrasil key=PRIVATE_KEY value=<your_ygg_private_key>

# if you set static ipv6 in veth then enable ipv6 forwarding
/container/envs add name=yggdrasil key=IPV6_FORWARDING value=1

/container/add remote-image=grisha765/mikrotik-yggdrasil-go:latest interface=YAGGDRASIl root-dir=usb1/docker/yggdrasil start-on-boot=yes envlist=yggdrasil
```

