{ vars, ... }: {
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

  virtualisation.oci-containers.containers = {
    adguardhome = {
      image = "adguard/adguardhome:v0.107.53";
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

        # "-l=homepage.widget.type=changedetectionio"
        # "-l=homepage.widget.url=http://${vars.homelabStaticIp}:3000"
        # "-l=homepage.widget.key={{HOMEPAGE_FILE_CHANGEDETECTION_KEY}}"
      ];
      # Expose ports
      volumes = [
        "adguardhome-work-data:/opt/adguardhome/work"
        "adguardhome-conf-data:/opt/adguardhome/conf"
      ];
    };
  };
}
