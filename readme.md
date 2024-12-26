# mikrotik-yggdrasil-go

```plaintext
/interface/bridge add name=Bridge-Docker port-cost-mode=short
/ip/address add address=192.168.254.1/24 interface=Bridge-Docker network=192.168.254.0

# where X is your favorite number other than 1 and 0
/interface/veth add address=192.168.254.X/24 gateway=192.168.254.1 name=YAGGDRASIl
/interface/bridge/port add bridge=Bridge-Docker interface=YAGGDRASIl
```

```plaintext
/container/config set registry-url=https://registry-1.docker.io tmpdir=/usb1/docker/pull username=<username> password=<passwd>
/container/add remote-image=grisha765/mikrotik-yggdrasil-go:latest interface=YAGGDRASIl root-dir=usb1/docker/yggdrasil start-on-boot=yes envlist=yggdrasil
```

```plaintext
# be sure to set peers from https://github.com/yggdrasil-network/public-peers
/container/envs add name=yggdrasil key=PEERS value="\"tls://peer_ip:port\", \"tls://peer2_ip:port\""

# if you have your private key
/container/envs add name=yggdrasil key=PRIVATE_KEY value=<your_ygg_private_key>

# if you set static ipv6 in veth then enable ipv6 forwarding
/container/envs add name=yggdrasil key=IPV6_FORWARDING value=1
```
