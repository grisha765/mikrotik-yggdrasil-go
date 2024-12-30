# mikrotik-yggdrasil-go

## Installation

1. **Create a virtual interface**  
   Replace `X` with any unused number (for example, `192.168.88.10/24`).  
   ```plaintext
   /interface/veth add address=192.168.88.X/24 gateway=192.168.254.1 name=YAGGDRASIl
   ```
   - This command creates a new VETH (virtual Ethernet) interface on your MikroTik device.

2. **Add the virtual interface to the main bridge**  
   ```plaintext
   /interface/bridge/port add bridge=bridge interface=YAGGDRASIl
   ```
   - This ensures traffic from the YAGGDRASIl interface can reach other LAN interfaces via the main bridge.

3. **Log in to Docker Hub**  
   ```plaintext
   /container/config set registry-url=https://registry-1.docker.io tmpdir=/usb1/docker/pull username=<username> password=<passwd>
   ```
   - Provide your Docker Hub credentials here; this allows the router to pull the container image.

4. **Pull the Yggdrasil container image**  
   ```plaintext
   /container/add remote-image=grisha765/mikrotik-yggdrasil-go:latest interface=YAGGDRASIl root-dir=usb1/docker/yggdrasil start-on-boot=yes envlist=yggdrasil
   ```
   - The `remote-image` option specifies which container image to pull from Docker Hub.  
   - `interface=YAGGDRASIl` sets the VETH interface for the container.  
   - `root-dir=usb1/docker/yggdrasil` is where container data will be stored.  
   - Watch the download progress by running:
     ```plaintext
     /log/print interval=5
     ```

5. **Set up Yggdrasil peers**  
   ```plaintext
   /container/envs add name=yggdrasil key=PEERS value="\"tls://peer_ip:port\", \"tls://peer2_ip:port\""
   ```
   - Add at least one peer so your Yggdrasil node can connect to the Yggdrasil network.

6. **Enable IPv6 forwarding (recommended)**  
   ```plaintext
   /container/envs add name=yggdrasil key=IPV6_FORWARDING value=1
   ```
   - Usually, IPv6 forwarding is enabled by default, but this ensures it remains active.

7. **Start the container**  
   ```plaintext
   /container start [find interface=YAGGDRASIl]
   ```
   - This command starts the container that was just created.

8. **Enter container shell (if needed)**  
   ```plaintext
   /container shell [find interface=YAGGDRASIl]
   ```
   - Opens an interactive shell in the running container for troubleshooting or manual configuration.

9. **Obtain current IPv6 address from Yggdrasil**  
   Inside the container shell, run:
   ```bash
   { ip -6 addr show dev tun0 | grep "inet6" | awk '{print $2}' | cut -d/ -f1; } 2>/dev/null
   # output: 200:1111:2222:3333:4444:5555:6666:7777
   ```
   - You’re interested in the prefix portion, for example `200:1111:2222:3333`.  
   - In MikroTik, you might use `300:1111:2222:3333` instead (simply replace the first digit `2` with `3`).  
   - If your IPv6 address starts with `203`, the prefix in MikroTik would be `303:...`, and so on.

10. **Retrieve the private key from Yggdrasil**  
    Still inside the container shell, run:
    ```bash
    { cat yggdrasil.conf | grep PrivateKey | awk '{print $2}'; } 2>/dev/null
    # output: <your_ygg_private_key>
    ```
    - Keep this key secure; you will need it for configuring a static private key in MikroTik.

11. **Assign a static IPv6 address and IPv4/IPv6 gateway to the virtual interface**  
    ```plaintext
    /interface/veth set YAGGDRASIl address=192.168.88.X/24,300:1111:2222:3333::1/64 gateway6=300:1111:2222:3333::
    ```
    - This configures both IPv4 (`192.168.88.X/24`) and IPv6 (`300:1111:2222:3333::1/64`) addresses on the interface.  
    - The `gateway6` is set to the prefix’s double colon, `300:1111:2222:3333::`.

12. **Set a static private key**  
    ```plaintext
    /container/envs add name=yggdrasil key=PRIVATE_KEY value=<your_ygg_private_key>
    ```
    - This ensures your Yggdrasil node uses the same private key on every startup.

13. **Create an IPv6 pool**  
    ```plaintext
    /ipv6/pool add name=yggdrassil prefix=300:1111:2222:3333::/64 prefix-length=64
    ```
    - This allows MikroTik to distribute IPv6 addresses from the `300:1111:2222:3333::/64` range to internal interfaces.

14. **Add an IPv6 address from the pool to a local interface**  
    ```plaintext
    /ipv6/address add address=::/64 eui-64=yes from-pool=yggdrassil interface=bridge
    ```
    - This automatically configures a local IPv6 address (with EUI-64 format) on your main `bridge`.

15. **Add a route into the Yggdrasil network**  
    ```plaintext
    /ipv6/route add disabled=no distance=1 dst-address=200::/7 gateway=300:1111:2222:3333::1 routing-table=main scope=30 target-scope=10
    ```
    - Routes all traffic destined for `200::/7` (the Yggdrasil global range) through the Yggdrasil container’s IPv6 address.

16. **Restart the container**  
    ```plaintext
    /container stop [find interface=YAGGDRASIl]
    /container start [find interface=YAGGDRASIl]
    ```
    - This applies any changes you made to the container environment or configuration.

17. **Configure firewall rules**  
    ```plaintext
    /ipv6/firewall/filter
    add action=accept chain=input comment="Yggdrassil: allow basic ICMPv6" protocol=icmpv6 src-address=200::/7
    add action=accept chain=forward comment="Yggdrassil: allow basic ICMPv6" protocol=icmpv6 out-interface=bridge src-address=200::/7
    
    add action=accept chain=forward comment="Yggdrassil: allow out ports" connection-state=new,invalid protocol=tcp dst-port=0-32768 src-address=300:1111:2222:3333::/64
    
    add action=drop chain=forward comment="Yggdrassil forward: drop everything else" connection-state=new,invalid out-interface=bridge src-address=200::/7
    add action=drop chain=input comment="Yggdrassil input: drop everything else" connection-state=new,invalid src-address=200::/7
    
    add action=accept chain=forward comment="Yggdrassil forward: accept global" out-interface=bridge src-address=200::/7
    add action=accept chain=forward comment="Yggdrassil forward: accept local" out-interface=bridge src-address=300:1111:2222:3333::/64
    add action=accept chain=input comment="Yggdrassil input: accept global" src-address=200::/7
    add action=accept chain=input comment="Yggdrassil input: accept local" src-address=300:1111:2222:3333::/64
    ```
    - These rules allow basic IPv6 and TCP traffic from your local Yggdrasil address range and drop everything else.  
    - Adjust or add extra rules as needed for your network.

18. **Open a specific port (example: HTTP on port 80)**  
    ```plaintext
    /ipv6/firewall/filter add action=accept chain=forward comment="Yggdrassil: allow http port" connection-state=new,invalid protocol=tcp src-address=300:1111:2222:3333:4444:5555:6666:7777/128 src-port=80
    ```
    - Then move this rule above any “drop” rules:
      ```plaintext
      /ipv6/firewall/filter move [find comment="Yggdrassil: allow http port"] [find comment="Yggdrassil forward: drop everything else"]
      ```
    - This opens TCP port 80 on the specified IPv6 address in your Yggdrasil network.
