# mikrotik-yggdrasil-go

```plaintext
/container/config set registry-url=https://registry-1.docker.io tmpdir=/usb1/docker/pull username=<username> password=<passwd>

/interface/bridge add name=Bridge-Docker port-cost-mode=short
/ip/address add address=192.168.254.1/24 interface=Bridge-Docker network=192.168.254.0

/interface/veth add address=192.168.254.3/24 gateway=192.168.254.1 name=YAGGDRASIl
/interface/bridge/port add bridge=Bridge-Docker interface=YAGGDRASIl

/container/add remote-image=grisha765/mikrotik-yggdrasil-go:latest interface=YAGGDRASIl root-dir=usb1/docker/yggdrasil start-on-boot=yes
```

