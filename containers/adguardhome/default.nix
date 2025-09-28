{ config, vars, ... }: {
  networking.firewall.allowedTCPPorts = [
    3000 # API
    3004 # WebUI
    53 # DNS
    5443 # DNSCrypt TCP
    853 # DNS-over-TLS (DoT)
    443 # HTTPS
  ];

  networking.firewall.allowedUDPPorts = [
    3000 # API
    3004 # WebUI
    443 # HTTPS
    53 # DNS
    5443 # DNSCrypt UDP
    67 # DHCP (server)
    68 # DHCP (client)
    784 # DNS-over-QUIC (DoQ)
    853 # DNS-over-DTLS (DoT)
    8853 # DNS-over-TLS (DoT)
  ];

  sops.secrets.ADGUARD_PASSWORDS = { };

  virtualisation.oci-containers.containers = {
    adguardhome = {
      image = "adguard/adguardhome:v0.107.66";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "--network=host"
        "--cap-add=NET_RAW" # Allows the container to use raw networking,
        "-l=homepage.group=System"
        "-l=homepage.name=adguardhome"
        "-l=homepage.icon=adguard-home.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:3004"
        "-l=homepage.description=Ads Blocker"

        "-l=homepage.widget.type=adguard"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:3004"
        "-l=homepage.widget.username=admin"
        "-l=homepage.widget.password={{HOMEPAGE_FILE_ADGUARDHOME_KEY}}"
      ];
  environment = { TZ = config.time.timeZone; };
      volumes = [
        "adguardhome-work-data:/opt/adguardhome/work"
        "adguardhome-conf-data:/opt/adguardhome/conf"
      ];
    };

    adguardhome-exporter = {
      image = "ghcr.io/henrywhitaker3/adguard-exporter:v1.2.1";
      autoStart = true;
      extraOptions = [ "--pull=newer" ];
      # Expose ports
      ports = [ "9618:9618" ];

      environmentFiles = [ config.sops.secrets.ADGUARD_PASSWORDS.path ];

      environment = {
        TZ = config.time.timeZone;
        ADGUARD_SERVERS = "http://${vars.homelabStaticIp}:3004";
        ADGUARD_USERNAMES = "admin";
        DEBUG = "true";
        INTERVAL = "15s";
      };
    };
  };
}
