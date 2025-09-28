{ config, ... }: {
  sops.secrets.wireguard-private-key = { };
  virtualisation.oci-containers.containers = {
    gluetun = {
      image = "qmcgaw/gluetun:v3.40.0";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun"
        "-l=homepage.group=System"
        "-l=homepage.name=Gluetun"
        "-l=homepage.icon=gluetun.svg"
        "-l=homepage.description=VPN Client for containers"
        # # "-l=homepage.widget.type=gluetun"
        # "-l=homepage.widget.url=http://${vars.homelabStaticIp}:3022"
        # "-l=homepage.widget.key=TODO"
      ];
      volumes = [
        "data-gluetun:/gluetun"
        "${config.sops.secrets.wireguard-private-key.path}:/run/secrets/wireguard_private_key"
      ];
      ports = [
        "8778:8888/tcp"
        "8001:8000/tcp"
        "8080:8080" # qbittorrent
        "6881:6881" # qBittorrent
        "6881:6881/udp" # qBittorrent
        "9091:9091" # transmission web UI
        "51413:51413" # transmission peer port TCP
        "51413:51413/udp" # transmission peer port UDP
      ];
      environment = {
        TZ = config.time.timeZone;
        VPN_SERVICE_PROVIDER = "protonvpn";
        VPN_TYPE = "wireguard";
        SERVER_COUNTRIES = "Switzerland";
        WIREGUARD_PRIVATE_KEY_SECRETFILE = "/run/secrets/wireguard_private_key";
        HEALTH_SUCCESS_WAIT_DURATION = "60s";
        # TOR_ONLY = "on";
      };
    };
  };
}
