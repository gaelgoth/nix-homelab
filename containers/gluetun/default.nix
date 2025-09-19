{ config, lib, vars, ... }:
let inherit (lib) mkIf;
in {
  # Only define secret and container when Gluetun is enabled
  sops.secrets.wireguard-private-key = mkIf vars.enableGluetun { };
  virtualisation.oci-containers.containers = mkIf vars.enableGluetun {
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
      ];
      volumes = [
        "data-gluetun:/gluetun"
        "${config.sops.secrets.wireguard-private-key.path}:/run/secrets/wireguard_private_key"
      ];
      ports = [
        "8778:8888/tcp"
        "8001:8000/tcp"
        # Ports for dependent containers (only mapped when using Gluetun). If Gluetun
        # is disabled, those containers expose ports themselves.
        "8080:8080" # qbittorrent
        "6881:6881" # qBittorrent TCP
        "6881:6881/udp" # qBittorrent UDP
        "9091:9091" # transmission web UI
        "51413:51413" # transmission peer port TCP
        "51413:51413/udp" # transmission peer port UDP
      ];
      environment = {
        TZ = vars.timeZone;
        VPN_SERVICE_PROVIDER = "protonvpn";
        VPN_TYPE = "wireguard";
        SERVER_COUNTRIES = "Switzerland";
        WIREGUARD_PRIVATE_KEY_SECRETFILE = "/run/secrets/wireguard_private_key";
        HEALTH_SUCCESS_WAIT_DURATION = "60s";
      };
    };
  };
}
