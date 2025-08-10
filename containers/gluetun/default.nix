{ config, vars, ... }: {
  # Secrets used by Gluetun
  sops.secrets.wireguard-private-key = { };
  # HTTP control server auth credentials
  sops.secrets.gluetun_control_username = { };
  sops.secrets.gluetun_control_password = { };

  # Render /gluetun/auth/config.toml for Gluetun's HTTP control server
  sops.templates."gluetun-auth-config" = {
    # Keep strict permissions; only root needs to read
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      [[roles]]
      name = "qbittorrent"
      # Define a list of routes with the syntax "Http-Method /path"
      routes = ["GET /v1/openvpn/portforwarded"]
      # Define an authentication method with its parameters
      auth = "basic"
      username = "{{ .gluetun_control_username }}"
      password = "{{ .gluetun_control_password }}"
    '';
  };
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
        # Mount the rendered control server auth configuration
        "${config.sops.templates."gluetun-auth-config".path}:/gluetun/auth/config.toml"
      ];
      ports = [
        "8080:8080" # qbittorrent
        "6881:6881" # qBittorrent
        "6881:6881/udp" # qBittorrent
        "8000:8000" # Gluetun HTTP control server
        ];
      environment = {
        TZ = vars.timeZone;
        VPN_SERVICE_PROVIDER = "protonvpn";
        VPN_TYPE = "wireguard";
        SERVER_COUNTRIES = "Switzerland";
        WIREGUARD_PRIVATE_KEY_SECRETFILE = "/run/secrets/wireguard_private_key";
        # Optional: override if you change the mount path above
        # HTTP_CONTROL_SERVER_AUTH_CONFIG_FILEPATH = "/gluetun/auth/config.toml";
      };
    };
  };
}
