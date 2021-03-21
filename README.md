<p align="center">
    <a href="https://nordvpn.com/"><img src="https://github.com/satishweb/docker-nordvpn/raw/master/NordVpn_logo.png"/></a>
</p>

Official `NordVPN` client in a kubernetes/docker container; it makes routing traffic through the `NordVPN` network easy.

# How to use this image (Kubernetes examples to be added)

This container was designed to be started first to provide a connection to other containers (using `--net=container:vpn`, see below *Starting an NordVPN client instance*).

**NOTE**: More than the basic privileges are needed for NordVPN. With docker 1.2 or newer you can use the `--cap-add=NET_ADMIN` and `--device /dev/net/tun` options. Earlier versions, or with fig, and you'll have to run it in privileged mode.

## Starting an NordVPN instance

    docker run -ti --cap-add=NET_ADMIN --cap-add=SYS_MODULE --device /dev/net/tun --name vpn \
                --sysctl net.ipv4.conf.all.rp_filter=2 \
                -e USER=user@email.com -e PASS='pas$word' \
                -e CONNECT=country -e TECHNOLOGY=NordLynx -d satishweb/nordvpn

Once it's up other containers can be started using it's network connection:

    docker run -it --net=container:vpn -d some/docker-container


# ENVIRONMENT VARIABLES

 * `USER`     - User for NordVPN account.
 * `PASS`     - Password for NordVPN account, surrounding the password in single quotes will prevent issues with special characters such as `$`.
 * `CONNECT`  -  [country]/[server]/[country_code]/[city]/[group] or [country] [city], if none provide you will connect to  the recommended server.
   - Provide a [country] argument to connect to a specific country. For example: Australia , Use `docker run --rm satishweb/nordvpn sh -c "nordvpnd & sleep 1 && nordvpn countries"` to get the list of countries.
   - Provide a [server] argument to connecto to a specific server. For example: jp35 , [Full List](https://nordvpn.com/servers/tools/)
   - Provide a [country_code] argument to connect to a specific country. For example: us 
   - Provide a [city] argument to connect to a specific city. For example: 'Hungary Budapest' , Use `docker run --rm satishweb/nordvpn sh -c "nordvpnd & sleep 1 && nordvpn cities [country]"` to get the list of cities. 
   - Provide a [group] argument to connect to a specific servers group. For example: P2P , Use `docker run --rm satishweb/nordvpn sh -c "nordvpnd & sleep 1 && nordvpn groups"` to get the full list.
   - --group value, -g value  Specify a server group to connect to. For example: 'us -g p2p'
 * `TECHNOLOGY` - Specify Technology to use: 
   * OpenVPN    - Traditional connection.
   * NordLynx   - NordVpn wireguard implementation (3x-5x times faster). NOTE: Requires `--cap-add=SYS_MODULE` and `--sysctl net.ipv4.conf.all.rp_filter=2`
 * `PROTOCOL`   - TCP or UDP (only valid when using OpenVPN).
 * `OBFUSCATE`  - Enable or Disable. When enabled, this feature allows to bypass network traffic sensors which aim to detect usage of the protocol and log, throttle or block it (only valid when using OpenVpn). 
 * `CYBER_SEC`  - Enable or Disable. When enabled, the CyberSec feature will automatically block suspicious websites so that no malware or other cyber threats can infect your device. Additionally, no flashy ads will come into your sight. More information on how it works: https://nordvpn.com/features/cybersec/.
 * `DNS` -   Can set up to 3 DNS servers. For example 1.1.1.1,8.8.8.8 or Disable, Setting DNS disables CyberSec.
 * `WHITELIST` - List of domains that are gonna be accessible _outside_ vpn (IE rarbg.to,yts.am).
 * `NETWORK`  - CIDR networks (IE 192.168.1.0/24), add a route to allows replies once the VPN is up.
 * `NETWORK6` - CIDR IPv6 networks (IE fe00:d34d:b33f::/64), add a route to allows replies once the VPN is up.
 * `TZ` - Set a timezone (IE EST5EDT, America/Denver, [full list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)).
 * `GROUPID` - Set the GID for the vpn.
 * `DEBUG`    - Set to 'on' for troubleshooting (User and Pass would be log).
 * `PORTS`  - Semicolon delimited list of ports to whitelist for both UDP and TCP. For example `- PORTS=9091;9095`
